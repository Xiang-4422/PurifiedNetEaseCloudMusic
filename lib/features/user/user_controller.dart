import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 收口账号相关的本地缓存、用户资料和快捷入口数据。
///
/// 当前仍保留少量 `Hive` 读写，是因为这些数据还没有完全迁入正式本地库，
/// 先集中在这里比继续散落到页面里更容易替换。
class UserController extends GetxController {
  static const Duration _startupDataTtl = Duration(minutes: 10);
  static const String _startupSyncMarker = 'startup_home';

  static UserController get to => Get.find();
  UserController({
    required UserRepository repository,
    required this.box,
  }) : _repository = repository;

  final Box box;
  final UserRepository _repository;
  bool _hasLocalSnapshot = false;
  Future<void>? _cacheBootstrapFuture;
  String _activeSnapshotUserId = '';

  bool get hasLocalSnapshot => _hasLocalSnapshot;

  Future<void> ensureCacheLoaded() async {
    await (_cacheBootstrapFuture ?? Future<void>.value());
  }

  Future<bool> shouldRefreshStartupData() async {
    await ensureCacheLoaded();
    if (!_hasLocalSnapshot) {
      return true;
    }
    final userId = userInfo.value.userId;
    if (userId.isEmpty) {
      return true;
    }
    return !(await _repository.isSyncMarkerFresh(
      userId: userId,
      markerKey: _startupSyncMarker,
      ttl: _startupDataTtl,
    ));
  }

  Future<void> _loadCache() async {
    final String? userInfoStr = box.get(userInfoSp);
    if (userInfoStr != null) {
      userInfo.value = UserSessionData.fromJson(jsonDecode(userInfoStr));
    }
    _activeSnapshotUserId = userInfo.value.userId;
    await _loadScopedSnapshot(_activeSnapshotUserId);
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
    if (cachedLikedIds.isNotEmpty) {
      hasCachedData = true;
    }

    final cachedReco = await _repository.loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.recommended,
    );
    recoPlayLists
      ..clear()
      ..addAll(cachedReco);
    if (cachedReco.isNotEmpty) {
      hasCachedData = true;
    }

    final cachedUserPlayLists = await _repository.loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.userPlaylists,
    );
    userPlayLists
      ..clear()
      ..addAll(cachedUserPlayLists);
    if (cachedUserPlayLists.isNotEmpty) {
      hasCachedData = true;
    }

    final cachedLikedPlaylist = await _repository.loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.likedCollection,
    );
    userLikedSongPlayList.value = cachedLikedPlaylist.isEmpty
        ? const PlaylistSummaryData(id: '', title: '')
        : cachedLikedPlaylist.first;
    if (userLikedSongPlayList.value.id.isNotEmpty) {
      hasCachedData = true;
    }

    final cachedTodaySongs = await _repository.loadCachedTrackList(
      userId: userId,
      kind: UserTrackListKind.dailyRecommend,
      likedSongIds: likedSongIds.toList(),
    );
    todayRecommendSongs
      ..clear()
      ..addAll(cachedTodaySongs);
    if (cachedTodaySongs.isNotEmpty) {
      hasCachedData = true;
    }

    final cachedFmSongs = await _repository.loadCachedTrackList(
      userId: userId,
      kind: UserTrackListKind.fm,
      likedSongIds: likedSongIds.toList(),
    );
    fmSongs
      ..clear()
      ..addAll(cachedFmSongs);
    if (cachedFmSongs.isNotEmpty) {
      hasCachedData = true;
    }

    await _refreshRandomLikedSong();
    if (randomLikedSongAlbumUrl.value.isNotEmpty) {
      hasCachedData = true;
    }
    _hasLocalSnapshot = hasCachedData;
  }

  Rx<UserSessionData> userInfo = const UserSessionData.empty().obs;
  List<PlaylistSummaryData> userPlayLists = <PlaylistSummaryData>[].obs;
  RxList<PlaylistSummaryData> recoPlayLists = <PlaylistSummaryData>[].obs;
  Rx<PlaylistSummaryData> userLikedSongPlayList =
      const PlaylistSummaryData(id: '', title: '').obs;
  RxList<int> likedSongIds = <int>[].obs;
  RxList<PlaybackQueueItem> likedSongs = <PlaybackQueueItem>[].obs;
  RxList<PlaybackQueueItem> todayRecommendSongs = <PlaybackQueueItem>[].obs;
  RxList<PlaybackQueueItem> fmSongs = <PlaybackQueueItem>[].obs;
  RxString randomLikedSongId = ''.obs;
  RxString randomLikedSongAlbumUrl = ''.obs;
  final List<ShellMenuItemData> leftMenus = [
    ShellMenuItemData('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    ShellMenuItemData(
        '推荐歌单', TablerIcons.smart_home, Routes.index, '/home/index'),
    ShellMenuItemData(
        '个性设置', TablerIcons.settings, Routes.setting, '/home/settingL'),
    ShellMenuItemData('捐赠', TablerIcons.coffee, Routes.coffee, ''),
  ];

  @override
  void onInit() {
    super.onInit();
    _cacheBootstrapFuture = _loadCache();
    ever(userInfo, (info) {
      if (info.isLoggedIn) {
        box.put(userInfoSp, jsonEncode(info.toJson()));
      } else {
        box.delete(userInfoSp);
      }
      if (_activeSnapshotUserId == info.userId) {
        return;
      }
      _activeSnapshotUserId = info.userId;
      unawaited(_loadScopedSnapshot(info.userId));
    });
  }

  Future<void> updateUserData() async {
    final userId = userInfo.value.userId;
    if (userId.isEmpty) {
      return;
    }
    await Future.wait([
      _updateUserPlayLists(),
      _updateQuickStartCardData(),
      updateRecoPlayLists(),
    ]);
    _hasLocalSnapshot = true;
    await _repository.markSyncMarkerUpdated(
      userId: userId,
      markerKey: _startupSyncMarker,
    );
  }

  Future<void> _updateQuickStartCardData() async {
    final userId = userInfo.value.userId.isEmpty ? '-1' : userInfo.value.userId;
    final nextLikedSongIds = await _repository.fetchLikedSongIds(
      userId,
    );
    likedSongIds
      ..clear()
      ..addAll(nextLikedSongIds);
    await _refreshRandomLikedSong();

    final nextTodayRecommendSongs = await getTodayRecommendSongs();
    todayRecommendSongs
      ..clear()
      ..addAll(nextTodayRecommendSongs);

    final nextFmSongs = await getFmSongs();
    fmSongs
      ..clear()
      ..addAll(nextFmSongs);
  }

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

  Future<void> updateRecoPlayLists({bool getMore = false}) async {
    final userId = userInfo.value.userId;
    if (userId.isEmpty || userId == "-1") return;
    final data = await _repository.fetchRecommendedPlaylists(
      userId: userId,
      offset: getMore ? recoPlayLists.length : 0,
    );
    if (!getMore) {
      recoPlayLists.clear();
    }
    recoPlayLists.addAll(data);
  }

  Future<void> _updateUserPlayLists() async {
    final userId = userInfo.value.userId;
    if (userId.isEmpty || userId == "-1") return;
    final playLists = await _repository.fetchUserPlaylists(userId);
    if (playLists.isNotEmpty) {
      final mutablePlayLists = [...playLists];
      final nextLikedPlaylist =
          mutablePlayLists.removeAt(0).copyWith(title: "我喜欢的音乐");
      userLikedSongPlayList.value = nextLikedPlaylist;
      userLikedSongPlayList.refresh();
      userPlayLists
        ..clear()
        ..addAll(mutablePlayLists);
    }
  }

  Future<void> toggleLikeStatus(PlaybackQueueItem curSong) async {
    final userId = userInfo.value.userId;
    final songId = _resolveSongSourceId(curSong);
    final numericSongId = int.tryParse(songId);
    if (userId.isEmpty || numericSongId == null) {
      return;
    }
    final isLiked = likedSongIds.contains(numericSongId);

    final serverStatusBean =
        await _repository.toggleLikeSong(userId, songId, !isLiked);
    if (serverStatusBean.success) {
      final updatedSong = curSong.copyWith(isLiked: !isLiked);
      await PlayerController.to.updatePlaybackQueueItem(updatedSong);

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
      await _refreshRandomLikedSong();
    }
  }

  Future<List<PlaybackQueueItem>> getTodayRecommendSongs() async {
    final userId = userInfo.value.userId;
    if (userId.isEmpty || userId == "-1") {
      return const [];
    }
    final todayRecommendSongs = await _repository.fetchTodayRecommendSongs(
      userId: userId,
      likedSongIds: likedSongIds.toList(),
    );
    return todayRecommendSongs;
  }

  Future<List<PlaybackQueueItem>> getFmSongs() async {
    final userId = userInfo.value.userId;
    if (userId.isEmpty || userId == "-1") {
      return const [];
    }
    return _repository.fetchFmSongs(
      userId: userId,
      likedSongIds: likedSongIds.toList(),
    );
  }

  Future<List<PlaybackQueueItem>> getHeartBeatSongs(
      String startSongId, String randomLikedSongId, bool fromPlayAll) async {
    return _repository.fetchHeartBeatSongs(
      startSongId: startSongId,
      randomLikedSongId: randomLikedSongId,
      fromPlayAll: fromPlayAll,
      likedSongIds: likedSongIds.toList(),
    );
  }

  Future<List<PlaybackQueueItem>> getSongsByIds(List<String> ids) async {
    return _repository.fetchSongsByIds(
      ids: ids,
      likedSongIds: likedSongIds.toList(),
    );
  }

  Future<String> getSongAlbumUrl(String songId) async {
    return _repository.fetchSongAlbumUrl(songId);
  }

  Future<void> clearUser() async {
    final value = await _repository.logout();
    if (value.success) {
      await _clearUserSnapshot();
      await SettingsController.to.updateLoginStatus(false);
    }
  }

  Future<void> expireLoginSession() async {
    await _clearUserSnapshot();
    await SettingsController.to.updateLoginStatus(false);
  }

  Future<void> _clearUserSnapshot() async {
    _activeSnapshotUserId = '';
    _hasLocalSnapshot = false;
    _clearScopedState();
    userInfo.value = const UserSessionData.empty();
    await box.delete(userInfoSp);
  }

  Future<void> _refreshRandomLikedSong() async {
    var nextRandomLikedSongId = '';
    var nextRandomLikedSongAlbumUrl = '';
    if (likedSongIds.isNotEmpty) {
      final randomIndex = Random().nextInt(likedSongIds.length);
      nextRandomLikedSongId = likedSongIds[randomIndex].toString();
      nextRandomLikedSongAlbumUrl =
          await _repository.loadCachedSongAlbumUrl(nextRandomLikedSongId);
      if (nextRandomLikedSongAlbumUrl.isEmpty) {
        nextRandomLikedSongAlbumUrl =
            await getSongAlbumUrl(nextRandomLikedSongId);
      }
    }
    randomLikedSongId.value = nextRandomLikedSongId;
    randomLikedSongAlbumUrl.value = nextRandomLikedSongAlbumUrl;
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
    todayRecommendSongs.clear();
    fmSongs.clear();
    recoPlayLists.clear();
    userPlayLists.clear();
    userLikedSongPlayList.value = const PlaylistSummaryData(id: '', title: '');
    randomLikedSongAlbumUrl.value = '';
    randomLikedSongId.value = '';
  }
}

class ShellMenuItemData {
  final String title;
  final IconData icon;
  final String route;
  final String path;

  ShellMenuItemData(this.title, this.icon, this.route, this.path);
}
