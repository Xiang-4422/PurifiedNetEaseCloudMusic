import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/core/playback/audio_service_handler.dart';
import 'package:bujuan/features/playback/controller/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
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
  static UserController get to => Get.find();
  final Box box = GetIt.instance<Box>();
  final UserRepository _repository = UserRepository();

  void _loadCache() {
    String? userInfoStr = box.get(userInfoSp);
    if (userInfoStr != null) {
      userInfo.value = NeteaseAccountInfoWrap.fromJson(jsonDecode(userInfoStr));
    }

    List<dynamic>? cachedLikedIds = box.get(likedSongIdsSp);
    if (cachedLikedIds != null) {
      likedSongIds.addAll(cachedLikedIds.cast<int>());
    }

    List<dynamic>? cachedReco = box.get(recoPlayListsSp);
    if (cachedReco != null && recoPlayLists.isEmpty) {
      recoPlayLists.addAll(
          cachedReco.map((e) => PlayList.fromJson(jsonDecode(e))).toList());
    }

    List<dynamic>? cachedUserPlayLists = box.get(userPlayListsSp);
    if (cachedUserPlayLists != null && userPlayLists.isEmpty) {
      userPlayLists.addAll(cachedUserPlayLists
          .map((e) => PlayList.fromJson(jsonDecode(e)))
          .toList());
    }

    String? likedPlStr = box.get(userLikedSongPlayListSp);
    if (likedPlStr != null) {
      userLikedSongPlayList.value = PlayList.fromJson(jsonDecode(likedPlStr));
    }

    List<String>? cachedTodaySongs =
        box.get(todayRecommendSongsSp)?.cast<String>();
    if (cachedTodaySongs != null && todayRecommendSongs.isEmpty) {
      stringToPlayList(cachedTodaySongs).then((list) {
        todayRecommendSongs.addAll(list);
      });
    }

    randomLikedSongAlbumUrl.value =
        box.get(randomLikedSongAlbumUrlSp, defaultValue: '');
  }

  Rx<NeteaseAccountInfoWrap> userInfo = NeteaseAccountInfoWrap().obs;
  List<PlayList> userPlayLists = <PlayList>[].obs;
  RxList<PlayList> recoPlayLists = <PlayList>[].obs;
  Rx<PlayList> userLikedSongPlayList = PlayList().obs;
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
      if (info.profile != null) {
        box.put(userInfoSp, jsonEncode(info.toJson()));
      }
    });
  }

  Future<void> updateUserData() async {
    await _updateUserPlayLists();
    await _updateQuickStartCardData();
    await updateRecoPlayLists();

    if (likedSongIds.isNotEmpty) {
      likedSongs.clear();
      likedSongs.addAll(
          await getSongsByIds(likedSongIds.map((e) => e.toString()).toList()));
    }
  }

  Future<void> _updateQuickStartCardData() async {
    todayRecommendSongs.clear();
    todayRecommendSongs.addAll(await getTodayRecommendSongs());

    fmSongs.clear();
    fmSongs.addAll(await getFmSongs());

    likedSongIds.clear();
    likedSongIds.addAll(
      await _repository
          .fetchLikedSongIds(userInfo.value.profile?.userId ?? '-1'),
    );
    box.put(likedSongIdsSp, likedSongIds.toList());

    if (likedSongIds.isNotEmpty) {
      int randomIndex = Random().nextInt(likedSongIds.length);
      randomLikedSongId.value = likedSongIds[randomIndex].toString();
      randomLikedSongAlbumUrl.value =
          await getSongAlbumUrl(randomLikedSongId.value);
      box.put(randomLikedSongAlbumUrlSp, randomLikedSongAlbumUrl.value);
    }
  }

  Future<void> updateRecoPlayLists({bool getMore = false}) async {
    final data = await _repository.fetchRecommendedPlaylists(
      offset: getMore ? recoPlayLists.length : 0,
    );
    if (!getMore) recoPlayLists.clear();
    recoPlayLists.addAll(data);
    if (!getMore && data.isNotEmpty) {
      box.put(
          recoPlayListsSp, data.map((e) => jsonEncode(e.toJson())).toList());
    }
  }

  Future<void> _updateUserPlayLists() async {
    String? userId = userInfo.value.profile?.userId;
    if (userId == null || userId == "-1") return;
    final playLists = await _repository.fetchUserPlaylists(userId);
    if (playLists.isNotEmpty) {
      final mutablePlayLists = [...playLists];
      userLikedSongPlayList.value = mutablePlayLists.removeAt(0);
      userLikedSongPlayList.value.name = "我喜欢的音乐";
      userLikedSongPlayList.refresh();
      userPlayLists.clear();
      userPlayLists.addAll(mutablePlayLists);
      box.put(userPlayListsSp,
          mutablePlayLists.map((e) => jsonEncode(e.toJson())).toList());
      box.put(userLikedSongPlayListSp,
          jsonEncode(userLikedSongPlayList.value.toJson()));
    }
  }

  Future<void> toggleLikeStatus(MediaItem curSong) async {
    bool isLiked = likedSongIds.contains(int.parse(curSong.id));

    final serverStatusBean =
        await _repository.toggleLikeSong(curSong.id, !isLiked);
    if (serverStatusBean.code == 200) {
      PlayerController.to.audioHandler
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
    return _repository.fetchFmSongs(likedSongIds: likedSongIds.toList());
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
    if (value.code == 200) {
      await SettingsController.to.updateLoginStatus(false);
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
