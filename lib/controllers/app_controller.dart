import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/lyric_parser/parser_lrc.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../common/bujuan_audio_handler.dart';
import '../common/lyric_parser/lyrics_reader_model.dart';
import '../routes/router.dart';
import '../routes/router.gr.dart' as gr;
import '../widget/custom_zoom_drawer/src/drawer_controller.dart';
import '../pages/home/body/app_body_page_view.dart';

/// 所有Controller都放在HomeController中统一控制
class AppController extends SuperController with GetTickerProviderStateMixin, WidgetsBindingObserver {
  static AppController get to => Get.find();

  // --- 无功能分类 ---
  Box box = GetIt.instance<Box>();
  late BuildContext buildContext;

  // --- 歌单存储 ---
  /// 用户创建的歌单
  List<PlayList> userMadePlayLists = <PlayList>[].obs;
  /// 用户收藏的歌单
  List<PlayList> userFavoritedPlayLists = <PlayList>[].obs;
  /// 推荐歌单
  RxList<PlayList> recoPlayLists = <PlayList>[].obs;

  // --- 首页快速播放卡片所需数据 ---
  RxBool dateLoaded = false.obs;
  RxList<MediaItem> fmSongs = <MediaItem>[].obs;
  RxList<MediaItem> todayRecommendSongs = <MediaItem>[].obs;
  // 用户喜欢的歌单
  RxList<int> likedSongIds = <int>[].obs;
  RxList<MediaItem> likedSongs = <MediaItem>[].obs;
  // 心动模式开始歌曲
  Rx<String> randomLikedSongAlbumUrl = ''.obs;
  Rx<String> randomLikedSongId = "".obs;

  // --- 用户信息 ---
  Rx<NeteaseAccountInfoWrap> userData = NeteaseAccountInfoWrap().obs;

  // --- APP 功能配置项 ---
  /// 是否渐变播放背景
  RxBool isGradientBackground = false.obs;
  /// 是否开启圆形专辑
  RxBool isRoundAlbumOpen = false.obs;
  /// 是否开启缓存
  RxBool isCacheOpen = false.obs;
  /// 是否开启高音质
  RxBool isHighSoundQualityOpen = false.obs;

  // --- 抽屉 ---
  /// Home页面侧滑抽屉
  late ZoomDrawerController zoomDrawerController;
  /// 侧边抽屉Beans   // TODO YU4422 待规范
  final List<LeftMenuBean> leftMenus = [
    LeftMenuBean('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    LeftMenuBean('推荐歌单', TablerIcons.smart_home, Routes.index, '/home/index'),
    // LeftMenuBean('本地歌曲', TablerIcons.file_music, Routes.local, '/home/local'),
    LeftMenuBean('个性设置', TablerIcons.settings, Routes.setting, '/home/settingL'),
    LeftMenuBean('捐赠', TablerIcons.coffee, Routes.coffee, ''),
  ];
  /// 抽屉开启状态
  RxBool isDrawerClosed = true.obs;
  /// 自动关闭抽屉倒计时（毫秒）
  double _timerCounter = 0.0;

  // --- Home页面PageView ---
  late PageController homePageController;
  bool isHomePageControllerInited = false;
  RxInt curHomePageIndex = 0.obs;
  RxString curHomePageTitle = "".obs;

  // --- 专辑封面 ---
  /// Home页面底部Panel中专辑封面的PageView
  late PageController albumPageController;
  RxBool isBigAlbum = true.obs;
  RxBool isAlbumScaleEnded = true.obs;
  bool isAlbumScrollingManully = false;
  bool isAlbumScrollingProgrammatic = false;
  RxBool isAlbumScrolling = false.obs;
  Rx<Color> albumColor = Colors.white.obs;
  Rx<Color> panelWidgetColor = Colors.white.obs;

  // --- 底部Panel ---
  PanelController bottomPanelController = PanelController();
  late AnimationController bottomPanelAnimationController;
  /// panel展开程度（0-1，1表示完全展开）
  RxBool bottomPanelFullyClosed = true.obs;
  RxBool bottomPanelOpened50 = false.obs;
  RxBool bottomPanelFullyOpened = false.obs;
  // --- Panel中的pageview ---
  late PageController bottomPanelPageController;
  RxInt curPanelPageIndex = 1.obs;
  // --- Panel中的tabview
  late TabController bottomPanelTabController;
  late TabController bottomPanelCommentTabController;
  // --- 正在播放列表 ---
  ScrollController playListScrollController = ScrollController();

  // --- 顶部Panel ---
  PanelController topPanelController = PanelController();
  late AnimationController topPanelAnimationController;
  late TextEditingController searchTextEditingController;
  RxBool topPanelFullyOpened = false.obs;
  RxBool topPanelFullyClosed = true.obs;
  RxString searchContent = ''.obs;
  final FocusNode searchFocusNode = FocusNode();
  RxDouble keyBoardHeight = 0.0.obs;

  // --- 歌词 ---
  ItemScrollController lyricScrollController = ItemScrollController();
  bool isLyricScrollingByUser = false;
  bool isLyricScrollingByItself = false;
  /// 自动关闭抽屉倒计时（毫秒）
  double _fullScreenLyricTimerCounter = 0.0;
  Timer? _fullScreenLyricTimer;
  RxBool isFullScreenLyricOpen = false.obs;

  // --- 播放器状态 ---
  late final AudioServiceHandler audioHandler;
  /// 播放状态
  RxBool isPlaying = false.obs;
  /// 循环方式
  Rx<AudioServiceRepeatMode> curRepeatMode = AudioServiceRepeatMode.all.obs;
  /// 漫游状态
  RxBool isFmMode = false.obs;
  /// 心动模式
  RxBool isHeartBeatMode = false.obs;
  /// 正在播放喜欢的音乐
  RxBool isPlayingLikedSongs = false.obs;
  /// 当前播放列表
  RxList<MediaItem> curPlayingSongs = <MediaItem>[].obs;
  RxString curPlayListName = "".obs;
  /// 当前播放歌曲
  Rx<MediaItem> curPlayingSong = const MediaItem(id: '', title: '暂无', duration: Duration(seconds: 10)).obs;
  /// 当前播放索引
  RxInt curPlayIndex = 0.obs;
  /// 当前播放进度
  Rx<Duration> curPlayDuration = Duration.zero.obs;
  // --- 歌词 ---
  /// 解析后的歌词数组
  RxList<LyricsLineModel> lyricsLineModels = <LyricsLineModel>[].obs;
  /// 是否有翻译歌词
  RxBool hasTransLyrics = false.obs;
  /// 当前歌词下标
  RxInt currLyricIndex = (-1).obs;
  
  @override
  Future<void> onInit() async {
    _initAppSetting();
    _initUIController();
    await updateUserState();

    WidgetsBinding.instance.addObserver(this);
    super.onInit();
  }
  _initAppSetting() {
    isCacheOpen.value = box.get(cacheSp, defaultValue: false);
    isGradientBackground.value = box.get(gradientBackgroundSp, defaultValue: true);
    isHighSoundQualityOpen.value = box.get(highSong, defaultValue: false);
    isRoundAlbumOpen.value = box.get(roundAlbumSp, defaultValue: false);
  }
  _initUIController() {
    zoomDrawerController = ZoomDrawerController();
    curHomePageTitle.value = userData.value.profile?.nickname ?? "";
    homePageController = PageController()..addListener(() {
      int updatedPageIndex = (homePageController.page! + 0.5).toInt();
      // 页面切换了
      if (updatedPageIndex != curHomePageIndex.value) {
        curHomePageIndex.value = updatedPageIndex;
        String title = "";
        // 更新appbar标题
        switch(updatedPageIndex)  {
          case 0:
            title = userData.value.profile?.nickname ?? "";
            break;
          case 1:
            title = "每日发现";
            break;
          case 2:
            title = "设置";
            break;
          case 3:
            title = "赞助开发者";
            break;
        }
        curHomePageTitle.value = title;

        // 启动倒计时器关闭抽屉
        _updateCloseDrawerTimer(3000);
      }
    });
    topPanelAnimationController = AnimationController(vsync: this);
    bottomPanelAnimationController = AnimationController(vsync: this);
    bottomPanelTabController = TabController(length: 3, initialIndex: 1, vsync: this)..addListener(() {
      if (bottomPanelTabController.indexIsChanging) {
        bottomPanelPageController.animateToPage(bottomPanelTabController.index, duration: const Duration(milliseconds: 300), curve: Curves.linear);
        if (bottomPanelTabController.index <= 1) {
          bottomPanelCommentTabController.index = 0;
          bottomPanelCommentTabController.offset = 0;
        }
      }
    });
    bottomPanelCommentTabController = TabController(length: 2, vsync: this)..addListener(() {
      if (bottomPanelCommentTabController.indexIsChanging) {
        bottomPanelPageController.animateToPage(bottomPanelCommentTabController.index + 2, duration: const Duration(milliseconds: 300), curve: Curves.linear);
      }
    });
    bottomPanelPageController = PageController(initialPage: 1)..addListener(() async {
      int newPanelPageIndex = (bottomPanelPageController.page! + 0.5).toInt();

      if (curPanelPageIndex.value != newPanelPageIndex) {
        curPanelPageIndex.value = newPanelPageIndex;
        // 切换到正在播放列表页，滚动到当前播放
        if (newPanelPageIndex == 0) await _animatePlayListToCurSong();
        if (isFullScreenLyricOpen.isFalse) {
          updateFullScreenLyricTimerCounter(cancelTimer: newPanelPageIndex != 1 && isFullScreenLyricOpen.isFalse);
        }
      }
      // 避免循环监听
      if (bottomPanelTabController.indexIsChanging || bottomPanelCommentTabController.indexIsChanging) return;
      // 控制tab显示
      if (bottomPanelPageController.page! <= 2) {
        bottomPanelTabController.index = newPanelPageIndex;
        bottomPanelTabController.offset = bottomPanelPageController.page! - newPanelPageIndex;
      } else {
        bottomPanelCommentTabController.index = newPanelPageIndex - 2;
        bottomPanelCommentTabController.offset = bottomPanelPageController.page! - newPanelPageIndex;
      }
    });
    albumPageController = PageController();
    searchTextEditingController = TextEditingController()..addListener(() {
      searchContent.value = searchTextEditingController.text;
    });
  }

  @override
  Future<void> onReady() async {
    // 初始化音频后台播放服务
    _initAudioHandler();

    // // 这个需要在UI构建后添加监听
    zoomDrawerController.addListener!((drawerOpenDegree) {
      //  抽屉状态改变
      if ((drawerOpenDegree == 0.0) != isDrawerClosed.value) {
        // 刷新抽屉状态
        isDrawerClosed.value = drawerOpenDegree == 0.0;
        if (!isDrawerClosed.value) {
          // 启动倒计时器关闭抽屉
          _updateCloseDrawerTimer(3000);
        } else {
          _updateCloseDrawerTimer(0);
        }
      }
    });

    updateData();

    super.onReady();
  }
  _initAudioHandler() async {
    audioHandler = await AudioService.init(
      builder: () => AudioServiceHandler(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.yu4422.purrr.channel.audio',
        androidNotificationChannelName: 'Music playback',
        androidNotificationIcon: 'drawable/audio_service_like',
      ),
    );
    // --- 初始化监听 ---

    // 监听播放列表切换
    audioHandler.queue.listen((mediaItems) async {
      curPlayingSongs
        ..clear()
        ..addAll(mediaItems);
      // 处理仅更新播放列表的情况，重新计算并更新curPlayIndex
      await _updateCurPlayIndex(curMediaItemUpdated: false);
    });
    // 监听歌曲切换
    audioHandler.mediaItem.listen((mediaItem) async {
      // 更新当前歌曲信息
      if (mediaItem == null) return;
      curPlayingSong.value = mediaItem;
      // 本地保存当前播放状态
      box.put(curPlaySongId, mediaItem.id);
      await _updateCurPlayIndex();

      // 漫游模式 播放到最后一首拉取新的FM歌曲列表
      int newIndex = curPlayingSongs.indexWhere((element) => element.id == curPlayingSong.value.id);
      if (isFmMode.isTrue && newIndex == curPlayingSongs.length - 1) {
        List<MediaItem> newFmPlayList = await getFmSongs();
        await audioHandler.changePlayList(newFmPlayList..insertAll(0, curPlayingSongs), index: curPlayIndex.value, playListName: "漫游模式", playNow: false, changePlayerSource: false);
      }
      // // TODO YU4422: 心动模式播放到最后一首策略待确定
    });
    // 监听播放状态变化
    audioHandler.playbackState.listen((playbackState) {
      isPlaying.value = playbackState.playing;
      updateFullScreenLyricTimerCounter(cancelTimer: isPlaying.isFalse);
      if(playbackState.processingState == AudioProcessingState.completed) audioHandler.skipToNext();
    });
    // 监听播放进度变化
    AudioService.createPositionStream(minPeriod: const Duration(microseconds: 800), steps: 1000).listen((newCurPlayingDuration) async {
      curPlayDuration.value = newCurPlayingDuration;
      // 找不到当前时间对应的歌词，此时newLyricIndex为-1，表示为前奏阶段，刚好显示空白
      int newLyricIndex = lyricsLineModels.lastIndexWhere((element) => element.startTime! <= newCurPlayingDuration.inMilliseconds);
      // print("lyricIndexUpdate: " + newLyricIndex.toString());
      if (newLyricIndex != currLyricIndex.value) {
        currLyricIndex.value = newLyricIndex;
        await _animateLyricToCurLyric();
      }
    });

    // --- 从本地恢复上次关闭播放状态 ---
    await audioHandler.restoreLastPlayState();
  }
  /// 监听歌单和歌曲变化时更新当前播放索引
  _updateCurPlayIndex({bool curMediaItemUpdated = true}) async {
    curPlayIndex.value = curPlayingSongs.indexWhere((element) => element.id == curPlayingSong.value.id);
    if (curMediaItemUpdated) {
      // 更新背景
      await _updateAlbumColor();
      // 更新歌词
      await _updateLyric();
    }
    // 专辑封面滚动到当前歌曲
    await _animateAlbumPageViewToCurSong();
    // 正在播放列表滚动到当前歌曲
    await _animatePlayListToCurSong();
  }

  updateData() async {
    await _updateUserPlayLists();
    await _updateQuickStartCardData();
    await updateRecoPlayLists();
    dateLoaded.value = true;

    likedSongs.addAll(await getSongsByIds(likedSongIds.map((id) => id.toString()).toList()));
  }

  _updateQuickStartCardData() async {
    todayRecommendSongs.addAll(await getTodayRecommendSongs());
    fmSongs.addAll(await getFmSongs());

    likedSongIds.clear();
    likedSongIds.addAll((await NeteaseMusicApi().likeSongList(userData.value.profile?.userId ?? '-1')).ids);
    
    _updateRandomLikedSong();
  }

  updateRecoPlayLists() async {
    List<PlayList> data;
    PersonalizedPlayListWrap personalizedPlayListWrap = await NeteaseMusicApi().personalizedPlaylist();
    data = personalizedPlayListWrap.result ?? [];
    recoPlayLists
      ..clear()
      ..addAll(data);
  }

  _updateRandomLikedSong() async {
    if (likedSongIds.isNotEmpty) {
      randomLikedSongId.value = likedSongIds[Random().nextInt(likedSongIds.length)].toString();
      randomLikedSongAlbumUrl.value = await _getSongAlbumUrl(randomLikedSongId.value);
    } else {
      randomLikedSongId.value = "";
      randomLikedSongAlbumUrl.value = "";
    }
  }

  _updateUserPlayLists() async {
    NeteaseMusicApi().userPlayLists(userData.value.profile?.userId ?? '-1').then((MultiPlayListWrap2 multiPlayListWrap2) async {
      List<PlayList> playLists = (multiPlayListWrap2.playlists ?? []);
      if (playLists.isNotEmpty) {
        userFavoritedPlayLists.clear();
        userMadePlayLists.clear();
        for(var playList in playLists) {
          if (playList.creator?.userId == userData.value.profile?.userId) {
            // 红心歌单重命名
            if(playList.name!.contains("${userData.value.profile?.nickname}喜欢的音乐")) {
              playList.name = "喜欢的音乐";
            }
            userMadePlayLists.add(playList);
          } else {
            userFavoritedPlayLists.add(playList);
          }
        }
      }
    });
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
    // WidgetUtil.showToast('onDetached');
  }
  @override
  void onInactive() {
    // TODO: implement onInactive
    // WidgetUtil.showToast('onInactive');
  }
  @override
  void onPaused() {
    // TODO: implement onPaused
    // WidgetUtil.showToast('onPaused');
  }
  @override
  void onResumed() {
    // WidgetUtil.showToast('onResumed');
  }
  @override
  void onHidden() {
    // TODO: implement onHidden
  }
  @override
  void didChangeMetrics() {
    // 监听窗口变化（包括键盘高度变化）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      keyBoardHeight.value = MediaQuery.of(buildContext).viewInsets.bottom;
    });
  }
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (bottomPanelFullyOpened.isTrue) return;
    // 状态栏颜色控制
    bool isDarkMode = buildContext.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  // --- 歌曲控制 ---
  /// 获取当前循环icon
  IconData getRepeatIcon() {
    IconData icon;
    if(isFmMode.value) {
      icon = TablerIcons.radio;
    } else if(isHeartBeatMode.value) {
      icon = TablerIcons.heartbeat;
    }else {
      switch (curRepeatMode.value) {
        case AudioServiceRepeatMode.one:
          icon = TablerIcons.repeat_once;
          break;
        case AudioServiceRepeatMode.none:
          icon = TablerIcons.arrows_shuffle;
          break;
        case AudioServiceRepeatMode.all:
        case AudioServiceRepeatMode.group:
          icon = TablerIcons.repeat;
          break;
      }
    }
    return icon;
  }
  /// 打开漫游模式
  openFmMode() async {
    bottomPanelPageController.jumpToPage(1);
    bottomPanelController.open();
    if(isFmMode.isTrue) {
      // 处于FM模式，恢复播放
      if (isPlaying.isFalse) await playOrPause();
    } else {
      if (isHeartBeatMode.isTrue) quitHeartBeatMode(showToast: false);
      // 保存FM开启状态
      isFmMode.value = true;
      box.put(fmSp, true);
      await audioHandler.changePlayList(fmSongs, playListName: "漫游模式", changePlayerSource: true, playNow: true);
      WidgetUtil.showToast('漫游模式已开启');
    }
  }

  quitFmMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出漫游模式');
    isFmMode.value = false;
    box.put(fmSp, false);
    fmSongs..clear()..addAll(await getFmSongs());
  }
  /// 打开心动模式
  openHeartBeatMode(String startSongId, bool fromPlayAll) async {
    // fromPlayAll == true，通过首页打开
    // fromPlayAll == false，通过切换播放模式打开（正在播放喜欢的歌单）。
    if (startSongId.isEmpty) {
      WidgetUtil.showToast('心动模式开启失败');
      return;
    }

    if (isHeartBeatMode.isTrue) {
      bottomPanelPageController.jumpToPage(1);
      bottomPanelController.open();
      if (isPlaying.isFalse) await playOrPause();
    } else {
      //  获取心动歌曲
      List<MediaItem> playList = await getHeartBeatSongs(startSongId, fromPlayAll);
      if (playList.isEmpty) {
        WidgetUtil.showToast('心动模式开启失败');
        return;
      } else {
        // 在心动歌曲列表头部添加起始歌曲
        MediaItem startSong = isPlayingLikedSongs.isTrue ? curPlayingSong.value : likedSongs.firstWhere((mediaItem) => mediaItem.id == startSongId);
        playList.insert(0, startSong);

        await audioHandler.changePlayList(playList, index: 0, playListName: "心动模式", changePlayerSource: fromPlayAll, playNow: fromPlayAll);
        // 开启成功，更新心动模式开启状态
        if (isFmMode.isTrue) quitFmMode(showToast: false);
        bottomPanelPageController.jumpToPage(1);
        bottomPanelController.open();
        isHeartBeatMode.value = true;
        box.put(heartBeatSp, true);
        WidgetUtil.showToast('心动模式已开启');
      }

    }
  }
  quitHeartBeatMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出心动模式');
    isHeartBeatMode.value = false;
    box.put(heartBeatSp, false);
    _updateRandomLikedSong();
  }
  /// 播放/暂停
  playOrPause() async {
    isPlaying.value
        ? await audioHandler.pause()
        : await audioHandler.play();
  }
  /// 喜欢歌曲
  toggleLikeStatus() async {
    bool isLiked = likedSongIds.contains(int.parse(curPlayingSong.value.id));

    NeteaseMusicApi().likeSong(curPlayingSong.value.id, !isLiked).then((serverStatusBean) async {
      if (serverStatusBean.code == 200) {
        // 修改状态栏
        await audioHandler.updateMediaItem(curPlayingSong.value..extras?['liked'] = !isLiked);
        // 修改喜欢列表
        isLiked
            ? likedSongIds.remove(int.parse(curPlayingSong.value.id))
            : likedSongIds.add(int.parse(curPlayingSong.value.id));

      } else {
        print("serverStatusBean.msg: ${serverStatusBean.msg}");
      }
    });
  }
  /// 根据下标播放歌曲
  playNewPlayList(List<MediaItem> playList, int index, {String playListName = "无名歌单"}) async {
    // 切歌单退出漫游模式、心动模式
    if (isFmMode.isTrue) quitFmMode();
    if (isHeartBeatMode.isTrue) quitHeartBeatMode();
    await audioHandler.changePlayList(playList, index: index, playListName: playListName, changePlayerSource: true, playNow: true);
  }

  playUserLikedSongs() async {
    int playIndex;
    List<MediaItem> playList = [...likedSongs];
    // 正在播放红心歌曲
    if (likedSongIds.contains(int.parse(curPlayingSong.value.id))){
      playIndex = likedSongs.indexWhere((song) => song.id == curPlayingSong.value.id);
    // 正在播放非红心歌曲
    } else {
      playIndex = 0;
      playList.insert(0, curPlayingSong.value);
    }
    await audioHandler.changePlayList(playList, index: playIndex, playListName: "喜欢的音乐", changePlayerSource: false, playNow: false);
  }

  /// 添加/删除歌曲到指定的歌单
  addOrDelSongToPlaylist(String playlistId, String songId, bool add) async {
    NeteaseMusicApi().playlistManipulateTracks(playlistId, songId, add);
  }

  /// 改变panel位置
  onBottomPanelSlide(double openDegree) {
    bottomPanelAnimationController.value = openDegree;

    // 如果当前的状态改变
    if (bottomPanelFullyClosed.value != (openDegree == 0.0)){
      // 更新状态
      bottomPanelFullyClosed.value = (openDegree == 0.0);
    }
    if (bottomPanelOpened50.value != (openDegree > 0.5)) {
      bottomPanelOpened50.value = openDegree > 0.5;
    }
    if (bottomPanelFullyOpened.value != (openDegree == 1.0)){
      // 更新状态
      bottomPanelFullyOpened.value = (openDegree == 1.0);
      // 打开Panel时在正在播放列表页，滚动到当前播放
      if (curPanelPageIndex.value == 0) {
        _animatePlayListToCurSong();
      }

    }

  }

  /// 改变panel位置
  onTopPanelSlide(double openDegree) {
    topPanelAnimationController.value = openDegree;

    if (topPanelFullyClosed.value != (openDegree == 0.0)){
      topPanelFullyClosed.value = (openDegree == 0.0);
    }
    if (topPanelFullyOpened.value != (openDegree == 1.0)){
      topPanelFullyOpened.value = (openDegree == 1.0);
      if (topPanelFullyOpened.isTrue) {
        if (searchContent.isEmpty) searchFocusNode.requestFocus();
      } else {
        searchFocusNode.unfocus();
      }
    }

  }

  /// 当按下返回键
  onWillPop() {
    if (topPanelController.isPanelOpen) {
      topPanelController.close();
      return;
    }
    if (bottomPanelController.isPanelOpen) {
      bottomPanelController.close();
      return;
    }
    if (zoomDrawerController.isOpen!()) {
      zoomDrawerController.close!();
      return;
    }
    if (homePageController.page != 0) {
      homePageController.animateToPage(0, duration: Duration(milliseconds: 100 * (homePageController.page)!.toInt()), curve: Curves.linear);
    } else {
      SystemNavigator.pop();
    }
  }
  List<MediaItem> song2ToMedia(List<Song2> songs) {
    return songs
        .where((e) => e.id.isNotEmpty) // Filter out songs with empty id
        .map((e) => MediaItem(
        id: e.id,
        duration: Duration(milliseconds: e.dt ?? 0),
        artUri: Uri.parse('${e.al?.picUrl ?? ''}?param=500y500'),
        extras: {
          'type': MediaType.playlist.name,
          'image': e.al?.picUrl ?? '',
          'liked': likedSongIds.contains(int.tryParse(e.id)),
          'artist': (e.ar ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / '),
          'albumId': e.al?.id ?? '',
          'mv': e.mv,
          'fee': e.fee
        },
        title: e.name ?? "",
        album: e.al?.name,
        artist: (e.ar ?? []).map((e) => e.name).toList().join(' / ')))
        .toList();
  }

  _updateCloseDrawerTimer(double timeValue) {
    if (_timerCounter == 0) {
      _timerCounter = timeValue;
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        _timerCounter -= 50;
        if (_timerCounter <= 0) {
          _timerCounter = 0;
          timer.cancel();
          if (zoomDrawerController.isOpen!()) {
            zoomDrawerController.close!();
          }
        }
      });
    } else {
      _timerCounter = timeValue;
    }
  }

  updateFullScreenLyricTimerCounter({bool cancelTimer = false}) {
    // 无操作5s，进入沉浸式歌词
    double closeTime = 5000;
    if (cancelTimer){
      _fullScreenLyricTimerCounter = 0;
      if(_fullScreenLyricTimer != null) _fullScreenLyricTimer!.cancel();
      isFullScreenLyricOpen.value = false;
    } else if (isPlaying.isTrue){
      if (_fullScreenLyricTimer == null || !_fullScreenLyricTimer!.isActive) {
        // 启动倒计时
        _fullScreenLyricTimerCounter = closeTime;
        _fullScreenLyricTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          _fullScreenLyricTimerCounter -= 50;
          // 倒计时结束
          if (_fullScreenLyricTimerCounter <= 0) {
            _fullScreenLyricTimerCounter = 0;
            timer.cancel();
            isFullScreenLyricOpen.value = true;
          }
        });
      } else {
        _fullScreenLyricTimerCounter = closeTime;
      }
    }
  }

  cancelFullScreenLyricTimerCounter(){

  }



  /// 更新歌词
  _updateLyric() async {
    // 歌词清空
    lyricsLineModels.clear();
    hasTransLyrics.value = false;

    // 更新歌词
    String songId = curPlayingSong.value.id;
    // 先从本地获取歌词
    String lyric = box.get('lyric_$songId') ?? '';
    String lyricTran = box.get('lyricTran_$songId') ?? '';
    // 本地为空则从网络获取，并缓存
    if (lyric.isEmpty) {
      SongLyricWrap songLyricWrap = await NeteaseMusicApi().songLyric(curPlayingSong.value.id);
      lyric = songLyricWrap.lrc.lyric ?? "";
      lyricTran = songLyricWrap.tlyric.lyric ?? "";
      box.put('lyric_$songId', lyric);
      box.put('lyricTran_$songId', lyricTran);
    }
    // 解析歌词
    if (lyric.isNotEmpty) {
      var mainLyricsLineModels = ParserLrc(lyric).parseLines();
      if (lyricTran.isNotEmpty) {
        hasTransLyrics.value = true;
        var extLyricsLineModels = ParserLrc(lyricTran).parseLines();
        for(LyricsLineModel lyricsLineModel in extLyricsLineModels) {
          int index = mainLyricsLineModels.indexWhere((element) => element.startTime == lyricsLineModel.startTime);
          mainLyricsLineModels[index].extText = lyricsLineModel.mainText;
        }
      }
      lyricsLineModels.addAll(mainLyricsLineModels);
    } else {
      lyricsLineModels.add(LyricsLineModel()..mainText = "没歌词哦～"..startTime = 0);
    }

    // 歌词复位
    currLyricIndex.value = -1;
    await _animateLyricToCurLyric();
  }
  /// 获取专辑颜色
  _updateAlbumColor() async {
    albumColor.value = await OtherUtils.getImageColor(curPlayingSong.value.extras?['image']);
    panelWidgetColor.value = albumColor.value.invertedColor;
  }
  _animateLyricToCurLyric() async {
    // 首尾添加栏空白行，避免滚动到空白行，index需要 +1 修正
    // currLyricIndex.value == -1 表示为前奏，滚动到第一行歌词
    int lyricListViewIndex = 1 + (currLyricIndex.value == -1 ? 0 : currLyricIndex.value);
    // 滚动到当前歌词
    if (!isLyricScrollingByUser) {
      isLyricScrollingByItself = true;
      lyricListViewIndex == 1
          ? lyricScrollController.jumpTo(index: lyricListViewIndex, alignment: 0.4)
          : await lyricScrollController.scrollTo(
              index: lyricListViewIndex,
              alignment: 0.4,
              duration: const Duration(milliseconds: 500),
              curve: Curves.decelerate
          );
    }
  }

  /// 滚动播放列表到当前播放歌曲
  _animatePlayListToCurSong() async {
    if (!playListScrollController.hasClients) return;
    await playListScrollController.animateTo(55.0 * curPlayIndex.value, duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }
  _animateAlbumPageViewToCurSong() async {
    if (!albumPageController.hasClients || isAlbumScrollingManully || curPlayIndex.value == albumPageController.page!.toInt()) return;
    isAlbumScrollingProgrammatic = true;
    bool isNearBy = (curPlayIndex.value - albumPageController.page!.toInt()).abs() <= 1;
    if (isNearBy && bottomPanelFullyOpened.isTrue) {
      await albumPageController.animateToPage(curPlayIndex.value , duration: const Duration(milliseconds: 300), curve: Curves.linear);
    } else {
      albumPageController.jumpToPage(curPlayIndex.value );
    }
  }

  /// 获取每日推荐歌曲
  Future<List<MediaItem>> getTodayRecommendSongs() async {
    List<MediaItem> todayRecommendSongs;
    RecommendSongListWrapX recommendSongListWrapX = await NeteaseMusicApi().recommendSongList();
    if (recommendSongListWrapX.code == 200) {
      todayRecommendSongs = song2ToMedia((recommendSongListWrapX.data.dailySongs ?? []));
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
      fmSongs = (songListWrap2.data ?? []).map((e) => MediaItem(
          id: e.id,
          duration: Duration(milliseconds: e.duration ?? 0),
          artUri: Uri.parse('${e.album?.picUrl ?? ''}?param=500y500'),
          extras: {
            'image': e.album?.picUrl ?? '',
            'liked': likedSongIds.contains(int.tryParse(e.id)),
            'artist': (e.artists ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / '),
            'albumId': e.album?.id ?? '',
            'type': MediaType.fm.name,
            'size': ''
          },
          title: e.name ?? "",
          album: e.album?.name ?? '',
          artist: (e.artists ?? []).map((e) => e.name).toList().join(' / ')
      )).toList();
    } else {
      fmSongs = [];
    }
    return fmSongs;
  }

  /// 获取心动模式歌曲
  Future<List<MediaItem>> getHeartBeatSongs(String startSongId, bool fromPlayAll) async {
    List<MediaItem> heartBeatSongs;
    PlaymodeIntelligenceListWrap playmodeIntelligenceListWrap = await NeteaseMusicApi().playmodeIntelligenceList(
      startSongId,
      randomLikedSongId.value,
      fromPlayAll,
      count: 20,
    );
    if (playmodeIntelligenceListWrap.code == 200) {
      // Filter out null songInfo and ensure Song2 objects have valid id
      List<Song2> validSongs = (playmodeIntelligenceListWrap.data ?? [])
          .where((e) => e.songInfo != null && e.songInfo!.id.isNotEmpty)
          .map((e) => e.songInfo!)
          .toList();
      heartBeatSongs = song2ToMedia(validSongs);
    } else {
      heartBeatSongs = [];
    }
    return heartBeatSongs;
  }

  /// 获取漫游模式歌曲
  Future<List<MediaItem>> getSongsByIds(List<String> ids) async {
    List<MediaItem> songs = <MediaItem>[];
    int loadedSongCount = 0;
    while(loadedSongCount != ids.length) {
      songs.addAll(song2ToMedia((await NeteaseMusicApi().songDetail(ids.sublist(loadedSongCount, min(loadedSongCount + 1000, ids.length)))).songs ?? []));
      loadedSongCount = songs.length;
    }
    return songs;
  }

  Future<String> _getSongAlbumUrl(String songId) async {
    SongDetailWrap songDetailWrap = await NeteaseMusicApi().songDetail([songId]);
    return "${song2ToMedia(songDetailWrap.songs ?? [])[0].extras?['image'] ?? ''}?param=500y500";
  }

  /// 更新用户登录信息
  updateUserState() async {
    try {
      NeteaseAccountInfoWrap neteaseAccountInfoWrap = await NeteaseMusicApi().loginAccountInfo();
      if (neteaseAccountInfoWrap.code == 200 && neteaseAccountInfoWrap.profile != null) {

        userData.value = neteaseAccountInfoWrap;
        // loginStatus.value = LoginStatus.login;
        box.put(loginData, jsonEncode(neteaseAccountInfoWrap.toJson()));

      } else {
        WidgetUtil.showToast('登录失效,请重新登录');
        buildContext.router.push(gr.LoginRouteView());

        // loginStatus.value = LoginStatus.noLogin;
      }
    } catch (e) {
      // loginStatus.value = LoginStatus.noLogin;
      WidgetUtil.showToast('获取用户资料失败，请检查网络');
    }
  }
  clearUser() {
    NeteaseMusicApi().logout().then((value) {
      if (value.code != 200) {
        WidgetUtil.showToast(value.message ?? '');
        return;
      }
      box.put(loginData, '');
      // loginStatus.value = LoginStatus.noLogin;
    });
  }

}

