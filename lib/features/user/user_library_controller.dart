import 'dart:async';
import 'dart:math';

import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';

/// 持有账号作用域下的资料库状态。
class UserLibraryController extends GetxController {
  static const int _homeFrequentPlaylistLimit = 8;

  /// 当前用户资料库控制器实例。
  static UserLibraryController get to => Get.find();

  /// 创建用户资料库控制器。
  UserLibraryController({
    required UserRepository repository,
    required UserSessionController sessionController,
  })  : _repository = repository,
        _sessionController = sessionController;

  final UserRepository _repository;
  final UserSessionController _sessionController;
  Future<void>? _cacheBootstrapFuture;
  String _activeLocalDataUserId = '';
  int _localDataGeneration = 0;
  int _likedSongsLoadGeneration = 0;
  bool _hasLocalData = false;
  bool _disposed = false;

  /// 当前账号是否已有本地资料库数据。
  bool get hasLocalData => _hasLocalData;

  /// 当前账号是否已有本地歌单数据。
  bool get hasPlaylistData => userPlayLists.isNotEmpty || userLikedSongPlayList.value.id.isNotEmpty;

  /// 首页轻量展示的常用歌单，复用用户歌单顺序并限制数量。
  List<PlaylistSummaryData> get homeFrequentPlaylists {
    return userPlayLists.take(_homeFrequentPlaylistLimit).toList(growable: false);
  }

  /// 用户创建或收藏的普通歌单列表，不包含“我喜欢的音乐”入口。
  final List<PlaylistSummaryData> userPlayLists = <PlaylistSummaryData>[].obs;

  /// “我喜欢的音乐”歌单入口。
  final Rx<PlaylistSummaryData> userLikedSongPlayList = const PlaylistSummaryData(id: '', title: '').obs;

  /// 用户喜欢歌曲的网易云数字 id 列表。
  final RxList<int> likedSongIds = <int>[].obs;

  /// 已加载的喜欢歌曲播放队列项。
  final RxList<PlaybackQueueItem> likedSongs = <PlaybackQueueItem>[].obs;

  /// 随机选中的喜欢歌曲 id，用于心动模式入口。
  final RxString randomLikedSongId = ''.obs;

  /// 随机喜欢歌曲对应的封面地址。
  final RxString randomLikedSongAlbumUrl = ''.obs;

  /// 等待用户资料库缓存启动加载完成。
  Future<void> ensureCacheLoaded() async {
    await (_cacheBootstrapFuture ?? Future<void>.value());
  }

  /// 重新载入指定用户作用域下的本地资料库数据。
  Future<void> loadScopedLocalData(String userId) {
    if (_disposed) {
      return Future<void>.value();
    }
    _activeLocalDataUserId = userId;
    final generation = ++_localDataGeneration;
    return _loadScopedLocalData(userId, generation);
  }

  @override
  void onInit() {
    super.onInit();
    _cacheBootstrapFuture = _loadCache();
    ever<UserSessionData>(_sessionController.userInfo, (info) {
      if (_activeLocalDataUserId == info.userId) {
        return;
      }
      unawaited(loadScopedLocalData(info.userId));
    });
  }

  /// 刷新用户喜欢歌曲和歌单数据。
  Future<void> refreshUserLibrary() async {
    if (_disposed) {
      return;
    }
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      _clearScopedState();
      _hasLocalData = false;
      return;
    }
    final hadVisibleLibraryData = _hasVisibleLibraryData;
    final hadLocalData = _hasLocalData;
    try {
      final snapshot = await _repository.fetchUserLibrarySnapshot(userId);
      if (!_isActiveSession(userId)) {
        return;
      }
      final nextRandomLikedSong = await _resolveRandomLikedSong(snapshot.likedSongIds);
      if (!_isActiveSession(userId)) {
        return;
      }
      _applyLikedSongIds(snapshot.likedSongIds);
      _applyUserPlaylists(snapshot.playlists);
      randomLikedSongId.value = nextRandomLikedSong.songId;
      randomLikedSongAlbumUrl.value = nextRandomLikedSong.albumUrl;
      _hasLocalData = true;
    } catch (_) {
      if (!_isActiveSession(userId)) {
        return;
      }
      _hasLocalData = hadLocalData || hadVisibleLibraryData;
      if (!hadLocalData && !hadVisibleLibraryData) {
        rethrow;
      }
    }
  }

  /// 刷新用户喜欢歌曲 id 列表。
  Future<void> refreshLikedSongIds() async {
    if (_disposed) {
      return;
    }
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      likedSongIds.clear();
      return;
    }
    final nextLikedSongIds = await _repository.fetchLikedSongIds(userId);
    if (!_isActiveSession(userId)) {
      return;
    }
    _applyLikedSongIds(nextLikedSongIds);
  }

  /// 刷新用户歌单列表并拆分“我喜欢的音乐”入口。
  Future<void> refreshUserPlaylists() async {
    if (_disposed) {
      return;
    }
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      userPlayLists.clear();
      userLikedSongPlayList.value = const PlaylistSummaryData(id: '', title: '');
      return;
    }
    final playLists = await _repository.fetchUserPlaylists(userId);
    if (!_isActiveSession(userId)) {
      return;
    }
    _applyUserPlaylists(playLists);
  }

  /// 切换当前歌曲的喜欢状态，并返回更新后的队列项。
  Future<PlaybackQueueItem?> toggleLikeStatus(
    PlaybackQueueItem currentSong,
  ) async {
    if (_disposed) {
      return null;
    }
    final userId = _sessionController.userInfo.value.userId;
    final songId = _resolveSongSourceId(currentSong);
    final numericSongId = int.tryParse(songId);
    if (userId.isEmpty || numericSongId == null) {
      return null;
    }

    final isLiked = likedSongIds.contains(numericSongId);
    final serverStatus = await _repository.toggleLikeSong(userId, songId, !isLiked);
    if (!serverStatus.success) {
      return null;
    }
    if (!_isActiveSession(userId)) {
      return null;
    }

    final updatedSong = currentSong.copyWith(isLiked: !isLiked);
    if (isLiked) {
      likedSongIds.remove(numericSongId);
      likedSongs.removeWhere(
        (item) => _resolveSongSourceId(item) == songId,
      );
    } else {
      likedSongIds.add(numericSongId);
      if (likedSongs.isNotEmpty) {
        likedSongs.add(updatedSong);
      }
    }
    await refreshRandomLikedSong();
    return updatedSong;
  }

  /// 确保喜欢歌曲队列已加载，可通过 `force` 强制远程刷新。
  Future<void> ensureLikedSongsLoaded({bool force = false}) async {
    if (_disposed) {
      return;
    }
    final userId = _sessionController.userInfo.value.userId;
    final requestedLikedSongIds = likedSongIds.toList();
    final generation = ++_likedSongsLoadGeneration;
    if (userId.isEmpty || userId == '-1' || requestedLikedSongIds.isEmpty) {
      likedSongs.clear();
      return;
    }
    if (!force && _likedSongsMatchIds(requestedLikedSongIds)) {
      return;
    }
    try {
      if (!force) {
        final cachedLikedSongs = await _repository.loadCachedSongsByIds(
          ids: requestedLikedSongIds.map((e) => e.toString()).toList(),
          likedSongIds: requestedLikedSongIds,
        );
        if (!_isCurrentLikedSongsLoad(userId, generation, requestedLikedSongIds)) {
          return;
        }
        if (cachedLikedSongs.length == requestedLikedSongIds.length) {
          likedSongs
            ..clear()
            ..addAll(cachedLikedSongs);
          return;
        }
      }
      final remoteLikedSongs = await _repository.fetchSongsByIds(
        ids: requestedLikedSongIds.map((e) => e.toString()).toList(),
        likedSongIds: requestedLikedSongIds,
      );
      if (!_isCurrentLikedSongsLoad(userId, generation, requestedLikedSongIds)) {
        return;
      }
      likedSongs
        ..clear()
        ..addAll(remoteLikedSongs);
    } catch (_) {
      if (!_isCurrentLikedSongsLoad(userId, generation, requestedLikedSongIds)) {
        return;
      }
      rethrow;
    }
  }

  /// 拉取心动模式歌曲队列。
  Future<List<PlaybackQueueItem>> getHeartBeatSongs(
    String startSongId,
    String randomLikedSongId,
    bool fromPlayAll,
  ) {
    return _repository.fetchHeartBeatSongs(
      startSongId: startSongId,
      randomLikedSongId: randomLikedSongId,
      fromPlayAll: fromPlayAll,
      likedSongIds: likedSongIds.toList(),
    );
  }

  /// 按歌曲 id 拉取播放队列项。
  Future<List<PlaybackQueueItem>> getSongsByIds(List<String> ids) {
    return _repository.fetchSongsByIds(
      ids: ids,
      likedSongIds: likedSongIds.toList(),
    );
  }

  /// 刷新随机喜欢歌曲及其封面，用于心动模式入口展示。
  Future<void> refreshRandomLikedSong() async {
    if (_disposed) {
      return;
    }
    final userId = _sessionController.userInfo.value.userId;
    final nextRandomLikedSong = await _resolveRandomLikedSong(likedSongIds);
    if (!_isActiveSession(userId)) {
      return;
    }
    randomLikedSongId.value = nextRandomLikedSong.songId;
    randomLikedSongAlbumUrl.value = nextRandomLikedSong.albumUrl;
  }

  Future<({String songId, String albumUrl})> _resolveRandomLikedSong(List<int> sourceLikedSongIds) async {
    var nextRandomLikedSongId = '';
    var nextRandomLikedSongAlbumUrl = '';
    if (sourceLikedSongIds.isNotEmpty) {
      final randomIndex = Random().nextInt(sourceLikedSongIds.length);
      nextRandomLikedSongId = sourceLikedSongIds[randomIndex].toString();
      nextRandomLikedSongAlbumUrl = await _loadCachedSongAlbumUrl(nextRandomLikedSongId);
      if (nextRandomLikedSongAlbumUrl.isEmpty) {
        nextRandomLikedSongAlbumUrl = await _fetchSongAlbumUrl(nextRandomLikedSongId);
      }
    }
    return (songId: nextRandomLikedSongId, albumUrl: nextRandomLikedSongAlbumUrl);
  }

  Future<void> _loadCache() async {
    await _sessionController.ensureCacheLoaded();
    await loadScopedLocalData(_sessionController.userInfo.value.userId);
  }

  Future<void> _loadScopedLocalData(String userId, int generation) async {
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    _clearScopedState();
    if (userId.isEmpty) {
      _hasLocalData = false;
      return;
    }

    var hasCachedData = false;
    final cachedLikedIds = await _loadCachedLikedSongIds(userId);
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    likedSongIds
      ..clear()
      ..addAll(cachedLikedIds);
    hasCachedData = hasCachedData || cachedLikedIds.isNotEmpty;

    final cachedUserPlayLists = await _loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.userPlaylists,
    );
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    userPlayLists
      ..clear()
      ..addAll(cachedUserPlayLists);
    hasCachedData = hasCachedData || cachedUserPlayLists.isNotEmpty;

    final cachedLikedPlaylist = await _loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.likedCollection,
    );
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    userLikedSongPlayList.value = cachedLikedPlaylist.isEmpty ? const PlaylistSummaryData(id: '', title: '') : cachedLikedPlaylist.first;
    hasCachedData = hasCachedData || userLikedSongPlayList.value.id.isNotEmpty;

    final nextRandomLikedSong = await _resolveRandomLikedSong(likedSongIds);
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    randomLikedSongId.value = nextRandomLikedSong.songId;
    randomLikedSongAlbumUrl.value = nextRandomLikedSong.albumUrl;
    hasCachedData = hasCachedData || nextRandomLikedSong.albumUrl.isNotEmpty;
    _hasLocalData = hasCachedData;
  }

  Future<List<int>> _loadCachedLikedSongIds(String userId) async {
    try {
      return await _repository.loadCachedLikedSongIds(userId);
    } catch (_) {
      return const [];
    }
  }

  Future<List<PlaylistSummaryData>> _loadCachedPlaylistList(
    String userId,
    UserPlaylistListKind kind,
  ) async {
    try {
      return await _repository.loadCachedPlaylistList(userId, kind);
    } catch (_) {
      return const [];
    }
  }

  Future<String> _loadCachedSongAlbumUrl(String songId) async {
    try {
      return await _repository.loadCachedSongAlbumUrl(songId);
    } catch (_) {
      return '';
    }
  }

  Future<String> _fetchSongAlbumUrl(String songId) async {
    try {
      return await _repository.fetchSongAlbumUrl(songId);
    } catch (_) {
      return '';
    }
  }

  bool _isCurrentLocalDataLoad(String userId, int generation) {
    return !_disposed && generation == _localDataGeneration && _activeLocalDataUserId == userId && _sessionController.userInfo.value.userId == userId;
  }

  bool _isCurrentLikedSongsLoad(
    String userId,
    int generation,
    List<int> requestedLikedSongIds,
  ) {
    return !_disposed && generation == _likedSongsLoadGeneration && _isActiveSession(userId) && _sameLikedSongIds(requestedLikedSongIds);
  }

  bool _isActiveSession(String userId) {
    return !_disposed && _sessionController.userInfo.value.userId == userId;
  }

  bool get _hasVisibleLibraryData {
    final hasPlaylistData = userPlayLists.isNotEmpty || userLikedSongPlayList.value.id.isNotEmpty;
    return likedSongIds.isNotEmpty || likedSongs.isNotEmpty || hasPlaylistData || randomLikedSongId.value.isNotEmpty || randomLikedSongAlbumUrl.value.isNotEmpty;
  }

  void _applyLikedSongIds(List<int> nextLikedSongIds) {
    final nextSongIds = nextLikedSongIds.map((songId) => songId.toString()).toList(growable: false);
    likedSongIds
      ..clear()
      ..addAll(nextLikedSongIds);
    if (likedSongs.isEmpty) {
      return;
    }
    if (nextSongIds.isEmpty) {
      likedSongs.clear();
      return;
    }
    final loadedSongsById = {
      for (final song in likedSongs) _resolveSongSourceId(song): song,
    };
    likedSongs
      ..clear()
      ..addAll(
        nextSongIds.map((songId) => loadedSongsById[songId]).whereType<PlaybackQueueItem>().map((song) => song.copyWith(isLiked: true)),
      );
  }

  void _applyUserPlaylists(List<PlaylistSummaryData> playLists) {
    if (playLists.isEmpty) {
      userLikedSongPlayList.value = const PlaylistSummaryData(id: '', title: '');
      userPlayLists.clear();
      return;
    }

    final mutablePlayLists = [...playLists];
    final nextLikedPlaylist = mutablePlayLists.removeAt(0).copyWith(title: '我喜欢的音乐');
    userLikedSongPlayList.value = nextLikedPlaylist;
    userLikedSongPlayList.refresh();
    userPlayLists
      ..clear()
      ..addAll(mutablePlayLists);
  }

  bool _sameLikedSongIds(List<int> requestedLikedSongIds) {
    if (likedSongIds.length != requestedLikedSongIds.length) {
      return false;
    }
    for (var index = 0; index < requestedLikedSongIds.length; index++) {
      if (likedSongIds[index] != requestedLikedSongIds[index]) {
        return false;
      }
    }
    return true;
  }

  bool _likedSongsMatchIds(List<int> requestedLikedSongIds) {
    if (likedSongs.length != requestedLikedSongIds.length) {
      return false;
    }
    for (var index = 0; index < requestedLikedSongIds.length; index++) {
      if (_resolveSongSourceId(likedSongs[index]) != requestedLikedSongIds[index].toString()) {
        return false;
      }
    }
    return true;
  }

  String _resolveSongSourceId(PlaybackQueueItem song) {
    if (song.sourceId.isNotEmpty) {
      return song.sourceId;
    }
    if (song.id.startsWith('netease:')) {
      return song.id.substring('netease:'.length);
    }
    return song.id;
  }

  void _clearScopedState() {
    likedSongIds.clear();
    likedSongs.clear();
    userPlayLists.clear();
    userLikedSongPlayList.value = const PlaylistSummaryData(id: '', title: '');
    randomLikedSongAlbumUrl.value = '';
    randomLikedSongId.value = '';
  }

  @override
  void onClose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _localDataGeneration++;
    _likedSongsLoadGeneration++;
    super.onClose();
  }
}
