import 'dart:async';
import 'package:bujuan/app/presentation_adapters/shell_playback_port.dart';
import 'package:bujuan/app/presentation_adapters/shell_user_port.dart';
import 'package:bujuan/features/shell/album_page_change_coordinator.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:bujuan/widget/custom_zoom_drawer/src/drawer_controller.dart';

/// 统一承接首页壳层、抽屉、顶部搜索面板和底部播放面板的 UI 协调。
class ShellController extends SuperController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  /// 当前壳层控制器实例。
  static ShellController get to => Get.find();
  HomeShellController get _homeShellController =>
      Get.find<HomeShellController>();
  ShellPlaybackPort get _playbackPort => Get.find<ShellPlaybackPort>();
  ShellUserPort get _userPort => Get.find<ShellUserPort>();

  /// 壳层当前构建上下文，用于响应系统窗口和主题变化。
  late BuildContext buildContext;

  /// 首页抽屉控制器。
  ZoomDrawerController get zoomDrawerController =>
      _homeShellController.zoomDrawerController;

  /// 抽屉是否完全关闭。
  RxBool get isDrawerClosed => _homeShellController.isDrawerClosed;

  /// 首页主分页控制器。
  PageController get homePageController =>
      _homeShellController.homePageController;

  /// 当前首页分页索引。
  RxInt get curHomePageIndex => _homeShellController.curHomePageIndex;

  /// 当前首页标题。
  RxString get curHomePageTitle => _homeShellController.curHomePageTitle;

  bool _uiControllersInitialized = false;
  PageController? _albumPageController;
  final AlbumPageChangeCoordinator _albumPageChangeCoordinator =
      AlbumPageChangeCoordinator();

  /// 底部面板是否展示大封面模式。
  RxBool isBigAlbum = true.obs;

  /// 专辑封面缩放动画是否结束。
  RxBool isAlbumScaleEnded = true.obs;

  /// 专辑页是否正在由用户手势滚动。
  bool isAlbumScrollingManully = false;

  /// 专辑页是否正在由程序同步滚动。
  bool isAlbumScrollingProgrammatic = false;

  /// 专辑页是否处于滚动状态。
  RxBool isAlbumScrolling = false.obs;

  /// 底部播放面板控制器。
  PanelController bottomPanelController = PanelController();
  AnimationController? _bottomPanelAnimationController;

  /// 底部播放面板是否完全关闭。
  RxBool bottomPanelFullyClosed = true.obs;

  /// 底部播放面板是否打开超过一半。
  RxBool bottomPanelOpened50 = false.obs;

  /// 底部播放面板是否完全打开。
  RxBool bottomPanelFullyOpened = false.obs;
  PageController? _bottomPanelPageController;

  /// 当前底部面板页面索引。
  RxInt curPanelPageIndex = 1.obs;
  TabController? _bottomPanelTabController;
  TabController? _bottomPanelCommentTabController;

  /// 播放队列列表滚动控制器。
  ScrollController playListScrollController = ScrollController();

  /// 专辑封面分页控制器。
  PageController get albumPageController {
    _ensureUiControllersInitialized();
    return _albumPageController!;
  }

  /// 底部播放面板动画控制器。
  AnimationController get bottomPanelAnimationController {
    _ensureUiControllersInitialized();
    return _bottomPanelAnimationController!;
  }

  /// 底部播放面板分页控制器。
  PageController get bottomPanelPageController {
    _ensureUiControllersInitialized();
    return _bottomPanelPageController!;
  }

  /// 立即跳转到底部面板指定页面。
  void jumpBottomPanelToPage(int page) {
    _ensureUiControllersInitialized();
    final controller = _bottomPanelPageController;
    if (controller != null && controller.hasClients) {
      controller.jumpToPage(page);
    }
  }

  /// 动画切换到底部面板指定页面。
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

  /// 打开底部播放面板。
  Future<void> openBottomPanel() async {
    if (bottomPanelController.isAttached) {
      await bottomPanelController.open();
    }
  }

  /// 关闭底部播放面板。
  Future<void> closeBottomPanel() async {
    if (bottomPanelController.isAttached) {
      await bottomPanelController.close();
    }
  }

  /// 打开顶部搜索面板。
  Future<void> openTopPanel() async {
    if (topPanelController.isAttached) {
      await topPanelController.open();
    }
  }

  /// 关闭顶部搜索面板。
  Future<void> closeTopPanel() async {
    if (topPanelController.isAttached) {
      await topPanelController.close();
    }
  }

  /// 底部面板主 tab 控制器。
  TabController get bottomPanelTabController {
    _ensureUiControllersInitialized();
    return _bottomPanelTabController!;
  }

  /// 底部面板评论 tab 控制器。
  TabController get bottomPanelCommentTabController {
    _ensureUiControllersInitialized();
    return _bottomPanelCommentTabController!;
  }

  /// 顶部搜索面板控制器。
  PanelController get topPanelController =>
      _homeShellController.topPanelController;

  /// 顶部搜索面板动画控制器。
  AnimationController get topPanelAnimationController =>
      _homeShellController.topPanelAnimationController;

  /// 搜索输入框控制器。
  TextEditingController get searchTextEditingController =>
      _homeShellController.searchTextEditingController;

  /// 顶部搜索面板是否完全打开。
  RxBool get topPanelFullyOpened => _homeShellController.topPanelFullyOpened;

  /// 顶部搜索面板是否完全关闭。
  RxBool get topPanelFullyClosed => _homeShellController.topPanelFullyClosed;

  /// 当前搜索输入内容。
  RxString get searchContent => _homeShellController.searchContent;

  /// 搜索输入框焦点。
  FocusNode get searchFocusNode => _homeShellController.searchFocusNode;

  /// 当前键盘高度。
  RxDouble get keyBoardHeight => _homeShellController.keyBoardHeight;

  /// 歌词列表定位控制器。
  ItemScrollController lyricScrollController = ItemScrollController();

  /// 歌词是否正在由用户滚动。
  bool isLyricScrollingByUser = false;

  /// 歌词是否正在由播放进度自动滚动。
  bool isLyricScrollingByItself = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    _homeShellController;
    _playbackPort;
    _userPort;

    _ensureUiControllersInitialized();
    WidgetsBinding.instance.addObserver(this);

    ever(_playbackPort.lyricState(), (lyricState) {
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

    ever<int>(_playbackPort.currentQueueIndex(), (currentIndex) {
      if (currentIndex < 0) {
        return;
      }
      unawaited(_animatePlayListToCurSong());
      _animateAlbumPageViewToCurSong();
    });
    ever(_userPort.userInfo(), (info) {
      _homeShellController.updateDefaultTitle(info.nickname);
    });
  }

  /// 标记封面页开始由用户手势滚动。
  void beginAlbumPageUserScroll() {
    isAlbumScrollingManully = true;
    isAlbumScrollingProgrammatic = false;
    _albumPageChangeCoordinator.clear();
  }

  /// 标记封面页用户手势结束，并提交最终切歌索引。
  Future<void> endAlbumPageUserScroll() async {
    isAlbumScrollingManully = false;
    await commitAlbumPageChange();
  }

  /// 记录专辑页用户切换，真实播放提交延迟到滚动结束。
  void onAlbumPageChanged(int index) {
    _albumPageChangeCoordinator.recordPageChange(
      index,
      isProgrammatic: isAlbumScrollingProgrammatic,
    );
  }

  /// 提交封面页最终停留索引到播放队列。
  Future<void> commitAlbumPageChange() async {
    final selectionState = _playbackPort.selectionState();
    final settledPage =
        albumPageController.hasClients ? albumPageController.page : null;
    await _albumPageChangeCoordinator.commit(
      currentIndex: selectionState.selectedIndex,
      queueLength: selectionState.queue.length,
      settledPage: settledPage,
      playIndex: _playbackPort.playQueueIndex,
    );
  }

  void _ensureUiControllersInitialized() {
    if (_uiControllersInitialized) {
      return;
    }
    _uiControllersInitialized = true;
    _homeShellController.init(
      initialTitle: _userPort.currentNickname(),
    );
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
          if (!_playbackPort.isFullScreenLyricOpen()) {
            _playbackPort.updateFullScreenLyricTimerCounter(
                cancelTimer: newPanelPageIndex != 1 &&
                    !_playbackPort.isFullScreenLyricOpen());
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

  /// 代理初始化首页抽屉监听。
  Future<void> initZoomDrawerListener() async {
    _homeShellController.initZoomDrawerListener();
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
      _homeShellController.updateKeyboardHeight(buildContext);
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

  /// 同步底部播放面板滑动进度。
  void onBottomPanelSlide(double openDegree) {
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
        unawaited(_animatePlayListToCurSong());
      }
    }
  }

  /// 同步顶部搜索面板滑动进度。
  void onTopPanelSlide(double openDegree) {
    _homeShellController.onTopPanelSlide(openDegree);
  }

  /// 处理壳层返回键。
  void onWillPop() {
    if (!_homeShellController.handleWillPop(
        bottomPanelController: bottomPanelController)) {
      SystemNavigator.pop();
    }
  }

  // 列表页打开时直接滚到当前播放项，可以减少“当前歌曲已变但列表还停在旧位置”的错觉。
  Future<void> _animatePlayListToCurSong() async {
    if (curPanelPageIndex.value == 0 &&
        bottomPanelFullyOpened.isTrue &&
        playListScrollController.hasClients) {
      final currentIndex = _playbackPort.currentQueueIndex().value;
      if (currentIndex < 0) {
        return;
      }
      double offset = currentIndex * 55.0;
      await playListScrollController.animateTo(offset,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  /// 将专辑页同步到当前播放索引。
  void syncAlbumPage() {
    if (isAlbumScrollingProgrammatic) {
      return;
    }
    _animateAlbumPageViewToCurSong();
  }

  // 专辑页和真实播放索引必须保持单向同步，否则用户会同时触发手势滚动和程序跳页。
  _animateAlbumPageViewToCurSong() {
    if (albumPageController.hasClients) {
      if (isAlbumScrollingManully) return;
      final currentIndex = _playbackPort.currentQueueIndex().value;
      if (currentIndex < 0) {
        return;
      }
      double currentPage = albumPageController.page ?? 0;
      if ((currentPage - currentIndex).abs() <
          AlbumPageChangeCoordinator.settledPageTolerance) {
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
