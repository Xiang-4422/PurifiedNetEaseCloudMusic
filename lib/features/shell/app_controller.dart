import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';
import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/user/user_controller.dart';
import 'package:bujuan/features/user/user_session_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:bujuan/widget/custom_zoom_drawer/src/drawer_controller.dart';

/// 迁移期的应用壳层协调器。
///
/// 这里仍保留大量代理 getter 和少量跨页面 UI 协调，是为了先把旧页面
/// 从“各自管理全局状态”收回到单点入口，再逐步下沉到更细的 feature controller。
class AppController extends SuperController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  static AppController get to => Get.find();
  HomeShellController get shellController =>
      Get.isRegistered<HomeShellController>()
          ? Get.find<HomeShellController>()
          : Get.put(HomeShellController());

  SettingsController get settingsController =>
      Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>()
          : Get.put(SettingsController());
  UserController get userController => Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());
  PlayerController get playerController => Get.isRegistered<PlayerController>()
      ? Get.find<PlayerController>()
      : Get.put(PlayerController());

  RxBool get isGradientBackground => settingsController.isGradientBackground;
  RxBool get isRoundAlbumOpen => settingsController.isRoundAlbumOpen;
  RxBool get isHighSoundQualityOpen =>
      settingsController.isHighSoundQualityOpen;
  RxBool get isOfflineModeEnabled => settingsController.isOfflineModeEnabled;
  Rx<Color> get albumColor => settingsController.albumColor;
  Rx<Color> get panelWidgetColor => settingsController.panelWidgetColor;

  Rx<UserSessionData> get userInfo => userController.userInfo;
  List<PlaylistSummaryData> get userPlayLists => userController.userPlayLists;
  RxList<PlaylistSummaryData> get recoPlayLists => userController.recoPlayLists;
  Rx<PlaylistSummaryData> get userLikedSongPlayList =>
      userController.userLikedSongPlayList;
  RxList<int> get likedSongIds => userController.likedSongIds;
  RxList<MediaItem> get likedSongs => userController.likedSongs;
  RxList<MediaItem> get fmSongs => userController.fmSongs;
  RxList<MediaItem> get todayRecommendSongs =>
      userController.todayRecommendSongs;

  RxBool get isPlaying => playerController.isPlaying;
  Rx<PlaybackSessionState> get playbackSessionState =>
      playerController.sessionState;
  Rx<PlaybackRuntimeState> get playbackRuntimeState =>
      playerController.runtimeState;
  Rx<MediaItem> get currentSong => playerController.currentSongState;
  Rx<Duration> get currentPosition => playerController.currentPositionState;
  RxList<MediaItem> get playbackQueue => playerController.queueState;
  RxInt get playbackQueueIndex => playerController.currentQueueIndex;
  Rx<PlaybackLyricState> get playbackLyricState => playerController.lyricState;
  Rx<AudioServiceRepeatMode> get curRepeatMode =>
      playerController.curRepeatMode;
  RxBool get isFmMode => playerController.isFmMode;
  RxBool get isHeartBeatMode => playerController.isHeartBeatMode;
  RxBool get isFullScreenLyricOpen => playerController.isFullScreenLyricOpen;
  PlaybackService get playbackService => playerController.playbackService;

  late BuildContext buildContext;

  RxBool dateLoaded = false.obs;

  RxString get randomLikedSongAlbumUrl =>
      userController.randomLikedSongAlbumUrl;
  RxString get randomLikedSongId => userController.randomLikedSongId;

  RefreshController refreshController = RefreshController();

  List<LeftMenuBean> get leftMenus => userController.leftMenus;
  ZoomDrawerController get zoomDrawerController =>
      shellController.zoomDrawerController;
  RxBool get isDrawerClosed => shellController.isDrawerClosed;
  PageController get homePageController => shellController.homePageController;
  RxInt get curHomePageIndex => shellController.curHomePageIndex;
  RxString get curHomePageTitle => shellController.curHomePageTitle;

  bool _uiControllersInitialized = false;
  PageController? _albumPageController;
  RxBool isBigAlbum = true.obs;
  RxBool isAlbumScaleEnded = true.obs;
  bool isAlbumScrollingManully = false;
  bool isAlbumScrollingProgrammatic = false;
  RxBool isAlbumScrolling = false.obs;
  Timer? _homeImageColorPrewarmTimer;

  PanelController bottomPanelController = PanelController();
  AnimationController? _bottomPanelAnimationController;
  RxBool bottomPanelFullyClosed = true.obs;
  RxBool bottomPanelOpened50 = false.obs;
  RxBool bottomPanelFullyOpened = false.obs;
  PageController? _bottomPanelPageController;
  RxInt curPanelPageIndex = 1.obs;
  TabController? _bottomPanelTabController;
  TabController? _bottomPanelCommentTabController;
  ScrollController playListScrollController = ScrollController();

  PageController get albumPageController {
    _ensureUiControllersInitialized();
    return _albumPageController!;
  }

  AnimationController get bottomPanelAnimationController {
    _ensureUiControllersInitialized();
    return _bottomPanelAnimationController!;
  }

  PageController get bottomPanelPageController {
    _ensureUiControllersInitialized();
    return _bottomPanelPageController!;
  }

  void jumpBottomPanelToPage(int page) {
    _ensureUiControllersInitialized();
    final controller = _bottomPanelPageController;
    if (controller != null && controller.hasClients) {
      controller.jumpToPage(page);
    }
  }

  Future<void> animateBottomPanelToPage(
    int page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
  }) async {
    _ensureUiControllersInitialized();
    final controller = _bottomPanelPageController;
    if (controller != null && controller.hasClients) {
      await controller.animateToPage(
        page,
        duration: duration,
        curve: curve,
      );
    }
  }

  Future<void> openBottomPanel() async {
    if (bottomPanelController.isAttached) {
      await bottomPanelController.open();
    }
  }

  Future<void> closeBottomPanel() async {
    if (bottomPanelController.isAttached) {
      await bottomPanelController.close();
    }
  }

  Future<void> openTopPanel() async {
    if (topPanelController.isAttached) {
      await topPanelController.open();
    }
  }

  Future<void> closeTopPanel() async {
    if (topPanelController.isAttached) {
      await topPanelController.close();
    }
  }

  TabController get bottomPanelTabController {
    _ensureUiControllersInitialized();
    return _bottomPanelTabController!;
  }

  TabController get bottomPanelCommentTabController {
    _ensureUiControllersInitialized();
    return _bottomPanelCommentTabController!;
  }

  PanelController get topPanelController => shellController.topPanelController;
  AnimationController get topPanelAnimationController =>
      shellController.topPanelAnimationController;
  TextEditingController get searchTextEditingController =>
      shellController.searchTextEditingController;
  RxBool get topPanelFullyOpened => shellController.topPanelFullyOpened;
  RxBool get topPanelFullyClosed => shellController.topPanelFullyClosed;
  RxString get searchContent => shellController.searchContent;
  FocusNode get searchFocusNode => shellController.searchFocusNode;
  RxDouble get keyBoardHeight => shellController.keyBoardHeight;

  ItemScrollController lyricScrollController = ItemScrollController();
  bool isLyricScrollingByUser = false;
  bool isLyricScrollingByItself = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    shellController;
    settingsController;
    userController;
    playerController;

    _ensureUiControllersInitialized();
    WidgetsBinding.instance.addObserver(this);

    ever(playbackLyricState, (lyricState) {
      final index = lyricState.currentIndex;
      if (index >= 0 &&
          !isLyricScrollingByUser &&
          lyricScrollController.isAttached) {
        try {
          lyricScrollController.scrollTo(
              index: index, duration: const Duration(milliseconds: 300));
        } catch (e) {
          // 歌词滚动失败只会影响跟随体验，不能反过来打断播放状态更新。
        }
      }
    });

    ever<int>(playbackQueueIndex, (currentIndex) {
      if (currentIndex < 0) {
        return;
      }
      _animatePlayListToCurSong();
      _animateAlbumPageViewToCurSong();
    });
    ever<List<MediaItem>>(todayRecommendSongs, (_) {
      _scheduleHomeImageColorPrewarm();
    });
    ever<List<MediaItem>>(fmSongs, (_) {
      _scheduleHomeImageColorPrewarm();
    });
    ever<String>(randomLikedSongAlbumUrl, (_) {
      _scheduleHomeImageColorPrewarm();
    });
  }

  Timer? _albumDebounceTimer;

  void onAlbumPageChanged(int index) {
    if (isAlbumScrollingProgrammatic) return;
    _albumDebounceTimer?.cancel();
    _albumDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (playbackRuntimeState.value.currentIndex != index) {
        playerController.playQueueIndex(index);
      }
    });
  }

  void _ensureUiControllersInitialized() {
    if (_uiControllersInitialized) {
      return;
    }
    _uiControllersInitialized = true;
    shellController.init(initialTitle: userInfo.value.nickname);
    _bottomPanelAnimationController = AnimationController(vsync: this);
    _bottomPanelTabController =
        TabController(length: 3, initialIndex: 1, vsync: this)
          ..addListener(() {
            if (bottomPanelTabController.indexIsChanging) {
              unawaited(
                animateBottomPanelToPage(
                  bottomPanelTabController.index,
                  duration: const Duration(milliseconds: 500),
                ),
              );
              if (bottomPanelTabController.index <= 1) {
                bottomPanelCommentTabController.index = 0;
                bottomPanelCommentTabController.offset = 0;
              }
            }
          });
    _bottomPanelCommentTabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (bottomPanelCommentTabController.indexIsChanging) {
          unawaited(
            animateBottomPanelToPage(
              bottomPanelCommentTabController.index + 2,
            ),
          );
        }
      });
    _bottomPanelPageController = PageController(initialPage: 1)
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
    _albumPageController = PageController();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await userController.ensureCacheLoaded();
    if (userController.hasLocalSnapshot) {
      dateLoaded.value = true;
      _scheduleHomeImageColorPrewarm();
      unawaited(
        (Get.isRegistered<AuthController>()
                ? Get.find<AuthController>()
                : Get.put(AuthController()))
            .validateLoginStateInBackgroundIfNeeded(),
      );
      if (await userController.shouldRefreshStartupData()) {
        unawaited(updateData());
      }
      return;
    }
    await updateData();
  }

  Future<void> initZoomDrawerListener() async {
    shellController.initZoomDrawerListener();
  }

  /// 主页初始化仍统一走这一入口，避免旧页面在各自生命周期里重复拉取同一份用户数据。
  Future<void> updateData() async {
    await userController.updateUserData();
    dateLoaded.value = true;
    _scheduleHomeImageColorPrewarm();

    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  updateRecoPlayLists({bool getMore = false}) async {
    await userController.updateRecoPlayLists(getMore: getMore);
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
  void onClose() {
    _homeImageColorPrewarmTimer?.cancel();
    _albumDebounceTimer?.cancel();
    _bottomPanelAnimationController?.dispose();
    _bottomPanelPageController?.dispose();
    _bottomPanelTabController?.dispose();
    _bottomPanelCommentTabController?.dispose();
    _albumPageController?.dispose();
    super.onClose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shellController.updateKeyboardHeight(buildContext);
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (bottomPanelFullyOpened.isTrue) return;
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

  IconData getRepeatIcon() => playerController.getRepeatIcon();

  playOrPause() => playerController.playOrPause();

  /// 播放列表切换仍保留在壳层入口，是为了兼容大量旧页面直接通过 `AppController`
  /// 发起播放；等这些入口迁完，再继续下沉到更细的播放用例层。
  playNewPlayList(List<MediaItem> playList, int index,
      {String playListName = "无名歌单", String playListNameHeader = ""}) async {
    await playerController.playPlaylist(
      playList,
      index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
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
    shellController.onTopPanelSlide(openDegree);
  }

  onWillPop() {
    if (!shellController.handleWillPop(
        bottomPanelController: bottomPanelController)) {
      SystemNavigator.pop();
    }
  }

  updateFullScreenLyricTimerCounter({bool cancelTimer = false}) {
    playerController.updateFullScreenLyricTimerCounter(
        cancelTimer: cancelTimer);
  }

  // 列表页打开时直接滚到当前播放项，可以减少“当前歌曲已变但列表还停在旧位置”的错觉。
  _animatePlayListToCurSong() {
    if (playListScrollController.hasClients) {
      final currentIndex = playbackQueueIndex.value;
      if (currentIndex < 0) {
        return;
      }
      double offset = currentIndex * 55.0;
      playListScrollController.animateTo(offset,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  syncAlbumPage() {
    if (isAlbumScrollingProgrammatic) {
      return;
    }
    _animateAlbumPageViewToCurSong();
  }

  void _scheduleHomeImageColorPrewarm() {
    _homeImageColorPrewarmTimer?.cancel();
    _homeImageColorPrewarmTimer = Timer(const Duration(milliseconds: 120), () {
      unawaited(
        OtherUtils.prewarmImageColors(
          [
            todayRecommendSongs.isNotEmpty
                ? (todayRecommendSongs.first.extras?['image'] as String?)
                : null,
            fmSongs.isNotEmpty
                ? (fmSongs.first.extras?['image'] as String?)
                : null,
            randomLikedSongAlbumUrl.value,
          ],
        ),
      );
    });
  }

  // 专辑页和真实播放索引必须保持单向同步，否则用户会同时触发手势滚动和程序跳页。
  _animateAlbumPageViewToCurSong() {
    if (albumPageController.hasClients) {
      if (isAlbumScrollingManully) return;
      final currentIndex = playbackQueueIndex.value;
      if (currentIndex < 0) {
        return;
      }
      double currentPage = albumPageController.page ?? 0;
      if ((currentPage - currentIndex).abs() < 0.01) {
        return;
      }

      isAlbumScrollingProgrammatic = true;
      albumPageController
          .animateToPage(currentIndex,
              duration: const Duration(milliseconds: 500), curve: Curves.ease)
          .whenComplete(() {
        isAlbumScrollingProgrammatic = false;
      });
    }
  }
}
