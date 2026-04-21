import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/playback/audio_service_handler.dart';
import 'package:bujuan/core/storage/cache_timestamp_store.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_data.dart';
import 'package:bujuan/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:math';

/// 收口账号相关的本地缓存、用户资料和快捷入口数据。
///
/// 当前仍保留少量 `Hive` 读写，是因为这些数据还没有完全迁入正式本地库，
/// 先集中在这里比继续散落到页面里更容易替换。
class UserController extends GetxController {
  static const Duration _startupDataTtl = Duration(minutes: 10);

  static UserController get to => Get.find();
  final Box box = GetIt.instance<Box>();
  final UserRepository _repository = UserRepository();
  final CacheTimestampStore _timestampStore = const CacheTimestampStore();
  bool _hasLocalSnapshot = false;

  bool get hasLocalSnapshot => _hasLocalSnapshot;
  bool get shouldRefreshStartupData {
    if (!_hasLocalSnapshot) {
      return true;
    }
    return !_timestampStore.isFresh(
      userStartupLastRefreshSp,
      ttl: _startupDataTtl,
    );
  }

  void _loadCache() {
    var hasCachedData = false;
    String? userInfoStr = box.get(userInfoSp);
    if (userInfoStr != null) {
      userInfo.value = UserSessionData.fromJson(jsonDecode(userInfoStr));
      hasCachedData = true;
    }

    List<dynamic>? cachedLikedIds = box.get(likedSongIdsSp);
    if (cachedLikedIds != null) {
      likedSongIds.addAll(cachedLikedIds.cast<int>());
      hasCachedData = true;
    }

    List<dynamic>? cachedReco = box.get(recoPlayListsSp);
    if (cachedReco != null && recoPlayLists.isEmpty) {
      recoPlayLists.addAll(
        cachedReco
            .map((e) => PlaylistSummaryData.fromJson(jsonDecode(e)))
            .toList(),
      );
      hasCachedData = true;
    }

    List<dynamic>? cachedUserPlayLists = box.get(userPlayListsSp);
    if (cachedUserPlayLists != null && userPlayLists.isEmpty) {
      userPlayLists.addAll(cachedUserPlayLists
          .map((e) => PlaylistSummaryData.fromJson(jsonDecode(e)))
          .toList());
      hasCachedData = true;
    }

    String? likedPlStr = box.get(userLikedSongPlayListSp);
    if (likedPlStr != null) {
      userLikedSongPlayList.value =
          PlaylistSummaryData.fromJson(jsonDecode(likedPlStr));
      hasCachedData = true;
    }

    List<String>? cachedTodaySongs =
        box.get(todayRecommendSongsSp)?.cast<String>();
    if (cachedTodaySongs != null && todayRecommendSongs.isEmpty) {
      stringToPlayList(cachedTodaySongs).then((list) {
        todayRecommendSongs.addAll(list);
      });
      hasCachedData = true;
    }

    List<String>? cachedFmSongs = box.get(fmSongsSp)?.cast<String>();
    if (cachedFmSongs != null && fmSongs.isEmpty) {
      stringToPlayList(cachedFmSongs).then((list) {
        fmSongs.addAll(list);
      });
      hasCachedData = true;
    }

    randomLikedSongId.value = box.get(randomLikedSongIdSp, defaultValue: '');
    if (randomLikedSongId.value.isNotEmpty) {
      hasCachedData = true;
    }

    randomLikedSongAlbumUrl.value =
        box.get(randomLikedSongAlbumUrlSp, defaultValue: '');
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
  RxList<MediaItem> likedSongs = <MediaItem>[].obs;
  RxList<MediaItem> todayRecommendSongs = <MediaItem>[].obs;
  RxList<MediaItem> fmSongs = <MediaItem>[].obs;
  RxString randomLikedSongId = ''.obs;
  RxString randomLikedSongAlbumUrl = ''.obs;
  final List<LeftMenuBean> leftMenus = [
    LeftMenuBean('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    LeftMenuBean('推荐歌单', TablerIcons.smart_home, Routes.index, '/home/index'),
    LeftMenuBean(
        '个性设置', TablerIcons.settings, Routes.setting, '/home/settingL'),
    LeftMenuBean('捐赠', TablerIcons.coffee, Routes.coffee, ''),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCache();
    ever(userInfo, (info) {
      if (info.isLoggedIn) {
        box.put(userInfoSp, jsonEncode(info.toJson()));
      }
    });
  }

  Future<void> updateUserData() async {
    await _updateUserPlayLists();
    await _updateQuickStartCardData();
    await updateRecoPlayLists();
    _hasLocalSnapshot = true;
    await _timestampStore.markUpdated(userStartupLastRefreshSp);
  }

  Future<void> _updateQuickStartCardData() async {
    final nextLikedSongIds = await _repository.fetchLikedSongIds(
      userInfo.value.userId.isEmpty ? '-1' : userInfo.value.userId,
    );
    likedSongIds
      ..clear()
      ..addAll(nextLikedSongIds);
    box.put(likedSongIdsSp, likedSongIds.toList());

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
    box.put(randomLikedSongIdSp, randomLikedSongId.value);
    box.put(randomLikedSongAlbumUrlSp, randomLikedSongAlbumUrl.value);

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
    final data = await _repository.fetchRecommendedPlaylists(
      offset: getMore ? recoPlayLists.length : 0,
    );
    if (!getMore) {
      recoPlayLists.clear();
    }
    recoPlayLists.addAll(data);
    if (!getMore && data.isNotEmpty) {
      box.put(
        recoPlayListsSp,
        data.map((e) => jsonEncode(e.toJson())).toList(),
      );
    }
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
      box.put(
        userPlayListsSp,
        mutablePlayLists.map((e) => jsonEncode(e.toJson())).toList(),
      );
      box.put(
        userLikedSongPlayListSp,
        jsonEncode(userLikedSongPlayList.value.toJson()),
      );
    }
  }

  Future<void> toggleLikeStatus(MediaItem curSong) async {
    bool isLiked = likedSongIds.contains(int.parse(curSong.id));

    final serverStatusBean =
        await _repository.toggleLikeSong(curSong.id, !isLiked);
    if (serverStatusBean.success) {
      await PlayerController.to.playbackService
          .updateMediaItem(curSong..extras?['liked'] = !isLiked);

      if (isLiked) {
        likedSongIds.remove(int.parse(curSong.id));
      } else {
        likedSongIds.add(int.parse(curSong.id));
      }
    }
  }

  Future<List<MediaItem>> getTodayRecommendSongs() async {
    final todayRecommendSongs = await _repository.fetchTodayRecommendSongs(
      likedSongIds: likedSongIds.toList(),
    );
    if (todayRecommendSongs.isNotEmpty) {
      playListToString(todayRecommendSongs).then((list) {
        box.put(todayRecommendSongsSp, list);
      });
    }
    return todayRecommendSongs;
  }

  Future<List<MediaItem>> getFmSongs() async {
    final songs =
        await _repository.fetchFmSongs(likedSongIds: likedSongIds.toList());
    if (songs.isNotEmpty) {
      playListToString(songs).then((list) {
        box.put(fmSongsSp, list);
      });
    }
    return songs;
  }

  Future<List<MediaItem>> getHeartBeatSongs(
      String startSongId, String randomLikedSongId, bool fromPlayAll) async {
    return _repository.fetchHeartBeatSongs(
      startSongId: startSongId,
      randomLikedSongId: randomLikedSongId,
      fromPlayAll: fromPlayAll,
      likedSongIds: likedSongIds.toList(),
    );
  }

  Future<List<MediaItem>> getSongsByIds(List<String> ids) async {
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
    _hasLocalSnapshot = false;
    likedSongIds.clear();
    likedSongs.clear();
    todayRecommendSongs.clear();
    fmSongs.clear();
    recoPlayLists.clear();
    userPlayLists.clear();
    userLikedSongPlayList.value = const PlaylistSummaryData(id: '', title: '');
    randomLikedSongAlbumUrl.value = '';
    randomLikedSongId.value = '';
    userInfo.value = const UserSessionData.empty();
    await _repository.clearCachedProfiles();
    final keys = [
      userInfoSp,
      likedSongIdsSp,
      recoPlayListsSp,
      userPlayListsSp,
      userLikedSongPlayListSp,
      todayRecommendSongsSp,
      fmSongsSp,
      randomLikedSongIdSp,
      randomLikedSongAlbumUrlSp,
      userStartupLastRefreshSp,
    ];
    for (final key in keys) {
      await box.delete(key);
    }
  }
}

class LeftMenuBean {
  final String title;
  final IconData icon;
  final String route;
  final String path;

  LeftMenuBean(this.title, this.icon, this.route, this.path);
}
