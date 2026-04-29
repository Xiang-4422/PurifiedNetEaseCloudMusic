import 'dart:async';

import 'package:bujuan/routes/router.dart';
import 'package:bujuan/widget/custom_zoom_drawer/src/drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeShellController extends GetxController
    with GetTickerProviderStateMixin {
  static HomeShellController get to => Get.find();

  late ZoomDrawerController zoomDrawerController;
  bool _zoomDrawerListenerInitialized = false;
  Timer? _closeDrawerTimer;
  String _defaultHomePageTitle = '';

  RxBool isDrawerClosed = true.obs;

  late PageController homePageController;
  RxInt curHomePageIndex = 0.obs;
  RxString curHomePageTitle = ''.obs;

  PanelController topPanelController = PanelController();
  late AnimationController topPanelAnimationController;
  late TextEditingController searchTextEditingController;
  RxBool topPanelFullyOpened = false.obs;
  RxBool topPanelFullyClosed = true.obs;
  RxString searchContent = ''.obs;
  final FocusNode searchFocusNode = FocusNode();
  RxDouble keyBoardHeight = 0.0.obs;
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

  void init({required String initialTitle}) {
    updateDefaultTitle(initialTitle);
  }

  void updateDefaultTitle(String title) {
    _defaultHomePageTitle = title;
    if (curHomePageIndex.value == 0) {
      curHomePageTitle.value = title;
    }
  }

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

class ShellMenuItemData {
  final String title;
  final IconData icon;
  final String route;
  final String path;

  ShellMenuItemData(this.title, this.icon, this.route, this.path);
}
