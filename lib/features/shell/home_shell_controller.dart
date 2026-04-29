import 'dart:async';

import 'package:bujuan/routes/router.dart';
import 'package:bujuan/widget/custom_zoom_drawer/src/drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// 首页壳层控制器，管理抽屉、首页分页和顶部搜索面板。
class HomeShellController extends GetxController
    with GetTickerProviderStateMixin {
  /// 当前首页壳层控制器实例。
  static HomeShellController get to => Get.find();

  /// 首页抽屉控制器。
  late ZoomDrawerController zoomDrawerController;
  bool _zoomDrawerListenerInitialized = false;
  Timer? _closeDrawerTimer;
  String _defaultHomePageTitle = '';

  /// 抽屉是否完全关闭。
  RxBool isDrawerClosed = true.obs;

  /// 首页主分页控制器。
  late PageController homePageController;

  /// 当前首页分页索引。
  RxInt curHomePageIndex = 0.obs;

  /// 当前首页标题。
  RxString curHomePageTitle = ''.obs;

  /// 顶部搜索面板控制器。
  PanelController topPanelController = PanelController();

  /// 顶部搜索面板动画控制器。
  late AnimationController topPanelAnimationController;

  /// 搜索输入框控制器。
  late TextEditingController searchTextEditingController;

  /// 顶部搜索面板是否完全打开。
  RxBool topPanelFullyOpened = false.obs;

  /// 顶部搜索面板是否完全关闭。
  RxBool topPanelFullyClosed = true.obs;

  /// 当前搜索输入内容。
  RxString searchContent = ''.obs;

  /// 搜索输入框焦点。
  final FocusNode searchFocusNode = FocusNode();

  /// 当前键盘高度。
  RxDouble keyBoardHeight = 0.0.obs;

  /// 左侧抽屉菜单项。
  final List<ShellMenuItemData> leftMenus = [
    ShellMenuItemData('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    ShellMenuItemData(
      '推荐歌单',
      TablerIcons.smart_home,
      Routes.index,
      '/home/index',
    ),
    ShellMenuItemData(
      '个性设置',
      TablerIcons.settings,
      Routes.setting,
      '/home/settingL',
    ),
    ShellMenuItemData('捐赠', TablerIcons.coffee, Routes.coffee, ''),
  ];

  @override
  void onInit() {
    super.onInit();
    zoomDrawerController = ZoomDrawerController();
    initZoomDrawerListener();
    topPanelAnimationController = AnimationController(vsync: this);
    searchTextEditingController = TextEditingController()
      ..addListener(() {
        searchContent.value = searchTextEditingController.text;
      });
    homePageController = PageController()
      ..addListener(() {
        final updatedPageIndex = (homePageController.page! + 0.5).toInt();
        if (updatedPageIndex == curHomePageIndex.value) return;
        curHomePageIndex.value = updatedPageIndex;
        curHomePageTitle.value = _resolveHomePageTitle(updatedPageIndex);
        _updateCloseDrawerTimer(3000);
      });
  }

  /// 初始化首页默认标题。
  void init({required String initialTitle}) {
    updateDefaultTitle(initialTitle);
  }

  /// 更新首页默认标题，当前停留首页时同步标题。
  void updateDefaultTitle(String title) {
    _defaultHomePageTitle = title;
    if (curHomePageIndex.value == 0) {
      curHomePageTitle.value = title;
    }
  }

  /// 初始化抽屉开合监听。
  void initZoomDrawerListener() {
    if (_zoomDrawerListenerInitialized) {
      return;
    }
    final addListener = zoomDrawerController.addListener;
    if (addListener == null) {
      return;
    }
    _zoomDrawerListenerInitialized = true;
    addListener((drawerOpenDegree) {
      if ((drawerOpenDegree == 0.0) == isDrawerClosed.value) return;
      isDrawerClosed.value = drawerOpenDegree == 0.0;
      if (!isDrawerClosed.value) {
        _updateCloseDrawerTimer(3000);
      } else {
        _updateCloseDrawerTimer(0);
      }
    });
  }

  /// 同步顶部搜索面板滑动进度。
  void onTopPanelSlide(double openDegree) {
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

  /// 处理返回键，优先关闭搜索面板、底部面板和抽屉。
  bool handleWillPop({required PanelController bottomPanelController}) {
    if (topPanelController.isPanelOpen) {
      if (topPanelController.isAttached) {
        topPanelController.close();
      }
      return true;
    }
    if (bottomPanelController.isPanelOpen) {
      if (bottomPanelController.isAttached) {
        bottomPanelController.close();
      }
      return true;
    }
    final isDrawerOpen = zoomDrawerController.isOpen;
    final closeDrawer = zoomDrawerController.close;
    if (isDrawerOpen?.call() == true) {
      closeDrawer?.call();
      return true;
    }
    if (homePageController.page != 0) {
      homePageController.animateToPage(
        0,
        duration:
            Duration(milliseconds: 100 * (homePageController.page)!.toInt()),
        curve: Curves.linear,
      );
      return true;
    }
    return false;
  }

  /// 根据窗口信息更新键盘高度。
  void updateKeyboardHeight(BuildContext context) {
    keyBoardHeight.value = MediaQuery.of(context).viewInsets.bottom;
  }

  String _resolveHomePageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return _defaultHomePageTitle;
      case 1:
        return '每日发现';
      case 2:
        return '设置';
      case 3:
        return '赞助开发者';
      default:
        return _defaultHomePageTitle;
    }
  }

  void _updateCloseDrawerTimer(double timeValue) {
    _closeDrawerTimer?.cancel();
    if (timeValue <= 0) {
      return;
    }
    _closeDrawerTimer = Timer(Duration(milliseconds: timeValue.toInt()), () {
      final isDrawerOpen = zoomDrawerController.isOpen;
      final closeDrawer = zoomDrawerController.close;
      if (isDrawerOpen?.call() == true) {
        closeDrawer?.call();
      }
    });
  }

  @override
  void onClose() {
    _closeDrawerTimer?.cancel();
    homePageController.dispose();
    topPanelAnimationController.dispose();
    searchTextEditingController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}

/// 首页抽屉菜单项数据。
class ShellMenuItemData {
  /// 菜单标题。
  final String title;

  /// 菜单图标。
  final IconData icon;

  /// 菜单对应路由名。
  final String route;

  /// 菜单对应路径。
  final String path;

  /// 创建首页抽屉菜单项数据。
  ShellMenuItemData(this.title, this.icon, this.route, this.path);
}
