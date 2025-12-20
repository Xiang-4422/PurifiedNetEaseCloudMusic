import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/controllers/settings_controller.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:bujuan/routes/router.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bujuan/common/bujuan_audio_handler.dart';

import 'player_controller.dart';

/// 用户控制器
/// 负责管理用户信息、歌单、红心歌曲状态
class UserController extends GetxController {
  static UserController get to => Get.find();
  final Box box = GetIt.instance<Box>();

  void _loadCache() {
    // 加载缓存的用户信息
    String? userInfoStr = box.get(userInfoSp);
    if (userInfoStr != null) {
      userInfo.value = NeteaseAccountInfoWrap.fromJson(jsonDecode(userInfoStr));
    }

    // 加载缓存的红心歌曲 ID
    List<dynamic>? cachedLikedIds = box.get(likedSongIdsSp);
    if (cachedLikedIds != null) {
      likedSongIds.addAll(cachedLikedIds.cast<int>());
    }

    // 加载缓存的推荐歌单
    List<dynamic>? cachedReco = box.get(recoPlayListsSp);
    if (cachedReco != null && recoPlayLists.isEmpty) {
      recoPlayLists.addAll(
          cachedReco.map((e) => PlayList.fromJson(jsonDecode(e))).toList());
    }

    // 加载缓存的用户歌单
    List<dynamic>? cachedUserPlayLists = box.get(userPlayListsSp);
    if (cachedUserPlayLists != null && userPlayLists.isEmpty) {
      userPlayLists.addAll(cachedUserPlayLists
          .map((e) => PlayList.fromJson(jsonDecode(e)))
          .toList());
    }

    // 加载缓存的我的喜欢歌单
    String? likedPlStr = box.get(userLikedSongPlayListSp);
    if (likedPlStr != null) {
      userLikedSongPlayList.value = PlayList.fromJson(jsonDecode(likedPlStr));
    }

    // 加载缓存的日推歌曲
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

  /// 用户信息
  Rx<NeteaseAccountInfoWrap> userInfo = NeteaseAccountInfoWrap().obs;

  /// 用户歌单
  List<PlayList> userPlayLists = <PlayList>[].obs;

  /// 推荐歌单
  RxList<PlayList> recoPlayLists = <PlayList>[].obs;

  /// 用户喜欢的歌单（红心歌单）
  Rx<PlayList> userLikedSongPlayList = PlayList().obs;

  /// 喜欢歌曲的ID列表
  RxList<int> likedSongIds = <int>[].obs;

  /// 喜欢歌曲的详细列表
  RxList<MediaItem> likedSongs = <MediaItem>[].obs;

  /// 每日推荐歌曲
  RxList<MediaItem> todayRecommendSongs = <MediaItem>[].obs;

  /// 私人FM歌曲
  RxList<MediaItem> fmSongs = <MediaItem>[].obs;

  /// 随机红心歌曲ID (用于心动模式入口)
  RxString randomLikedSongId = ''.obs;

  /// 随机红心歌曲封面 (用于心动模式入口)
  RxString randomLikedSongAlbumUrl = ''.obs;

  /// 侧边菜单列表
  final List<LeftMenuBean> leftMenus = [
    LeftMenuBean('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    LeftMenuBean('推荐歌单', TablerIcons.smart_home, Routes.index, '/home/index'),
    // LeftMenuBean('本地歌曲', TablerIcons.file_music, Routes.local, '/home/local'),
    LeftMenuBean(
        '个性设置', TablerIcons.settings, Routes.setting, '/home/settingL'),
    LeftMenuBean('捐赠', TablerIcons.coffee, Routes.coffee, ''),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCache();
    // 监听用户信息变化并缓存
    ever(userInfo, (info) {
      if (info.profile != null) {
        box.put(userInfoSp, jsonEncode(info.toJson()));
      }
    });
  }

  /// 更新用户数据
  Future<void> updateUserData() async {
    await _updateUserPlayLists();
    await _updateQuickStartCardData();
    await updateRecoPlayLists();

    // 获取喜欢歌曲的详细信息
    if (likedSongIds.isNotEmpty) {
      likedSongs.clear();
      // 获取歌曲详情
      likedSongs.addAll(
          await getSongsByIds(likedSongIds.map((e) => e.toString()).toList()));
    }
  }

  /// 获取首页快速启动卡片数据
  Future<void> _updateQuickStartCardData() async {
    // 获取日推
    todayRecommendSongs.clear();
    todayRecommendSongs.addAll(await getTodayRecommendSongs());

    // 获取FM
    fmSongs.clear();
    fmSongs.addAll(await getFmSongs());

    likedSongIds.clear();
    var likedList = await NeteaseMusicApi()
        .likeSongList(userInfo.value.profile?.userId ?? '-1');
    likedSongIds.addAll(likedList.ids);
    box.put(likedSongIdsSp, likedSongIds.toList());

    // 更新随机心动歌曲
    if (likedSongIds.isNotEmpty) {
      int randomIndex = Random().nextInt(likedSongIds.length);
      randomLikedSongId.value = likedSongIds[randomIndex].toString();
      randomLikedSongAlbumUrl.value =
          await getSongAlbumUrl(randomLikedSongId.value);
      box.put(randomLikedSongAlbumUrlSp, randomLikedSongAlbumUrl.value);
    }
  }

  /// 更新推荐歌单
  Future<void> updateRecoPlayLists({bool getMore = false}) async {
    List<PlayList> data;
    PersonalizedPlayListWrap personalizedPlayListWrap = await NeteaseMusicApi()
        .personalizedPlaylist(
            offset: getMore ? recoPlayLists.length : 0, limit: 10);
    data = personalizedPlayListWrap.result ?? [];
    if (!getMore) recoPlayLists.clear();
    recoPlayLists.addAll(data);
    // 缓存推荐歌单
    if (!getMore && data.isNotEmpty) {
      box.put(
          recoPlayListsSp, data.map((e) => jsonEncode(e.toJson())).toList());
    }
  }

  /// 更新用户歌单
  Future<void> _updateUserPlayLists() async {
    String? userId = userInfo.value.profile?.userId;
    if (userId == null || userId == "-1") return;
    await NeteaseMusicApi()
        .userPlayLists(userId)
        .then((MultiPlayListWrap2 multiPlayListWrap2) async {
      List<PlayList> playLists = (multiPlayListWrap2.playlists ?? []);
      if (playLists.isNotEmpty) {
        userLikedSongPlayList.value = playLists.removeAt(0);
        userLikedSongPlayList.value.name = "我喜欢的音乐";
        userLikedSongPlayList.refresh(); // 确保 UI 更新
        userPlayLists.clear();
        userPlayLists.addAll(playLists);
        // 缓存
        box.put(userPlayListsSp,
            playLists.map((e) => jsonEncode(e.toJson())).toList());
        box.put(userLikedSongPlayListSp,
            jsonEncode(userLikedSongPlayList.value.toJson()));
      }
    });
  }

  /// 切换喜欢状态
  Future<void> toggleLikeStatus(MediaItem curSong) async {
    bool isLiked = likedSongIds.contains(int.parse(curSong.id));

    await NeteaseMusicApi()
        .likeSong(curSong.id, !isLiked)
        .then((serverStatusBean) async {
      if (serverStatusBean.code == 200) {
        // 修改状态栏 (需要通知 PlayerController 更新当前歌曲状态)
        PlayerController.to.audioHandler
            .updateMediaItem(curSong..extras?['liked'] = !isLiked);

        // 修改喜欢列表
        if (isLiked) {
          likedSongIds.remove(int.parse(curSong.id));
        } else {
          likedSongIds.add(int.parse(curSong.id));
        }
      } else {
        print("serverStatusBean.msg: ${serverStatusBean.msg}");
      }
    });
  }

  /// 获取每日推荐歌曲
  Future<List<MediaItem>> getTodayRecommendSongs() async {
    List<MediaItem> todayRecommendSongs;
    RecommendSongListWrapX recommendSongListWrapX =
        await NeteaseMusicApi().recommendSongList();
    if (recommendSongListWrapX.code == 200) {
      todayRecommendSongs = PlayerController.to
          .song2ToMedia((recommendSongListWrapX.data.dailySongs ?? []));
      // 缓存日推
      playListToString(todayRecommendSongs).then((list) {
        box.put(todayRecommendSongsSp, list);
      });
    } else {
      todayRecommendSongs = [];
    }
    return todayRecommendSongs;
  }

  /// 获取漫游模式歌曲
  Future<List<MediaItem>> getFmSongs() async {
    List<MediaItem> fmSongs;
    SongListWrap2 songListWrap2 = await NeteaseMusicApi().userRadio();
    if (songListWrap2.code == 200) {
      fmSongs = (songListWrap2.data ?? [])
          .map((e) => MediaItem(
              id: e.id,
              duration: Duration(milliseconds: e.duration ?? 0),
              artUri: Uri.parse('${e.album?.picUrl ?? ''}?param=200y200'),
              extras: {
                'image': e.album?.picUrl ?? '',
                'liked': likedSongIds.contains(int.tryParse(e.id)),
                'artist': (e.artists ?? [])
                    .map((e) => jsonEncode(e.toJson()))
                    .toList()
                    .join(' / '),
                'albumId': e.album?.id ?? '',
                'type': MediaType.fm.name,
                'size': ''
              },
              title: e.name ?? "",
              album: e.album?.name ?? '',
              artist:
                  (e.artists ?? []).map((e) => e.name).toList().join(' / ')))
          .toList();
    } else {
      fmSongs = [];
    }
    return fmSongs;
  }

  /// 获取心动模式歌曲
  Future<List<MediaItem>> getHeartBeatSongs(
      String startSongId, String randomLikedSongId, bool fromPlayAll) async {
    List<MediaItem> heartBeatSongs;
    PlaymodeIntelligenceListWrap playmodeIntelligenceListWrap =
        await NeteaseMusicApi().playmodeIntelligenceList(
      startSongId,
      randomLikedSongId,
      fromPlayAll,
      count: 20,
    );
    if (playmodeIntelligenceListWrap.code == 200) {
      // Filter out null songInfo and ensure Song2 objects have valid id
      List<Song2> validSongs = (playmodeIntelligenceListWrap.data ?? [])
          .where((e) => e.songInfo != null && e.songInfo!.id.isNotEmpty)
          .map((e) => e.songInfo!)
          .toList();
      heartBeatSongs = PlayerController.to.song2ToMedia(validSongs);
    } else {
      heartBeatSongs = [];
    }
    return heartBeatSongs;
  }

  /// 根据ID获取歌曲详情
  Future<List<MediaItem>> getSongsByIds(List<String> ids) async {
    List<MediaItem> songs = <MediaItem>[];
    int loadedSongCount = 0;
    while (loadedSongCount != ids.length) {
      songs.addAll(PlayerController.to.song2ToMedia((await NeteaseMusicApi()
                  .songDetail(ids.sublist(loadedSongCount,
                      min(loadedSongCount + 1000, ids.length))))
              .songs ??
          []));
      loadedSongCount = songs.length;
    }
    return songs;
  }

  /// 获取歌曲封面Url
  Future<String> getSongAlbumUrl(String songId) async {
    SongDetailWrap songDetailWrap =
        await NeteaseMusicApi().songDetail([songId]);
    var songs = songDetailWrap.songs ?? [];
    if (songs.isNotEmpty) {
      return "${PlayerController.to.song2ToMedia(songs)[0].extras?['image'] ?? ''}?param=500y500";
    }
    return '';
  }

  /// 退出登录
  clearUser() {
    NeteaseMusicApi().logout().then((value) {
      if (value.code == 200) {
        SettingsController.to.box.put(isLoginSP, false);
      } else {
        // WidgetUtil.showToast(value.message ?? ''); // Commented out as WidgetUtil is not defined in this context
      }
    });
  }
}

/// 侧边菜单实体类
class LeftMenuBean {
  final String title;
  final IconData icon;
  final String route;
  final String path;

  LeftMenuBean(this.title, this.icon, this.route, this.path);
}
