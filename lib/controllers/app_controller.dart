import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bujuan/controllers/player_controller.dart';
import 'package:bujuan/controllers/settings_controller.dart';
import 'package:bujuan/controllers/user_controller.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/features/playlist/repository/playlist_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../common/bujuan_audio_handler.dart';
import '../widget/custom_zoom_drawer/src/drawer_controller.dart';

/// 所有Controller都放在HomeController中统一控制
///
/// **代理 Getters 以保持向后兼容**
class AppController extends SuperController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  static AppController get to => Get.find();
  final PlaylistRepository _playlistRepository = PlaylistRepository();

  // --- 注入新的 Controllers ---
  late final SettingsController settingsController;
  late final UserController userController;
  late final PlayerController playerController;

  // Proxy for Box (fix for setting_page.dart)
  Box get box => settingsController.box;

  // Proxy for clearUser
  clearUser() => userController.clearUser();

  // --- 代理 Getters (为了兼容旧代码) ---
  // Settings
  RxBool get isGradientBackground => settingsController.isGradientBackground;
  RxBool get isRoundAlbumOpen => settingsController.isRoundAlbumOpen;
  RxBool get isCacheOpen => settingsController.isCacheOpen;
  RxBool get isHighSoundQualityOpen =>
      settingsController.isHighSoundQualityOpen;
  Rx<Color> get albumColor => settingsController.albumColor;
  Rx<Color> get panelWidgetColor => settingsController.panelWidgetColor;

  // User
  Rx<NeteaseAccountInfoWrap> get userInfo => userController.userInfo;
  List<PlayList> get userPlayLists => userController.userPlayLists;
  RxList<PlayList> get recoPlayLists => userController.recoPlayLists;
  Rx<PlayList> get userLikedSongPlayList =>
      userController.userLikedSongPlayList;
  RxList<int> get likedSongIds => userController.likedSongIds;
  RxList<MediaItem> get likedSongs => userController.likedSongs;
  RxList<MediaItem> get fmSongs => userController.fmSongs;
  RxList<MediaItem> get todayRecommendSongs =>
      userController.todayRecommendSongs;

  // Player
  RxBool get isPlaying => playerController.isPlaying;
  Rx<AudioServiceRepeatMode> get curRepeatMode =>
      playerController.curRepeatMode;
  RxBool get isFmMode => playerController.isFmMode;
  RxBool get isHeartBeatMode => playerController.isHeartBeatMode;
  RxBool get isPlayingLikedSongs => playerController.isPlayingLikedSongs;
  RxList<MediaItem> get curPlayingSongs => playerController.curPlayingSongs;
  RxString get curPlayListName => playerController.curPlayListName;
  RxString get curPlayListNameHeader => playerController.curPlayListNameHeader;
  Rx<MediaItem> get curPlayingSong => playerController.curPlayingSong;
  RxInt get curPlayIndex => playerController.curPlayIndex;
  Rx<Duration> get curPlayDuration => playerController.curPlayDuration;
  RxList<LyricsLineModel> get lyricsLineModels =>
      playerController.lyricsLineModels;
  RxBool get hasTransLyrics => playerController.hasTransLyrics;
  RxInt get currLyricIndex => playerController.currLyricIndex;
  RxBool get isFullScreenLyricOpen => playerController.isFullScreenLyricOpen;
  AudioServiceHandler get audioHandler => playerController.audioHandler;

  // --- 无功能分类 ---
  late BuildContext buildContext;

  // --- 首页快速播放卡片所需数据 ---
  RxBool dateLoaded = false.obs;

  // 心动模式开始歌曲 (这些变量需要在适当的时候重构到 Controllers 中，暂时保留在此处做中转或State)
  RxString get randomLikedSongAlbumUrl =>
      userController.randomLikedSongAlbumUrl;
  RxString get randomLikedSongId => userController.randomLikedSongId;

  // 首页刷新
  RefreshController refreshController = RefreshController();

  // --- 抽屉 (UI Logic - Keep here) ---
  /// Home页面侧滑抽屉
  late ZoomDrawerController zoomDrawerController;

  /// 侧边抽屉Beans
  List<LeftMenuBean> get leftMenus => userController.leftMenus;

  /// 抽屉开启状态
  RxBool isDrawerClosed = true.obs;

  /// 自动关闭抽屉倒计时（毫秒）
  double _timerCounter = 0.0;

  // --- Home页面PageView (UI Logic - Keep here) ---
  late PageController homePageController;
  bool isHomePageControllerInited = false;
  RxInt curHomePageIndex = 0.obs;
  RxString curHomePageTitle = "".obs;

  // --- 专辑封面 (UI Logic - Keep here) ---
  /// Home页面底部Panel中专辑封面的PageView
  late PageController albumPageController;
  RxBool isBigAlbum = true.obs;
  RxBool isAlbumScaleEnded = true.obs;
  bool isAlbumScrollingManully = false;
  bool isAlbumScrollingProgrammatic = false;
  RxBool isAlbumScrolling = false.obs;

  // --- 底部Panel (UI Logic - Keep here) ---
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

  // --- 顶部Panel (UI Logic - Keep here) ---
  PanelController topPanelController = PanelController();
  late AnimationController topPanelAnimationController;
  late TextEditingController searchTextEditingController;
  RxBool topPanelFullyOpened = false.obs;
  RxBool topPanelFullyClosed = true.obs;
  RxString searchContent = ''.obs;
  final FocusNode searchFocusNode = FocusNode();
  RxDouble keyBoardHeight = 0.0.obs;

  // --- 歌词 (UI Scroll Logic - Keep here) ---
  ItemScrollController lyricScrollController = ItemScrollController();
  bool isLyricScrollingByUser = false;
  bool isLyricScrollingByItself = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    // 注入依赖
    settingsController = Get.put(SettingsController());
    userController = Get.put(UserController());
    playerController = Get.put(PlayerController());

    // UI 初始化
    _initUIController();
    WidgetsBinding.instance.addObserver(this);

    // 监听歌词索引变化以驱动滚动
    ever(currLyricIndex, (index) {
      if (index >= 0 &&
          !isLyricScrollingByUser &&
          lyricScrollController.isAttached) {
        // 这里需要 try-catch 或者简单的延时，或者是确保 scrollController 已附着
        try {
          lyricScrollController.scrollTo(
              index: index, duration: const Duration(milliseconds: 300));
        } catch (e) {
          // ignore
        }
      }
    });

    // 监听播放列表索引变化以驱动 UI 滚动
    ever(curPlayIndex, (index) {
      _animatePlayListToCurSong();
      _animateAlbumPageViewToCurSong();
    });
  }

  // Debounce timer for album swipe
  Timer? _albumDebounceTimer;

  // Debounced album page change handler
  void onAlbumPageChanged(int index) {
    if (isAlbumScrollingProgrammatic) return;
    _albumDebounceTimer?.cancel();
    _albumDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (curPlayIndex.value != index) {
        audioHandler.playIndex(audioSourceIndex: index, playNow: true);
      }
    });
  }

  _initUIController() {
    zoomDrawerController = ZoomDrawerController();
    curHomePageTitle.value = userInfo.value.profile?.nickname ?? "";
    homePageController = PageController()
      ..addListener(() {
        int updatedPageIndex = (homePageController.page! + 0.5).toInt();
        // 页面切换了
        if (updatedPageIndex != curHomePageIndex.value) {
          curHomePageIndex.value = updatedPageIndex;
          String title = "";
          // 更新appbar标题
          switch (updatedPageIndex) {
            case 0:
              title = userInfo.value.profile?.nickname ?? "";
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
    bottomPanelTabController =
        TabController(length: 3, initialIndex: 1, vsync: this)
          ..addListener(() {
            if (bottomPanelTabController.indexIsChanging) {
              bottomPanelPageController.animateToPage(
                  bottomPanelTabController.index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear);
              if (bottomPanelTabController.index <= 1) {
                bottomPanelCommentTabController.index = 0;
                bottomPanelCommentTabController.offset = 0;
              }
            }
          });
    bottomPanelCommentTabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (bottomPanelCommentTabController.indexIsChanging) {
          bottomPanelPageController.animateToPage(
              bottomPanelCommentTabController.index + 2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        }
      });
    bottomPanelPageController = PageController(initialPage: 1)
      ..addListener(() async {
        int newPanelPageIndex = (bottomPanelPageController.page! + 0.5).toInt();

        if (curPanelPageIndex.value != newPanelPageIndex) {
          curPanelPageIndex.value = newPanelPageIndex;
          // 切换到正在播放列表页，滚动到当前播放
          if (newPanelPageIndex == 0) await _animatePlayListToCurSong();
          if (isFullScreenLyricOpen.isFalse) {
            playerController.updateFullScreenLyricTimerCounter(
                cancelTimer:
                    newPanelPageIndex != 1 && isFullScreenLyricOpen.isFalse);
          }
        }
        // 避免循环监听
        if (bottomPanelTabController.indexIsChanging ||
            bottomPanelCommentTabController.indexIsChanging) {
          return;
        }
        // 控制tab显示
        if (bottomPanelPageController.page! <= 2) {
          bottomPanelTabController.index = newPanelPageIndex;
          bottomPanelTabController.offset =
              bottomPanelPageController.page! - newPanelPageIndex;
        } else {
          bottomPanelCommentTabController.index = newPanelPageIndex - 2;
          bottomPanelCommentTabController.offset =
              bottomPanelPageController.page! - newPanelPageIndex;
        }
      });
    albumPageController = PageController();
    searchTextEditingController = TextEditingController()
      ..addListener(() {
        searchContent.value = searchTextEditingController.text;
      });
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    // 触发数据加载
    updateData();
  }

  initZoomDrawerListener() async {
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
  }

  updateData() async {
    // 代理调用 UserController
    await userController.updateUserData();
    dateLoaded.value = true;

    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  updateRecoPlayLists({bool getMore = false}) async {
    await userController.updateRecoPlayLists(getMore: getMore);
    NeteaseMusicApi().playlistCatalogue();
    refreshController.loadComplete();
  }

  @override
  void onDetached() {}
  @override
  void onInactive() {}
  @override
  void onPaused() {}
  @override
  void onResumed() {}
  @override
  void onHidden() {}
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
      systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.dark : Brightness.light,
      statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  // --- 歌曲控制 ---
  /// 获取当前循环icon
  IconData getRepeatIcon() => playerController.getRepeatIcon();

  /// 打开漫游模式
  openFmMode() async {
    bottomPanelPageController.jumpToPage(1);
    bottomPanelController.open();
    // 代理逻辑
    await playerController.switchMode(PlaybackMode.roaming);
  }

  quitFmMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出漫游模式');
    // playerController.isFmMode.value = false; // logic handled by switchMode now
    // Potentially switch back to default playlist mode or just leave as is but unset FM flag
    if (playerController.playbackMode.value == PlaybackMode.roaming) {
      playerController.playbackMode.value = PlaybackMode.playlist;
    }
  }

  /// 打开心动模式
  openHeartBeatMode(String startSongId, bool fromPlayAll) async {
    if (startSongId.isEmpty) {
      return;
    }
    bottomPanelPageController.jumpToPage(1);
    bottomPanelController.open();

    await playerController.switchMode(PlaybackMode.heartbeat,
        contextData: {'startSongId': startSongId, 'fromPlayAll': fromPlayAll});
  }

  quitHeartBeatMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出心动模式');
    if (playerController.playbackMode.value == PlaybackMode.heartbeat) {
      playerController.playbackMode.value = PlaybackMode.playlist;
    }
  }

  /// 播放/暂停
  playOrPause() => playerController.playOrPause();

  /// 喜欢歌曲
  toggleLikeStatus() => userController.toggleLikeStatus(curPlayingSong.value);

  playNewPlayList(List<MediaItem> playList, int index,
      {String playListName = "无名歌单", String playListNameHeader = ""}) async {
    if (isFmMode.isTrue) quitFmMode();
    if (isHeartBeatMode.isTrue) quitHeartBeatMode();
    await audioHandler.changePlayList(playList,
        index: index,
        playListName: playListName,
        playListNameHeader: playListNameHeader,
        changePlayerSource: true,
        playNow: true);
  }

  playNewPlayListById(String playListId) async {
    SinglePlayListWrap details =
        await _playlistRepository.fetchPlaylistWrap(playListId);
    List<MediaItem> songs =
        await getPlayListSongs("", singlePlayListWrap: details);
    playNewPlayList(songs, 0,
        playListName: details.playlist?.name ?? "无名歌单",
        playListNameHeader: "歌单");
  }

  Future<List<MediaItem>> getPlayListSongs(String playListId,
      {SinglePlayListWrap? singlePlayListWrap,
      int offset = 0,
      int limit = -1}) async {
    return _playlistRepository.fetchPlaylistSongs(
      playlistId: playListId,
      likedSongIds: likedSongIds.toList(),
      offset: offset,
      limit: limit,
      playlistWrap: singlePlayListWrap,
    );
  }

  playUserLikedSongs() async {
    int playIndex;
    List<MediaItem> playList = [...likedSongs];
    // 正在播放红心歌曲
    if (likedSongIds.contains(int.parse(curPlayingSong.value.id))) {
      playIndex =
          likedSongs.indexWhere((song) => song.id == curPlayingSong.value.id);
      // 正在播放非红心歌曲
    } else {
      playIndex = 0;
      playList.insert(0, curPlayingSong.value);
    }
    await audioHandler.changePlayList(playList,
        index: playIndex,
        playListName: "喜欢的音乐",
        changePlayerSource: false,
        playNow: false);
  }

  addOrDelSongToPlaylist(String playlistId, String songId, bool add) async {
    _playlistRepository.manipulateTracks(playlistId, songId, add: add);
  }

  onBottomPanelSlide(double openDegree) {
    bottomPanelAnimationController.value = openDegree;

    if (bottomPanelFullyClosed.value != (openDegree == 0.0)) {
      bottomPanelFullyClosed.value = (openDegree == 0.0);
    }
    if (bottomPanelOpened50.value != (openDegree > 0.5)) {
      bottomPanelOpened50.value = openDegree > 0.5;
    }
    if (bottomPanelFullyOpened.value != (openDegree == 1.0)) {
      bottomPanelFullyOpened.value = (openDegree == 1.0);
      if (curPanelPageIndex.value == 0) {
        _animatePlayListToCurSong();
      }
    }
  }

  onTopPanelSlide(double openDegree) {
    topPanelAnimationController.value = openDegree;

    if (topPanelFullyClosed.value != (openDegree == 0.0)) {
      topPanelFullyClosed.value = (openDegree == 0.0);
    }
    if (topPanelFullyOpened.value != (openDegree == 1.0)) {
      topPanelFullyOpened.value = (openDegree == 1.0);
      if (topPanelFullyOpened.isTrue) {
        if (searchContent.isEmpty) searchFocusNode.requestFocus();
      } else {
        searchFocusNode.unfocus();
      }
    }
  }

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
      homePageController.animateToPage(0,
          duration:
              Duration(milliseconds: 100 * (homePageController.page)!.toInt()),
          curve: Curves.linear);
    } else {
      SystemNavigator.pop();
    }
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
    playerController.updateFullScreenLyricTimerCounter(
        cancelTimer: cancelTimer);
  }

  cancelFullScreenLyricTimerCounter() {}

  _animatePlayListToCurSong() {
    if (playListScrollController.hasClients) {
      double offset = curPlayIndex.value * 55.0;
      playListScrollController.animateTo(offset,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  syncAlbumPage() => _animateAlbumPageViewToCurSong();

  _animateAlbumPageViewToCurSong() {
    if (albumPageController.hasClients) {
      if (isAlbumScrollingManully) return;
      double currentPage = albumPageController.page ?? 0;
      if ((currentPage - curPlayIndex.value).abs() < 0.01) return;

      isAlbumScrollingProgrammatic = true;
      albumPageController.animateToPage(curPlayIndex.value,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  List<MediaItem> song2ToMedia(List<Song2> songs) =>
      playerController.song2ToMedia(songs);
}
