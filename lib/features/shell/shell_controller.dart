import 'dart:async';
import 'package:bujuan/app/presentation_adapters/shell_playback_port.dart';
import 'package:bujuan/app/presentation_adapters/shell_user_port.dart';
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
  static ShellController get to => Get.find();
  HomeShellController get _homeShellController =>
      Get.find<HomeShellController>();
  ShellPlaybackPort get _playbackPort => Get.find<ShellPlaybackPort>();
  ShellUserPort get _userPort => Get.find<ShellUserPort>();

  late BuildContext buildContext;

  ZoomDrawerController get zoomDrawerController =>
      _homeShellController.zoomDrawerController;
  RxBool get isDrawerClosed => _homeShellController.isDrawerClosed;
  PageController get homePageController =>
      _homeShellController.homePageController;
  RxInt get curHomePageIndex => _homeShellController.curHomePageIndex;
  RxString get curHomePageTitle => _homeShellController.curHomePageTitle;

  bool _uiControllersInitialized = false;
  PageController? _albumPageController;
  RxBool isBigAlbum = true.obs;
  RxBool isAlbumScaleEnded = true.obs;
  bool isAlbumScrollingManully = false;
  bool isAlbumScrollingProgrammatic = false;
  RxBool isAlbumScrolling = false.obs;

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

  PanelController get topPanelController =>
      _homeShellController.topPanelController;
  AnimationController get topPanelAnimationController =>
      _homeShellController.topPanelAnimationController;
  TextEditingController get searchTextEditingController =>
      _homeShellController.searchTextEditingController;
  RxBool get topPanelFullyOpened => _homeShellController.topPanelFullyOpened;
  RxBool get topPanelFullyClosed => _homeShellController.topPanelFullyClosed;
  RxString get searchContent => _homeShellController.searchContent;
  FocusNode get searchFocusNode => _homeShellController.searchFocusNode;
  RxDouble get keyBoardHeight => _homeShellController.keyBoardHeight;

  ItemScrollController lyricScrollController = ItemScrollController();
  bool isLyricScrollingByUser = false;
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
      _animatePlayListToCurSong();
      _animateAlbumPageViewToCurSong();
    });
    ever(_userPort.userInfo(), (info) {
      _homeShellController.updateDefaultTitle(info.nickname);
    });
  }

  Timer? _albumDebounceTimer;

  void onAlbumPageChanged(int index) {
    if (isAlbumScrollingProgrammatic) return;
    _albumDebounceTimer?.cancel();
    _albumDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_playbackPort.runtimeState().currentIndex != index) {
        _playbackPort.playQueueIndex(index);
      }
    });
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
    _homeShellController.onTopPanelSlide(openDegree);
  }

  onWillPop() {
    if (!_homeShellController.handleWillPop(
        bottomPanelController: bottomPanelController)) {
      SystemNavigator.pop();
    }
  }

  // 列表页打开时直接滚到当前播放项，可以减少“当前歌曲已变但列表还停在旧位置”的错觉。
  _animatePlayListToCurSong() {
    if (playListScrollController.hasClients) {
      final currentIndex = _playbackPort.currentQueueIndex().value;
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

  // 专辑页和真实播放索引必须保持单向同步，否则用户会同时触发手势滚动和程序跳页。
  _animateAlbumPageViewToCurSong() {
    if (albumPageController.hasClients) {
      if (isAlbumScrollingManully) return;
      final currentIndex = _playbackPort.currentQueueIndex().value;
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
