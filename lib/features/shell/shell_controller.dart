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
  /// to。
  static ShellController get to => Get.find();
  HomeShellController get _homeShellController =>
      Get.find<HomeShellController>();
  ShellPlaybackPort get _playbackPort => Get.find<ShellPlaybackPort>();
  ShellUserPort get _userPort => Get.find<ShellUserPort>();

  /// buildContext。
  late BuildContext buildContext;

  /// zoomDrawerController。
  ZoomDrawerController get zoomDrawerController =>
      _homeShellController.zoomDrawerController;

  /// isDrawerClosed。
  RxBool get isDrawerClosed => _homeShellController.isDrawerClosed;

  /// homePageController。
  PageController get homePageController =>
      _homeShellController.homePageController;

  /// curHomePageIndex。
  RxInt get curHomePageIndex => _homeShellController.curHomePageIndex;

  /// curHomePageTitle。
  RxString get curHomePageTitle => _homeShellController.curHomePageTitle;

  bool _uiControllersInitialized = false;
  PageController? _albumPageController;

  /// isBigAlbum。
  RxBool isBigAlbum = true.obs;

  /// isAlbumScaleEnded。
  RxBool isAlbumScaleEnded = true.obs;

  /// isAlbumScrollingManully。
  bool isAlbumScrollingManully = false;

  /// isAlbumScrollingProgrammatic。
  bool isAlbumScrollingProgrammatic = false;

  /// isAlbumScrolling。
  RxBool isAlbumScrolling = false.obs;

  /// bottomPanelController。
  PanelController bottomPanelController = PanelController();
  AnimationController? _bottomPanelAnimationController;

  /// bottomPanelFullyClosed。
  RxBool bottomPanelFullyClosed = true.obs;

  /// bottomPanelOpened50。
  RxBool bottomPanelOpened50 = false.obs;

  /// bottomPanelFullyOpened。
  RxBool bottomPanelFullyOpened = false.obs;
  PageController? _bottomPanelPageController;

  /// curPanelPageIndex。
  RxInt curPanelPageIndex = 1.obs;
  TabController? _bottomPanelTabController;
  TabController? _bottomPanelCommentTabController;

  /// playListScrollController。
  ScrollController playListScrollController = ScrollController();

  /// albumPageController。
  PageController get albumPageController {
    _ensureUiControllersInitialized();
    return _albumPageController!;
  }

  /// bottomPanelAnimationController。
  AnimationController get bottomPanelAnimationController {
    _ensureUiControllersInitialized();
    return _bottomPanelAnimationController!;
  }

  /// bottomPanelPageController。
  PageController get bottomPanelPageController {
    _ensureUiControllersInitialized();
    return _bottomPanelPageController!;
  }

  /// jumpBottomPanelToPage。
  void jumpBottomPanelToPage(int page) {
    _ensureUiControllersInitialized();
    final controller = _bottomPanelPageController;
    if (controller != null && controller.hasClients) {
      controller.jumpToPage(page);
    }
  }

  /// animateBottomPanelToPage。
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

  /// openBottomPanel。
  Future<void> openBottomPanel() async {
    if (bottomPanelController.isAttached) {
      await bottomPanelController.open();
    }
  }

  /// closeBottomPanel。
  Future<void> closeBottomPanel() async {
    if (bottomPanelController.isAttached) {
      await bottomPanelController.close();
    }
  }

  /// openTopPanel。
  Future<void> openTopPanel() async {
    if (topPanelController.isAttached) {
      await topPanelController.open();
    }
  }

  /// closeTopPanel。
  Future<void> closeTopPanel() async {
    if (topPanelController.isAttached) {
      await topPanelController.close();
    }
  }

  /// bottomPanelTabController。
  TabController get bottomPanelTabController {
    _ensureUiControllersInitialized();
    return _bottomPanelTabController!;
  }

  /// bottomPanelCommentTabController。
  TabController get bottomPanelCommentTabController {
    _ensureUiControllersInitialized();
    return _bottomPanelCommentTabController!;
  }

  /// topPanelController。
  PanelController get topPanelController =>
      _homeShellController.topPanelController;

  /// topPanelAnimationController。
  AnimationController get topPanelAnimationController =>
      _homeShellController.topPanelAnimationController;

  /// searchTextEditingController。
  TextEditingController get searchTextEditingController =>
      _homeShellController.searchTextEditingController;

  /// topPanelFullyOpened。
  RxBool get topPanelFullyOpened => _homeShellController.topPanelFullyOpened;

  /// topPanelFullyClosed。
  RxBool get topPanelFullyClosed => _homeShellController.topPanelFullyClosed;

  /// searchContent。
  RxString get searchContent => _homeShellController.searchContent;

  /// searchFocusNode。
  FocusNode get searchFocusNode => _homeShellController.searchFocusNode;

  /// keyBoardHeight。
  RxDouble get keyBoardHeight => _homeShellController.keyBoardHeight;

  /// lyricScrollController。
  ItemScrollController lyricScrollController = ItemScrollController();

  /// isLyricScrollingByUser。
  bool isLyricScrollingByUser = false;

  /// isLyricScrollingByItself。
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

  /// onAlbumPageChanged。
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

  /// initZoomDrawerListener。
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

  /// onBottomPanelSlide。
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

  /// onTopPanelSlide。
  onTopPanelSlide(double openDegree) {
    _homeShellController.onTopPanelSlide(openDegree);
  }

  /// onWillPop。
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

  /// syncAlbumPage。
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
