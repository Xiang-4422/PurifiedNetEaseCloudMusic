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
  bool _hasLocalData = false;

  /// 当前账号是否已有本地资料库数据。
  bool get hasLocalData => _hasLocalData;

  /// 当前账号是否已有本地歌单数据。
  bool get hasPlaylistData => userPlayLists.isNotEmpty || userLikedSongPlayList.value.id.isNotEmpty;

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
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      _clearScopedState();
      _hasLocalData = false;
      return;
    }
    await Future.wait([
      refreshLikedSongIds(),
      refreshUserPlaylists(),
    ]);
    if (_sessionController.userInfo.value.userId != userId) {
      return;
    }
    await refreshRandomLikedSong();
    if (_sessionController.userInfo.value.userId != userId) {
      return;
    }
    _hasLocalData = true;
  }

  /// 刷新用户喜欢歌曲 id 列表。
  Future<void> refreshLikedSongIds() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      likedSongIds.clear();
      return;
    }
    final nextLikedSongIds = await _repository.fetchLikedSongIds(userId);
    if (_sessionController.userInfo.value.userId != userId) {
      return;
    }
    likedSongIds
      ..clear()
      ..addAll(nextLikedSongIds);
  }

  /// 刷新用户歌单列表并拆分“我喜欢的音乐”入口。
  Future<void> refreshUserPlaylists() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      userPlayLists.clear();
      userLikedSongPlayList.value = const PlaylistSummaryData(id: '', title: '');
      return;
    }
    final playLists = await _repository.fetchUserPlaylists(userId);
    if (_sessionController.userInfo.value.userId != userId) {
      return;
    }
    if (playLists.isEmpty) {
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

  /// 切换当前歌曲的喜欢状态，并返回更新后的队列项。
  Future<PlaybackQueueItem?> toggleLikeStatus(
    PlaybackQueueItem currentSong,
  ) async {
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
    if (_sessionController.userInfo.value.userId != userId) {
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
    if (likedSongIds.isEmpty) {
      likedSongs.clear();
      return;
    }
    if (!force && likedSongs.length == likedSongIds.length) {
      return;
    }
    if (!force) {
      final cachedLikedSongs = await _repository.loadCachedSongsByIds(
        ids: likedSongIds.map((e) => e.toString()).toList(),
        likedSongIds: likedSongIds.toList(),
      );
      if (cachedLikedSongs.length == likedSongIds.length) {
        likedSongs
          ..clear()
          ..addAll(cachedLikedSongs);
        return;
      }
    }
    final remoteLikedSongs = await getSongsByIds(likedSongIds.map((e) => e.toString()).toList());
    likedSongs
      ..clear()
      ..addAll(remoteLikedSongs);
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
    final userId = _sessionController.userInfo.value.userId;
    final nextRandomLikedSong = await _resolveRandomLikedSong();
    if (_sessionController.userInfo.value.userId != userId) {
      return;
    }
    randomLikedSongId.value = nextRandomLikedSong.songId;
    randomLikedSongAlbumUrl.value = nextRandomLikedSong.albumUrl;
  }

  Future<({String songId, String albumUrl})> _resolveRandomLikedSong() async {
    var nextRandomLikedSongId = '';
    var nextRandomLikedSongAlbumUrl = '';
    if (likedSongIds.isNotEmpty) {
      final randomIndex = Random().nextInt(likedSongIds.length);
      nextRandomLikedSongId = likedSongIds[randomIndex].toString();
      nextRandomLikedSongAlbumUrl = await _repository.loadCachedSongAlbumUrl(nextRandomLikedSongId);
      if (nextRandomLikedSongAlbumUrl.isEmpty) {
        nextRandomLikedSongAlbumUrl = await _repository.fetchSongAlbumUrl(nextRandomLikedSongId);
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
    final cachedLikedIds = await _repository.loadCachedLikedSongIds(userId);
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    likedSongIds
      ..clear()
      ..addAll(cachedLikedIds);
    hasCachedData = hasCachedData || cachedLikedIds.isNotEmpty;

    final cachedUserPlayLists = await _repository.loadCachedPlaylistList(
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

    final cachedLikedPlaylist = await _repository.loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.likedCollection,
    );
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    userLikedSongPlayList.value = cachedLikedPlaylist.isEmpty ? const PlaylistSummaryData(id: '', title: '') : cachedLikedPlaylist.first;
    hasCachedData = hasCachedData || userLikedSongPlayList.value.id.isNotEmpty;

    final nextRandomLikedSong = await _resolveRandomLikedSong();
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    randomLikedSongId.value = nextRandomLikedSong.songId;
    randomLikedSongAlbumUrl.value = nextRandomLikedSong.albumUrl;
    hasCachedData = hasCachedData || nextRandomLikedSong.albumUrl.isNotEmpty;
    _hasLocalData = hasCachedData;
  }

  bool _isCurrentLocalDataLoad(String userId, int generation) {
    return generation == _localDataGeneration && _activeLocalDataUserId == userId && _sessionController.userInfo.value.userId == userId;
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
}
