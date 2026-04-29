import 'dart:async';
import 'dart:math';

import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';

/// 持有账号作用域下的资料库状态。
class UserLibraryController extends GetxController {
  /// to。
  static UserLibraryController get to => Get.find();

  /// 创建 UserLibraryController。
  UserLibraryController({
    required UserRepository repository,
    required UserSessionController sessionController,
  })  : _repository = repository,
        _sessionController = sessionController;

  final UserRepository _repository;
  final UserSessionController _sessionController;
  Future<void>? _cacheBootstrapFuture;
  String _activeSnapshotUserId = '';
  bool _hasLocalSnapshot = false;

  /// hasLocalSnapshot。
  bool get hasLocalSnapshot => _hasLocalSnapshot;

  /// userPlayLists。
  final List<PlaylistSummaryData> userPlayLists = <PlaylistSummaryData>[].obs;

  /// userLikedSongPlayList。
  final Rx<PlaylistSummaryData> userLikedSongPlayList =
      const PlaylistSummaryData(id: '', title: '').obs;

  /// likedSongIds。
  final RxList<int> likedSongIds = <int>[].obs;

  /// likedSongs。
  final RxList<PlaybackQueueItem> likedSongs = <PlaybackQueueItem>[].obs;

  /// randomLikedSongId。
  final RxString randomLikedSongId = ''.obs;

  /// randomLikedSongAlbumUrl。
  final RxString randomLikedSongAlbumUrl = ''.obs;

  /// ensureCacheLoaded。
  Future<void> ensureCacheLoaded() async {
    await (_cacheBootstrapFuture ?? Future<void>.value());
  }

  /// loadScopedSnapshot。
  Future<void> loadScopedSnapshot(String userId) {
    return _loadScopedSnapshot(userId);
  }

  @override
  void onInit() {
    super.onInit();
    _cacheBootstrapFuture = _loadCache();
    ever<UserSessionData>(_sessionController.userInfo, (info) {
      if (_activeSnapshotUserId == info.userId) {
        return;
      }
      _activeSnapshotUserId = info.userId;
      unawaited(loadScopedSnapshot(info.userId));
    });
  }

  /// refreshUserLibrary。
  Future<void> refreshUserLibrary() async {
    await Future.wait([
      refreshLikedSongIds(),
      refreshUserPlaylists(),
    ]);
    await refreshRandomLikedSong();
    _hasLocalSnapshot = true;
  }

  /// refreshLikedSongIds。
  Future<void> refreshLikedSongIds() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      likedSongIds.clear();
      return;
    }
    final nextLikedSongIds = await _repository.fetchLikedSongIds(userId);
    likedSongIds
      ..clear()
      ..addAll(nextLikedSongIds);
  }

  /// refreshUserPlaylists。
  Future<void> refreshUserPlaylists() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      return;
    }
    final playLists = await _repository.fetchUserPlaylists(userId);
    if (playLists.isEmpty) {
      return;
    }

    final mutablePlayLists = [...playLists];
    final nextLikedPlaylist =
        mutablePlayLists.removeAt(0).copyWith(title: '我喜欢的音乐');
    userLikedSongPlayList.value = nextLikedPlaylist;
    userLikedSongPlayList.refresh();
    userPlayLists
      ..clear()
      ..addAll(mutablePlayLists);
  }

  /// toggleLikeStatus。
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
    final serverStatus =
        await _repository.toggleLikeSong(userId, songId, !isLiked);
    if (!serverStatus.success) {
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

  /// ensureLikedSongsLoaded。
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
    likedSongs
      ..clear()
      ..addAll(
        await getSongsByIds(likedSongIds.map((e) => e.toString()).toList()),
      );
  }

  /// getHeartBeatSongs。
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

  /// getSongsByIds。
  Future<List<PlaybackQueueItem>> getSongsByIds(List<String> ids) {
    return _repository.fetchSongsByIds(
      ids: ids,
      likedSongIds: likedSongIds.toList(),
    );
  }

  /// refreshRandomLikedSong。
  Future<void> refreshRandomLikedSong() async {
    var nextRandomLikedSongId = '';
    var nextRandomLikedSongAlbumUrl = '';
    if (likedSongIds.isNotEmpty) {
      final randomIndex = Random().nextInt(likedSongIds.length);
      nextRandomLikedSongId = likedSongIds[randomIndex].toString();
      nextRandomLikedSongAlbumUrl =
          await _repository.loadCachedSongAlbumUrl(nextRandomLikedSongId);
      if (nextRandomLikedSongAlbumUrl.isEmpty) {
        nextRandomLikedSongAlbumUrl =
            await _repository.fetchSongAlbumUrl(nextRandomLikedSongId);
      }
    }
    randomLikedSongId.value = nextRandomLikedSongId;
    randomLikedSongAlbumUrl.value = nextRandomLikedSongAlbumUrl;
  }

  Future<void> _loadCache() async {
    await _sessionController.ensureCacheLoaded();
    _activeSnapshotUserId = _sessionController.userInfo.value.userId;
    await loadScopedSnapshot(_activeSnapshotUserId);
  }

  Future<void> _loadScopedSnapshot(String userId) async {
    _clearScopedState();
    if (userId.isEmpty) {
      _hasLocalSnapshot = false;
      return;
    }

    var hasCachedData = false;
    final cachedLikedIds = await _repository.loadCachedLikedSongIds(userId);
    likedSongIds
      ..clear()
      ..addAll(cachedLikedIds);
    hasCachedData = hasCachedData || cachedLikedIds.isNotEmpty;

    final cachedUserPlayLists = await _repository.loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.userPlaylists,
    );
    userPlayLists
      ..clear()
      ..addAll(cachedUserPlayLists);
    hasCachedData = hasCachedData || cachedUserPlayLists.isNotEmpty;

    final cachedLikedPlaylist = await _repository.loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.likedCollection,
    );
    userLikedSongPlayList.value = cachedLikedPlaylist.isEmpty
        ? const PlaylistSummaryData(id: '', title: '')
        : cachedLikedPlaylist.first;
    hasCachedData = hasCachedData || userLikedSongPlayList.value.id.isNotEmpty;

    await refreshRandomLikedSong();
    hasCachedData = hasCachedData || randomLikedSongAlbumUrl.value.isNotEmpty;
    _hasLocalSnapshot = hasCachedData;
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
