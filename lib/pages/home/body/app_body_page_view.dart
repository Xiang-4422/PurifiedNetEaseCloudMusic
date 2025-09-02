
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/home/body/body_pages/coffee_page.dart';
import 'package:bujuan/pages/home/body/body_pages/explore_page.dart';
import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:bujuan/pages/home/body/body_pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widget/custom_zoom_drawer/src/flutter_zoom_drawer.dart';
import 'package:bujuan/routes/router.dart';


import '../../../widget/simple_extended_image.dart';
import '../top_panel/top_panel_view.dart';


class AppBodyPageView extends GetView<AppController> {
  const AppBodyPageView({super.key});

  /// 0-1，占据屏幕的比例
  final double _manuPanelWidth = 0.2;

  @override
  Widget build(BuildContext context) {
    log("building zoomDrawer");
    return Stack(
      children: [
        Container(
          color: context.theme.colorScheme.primary,
          child: ZoomDrawer(
            controller: controller.zoomDrawerController,

            // 侧边抽屉配置
            // menuScreenTapClose: true,
            slideWidth: AppDimensions.bottomPanelHeaderHeight,
            menuScreenWidth: AppDimensions.bottomPanelHeaderHeight,
            menuBackgroundColor: Colors.white70,
            // menuScreenOverlayColor: Colors.white10,

            // 主屏幕配置
            angle: 0,
            mainScreenScale: 0,
            borderRadius: 0,
            mainScreenTapClose: true,
            mainScreenAbsorbPointer: false,
            clipMainScreen: true,

            // 动画配置
            openCurve: Curves.linear,
            closeCurve: Curves.linear,
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 200),
            androidCloseOnBackTap: true,
            dragOffset: context.width,

            menuScreen: const MenuView(),
            mainScreen: const DrawerMainScreenView(),
          ),
        ),
      ],
    );
  }
}

class DrawerMainScreenView extends GetView<AppController> {
  const DrawerMainScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: context.height,
      child: Obx(() => PageView(
        physics: controller.isDrawerClosed.value
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        scrollDirection: Axis.vertical,
        controller: controller.homePageController,
        children: [
          Obx(() => AbsorbPointer(
            absorbing: !AppController.to.isDrawerClosed.value,
            child: const PersonalPageView(),
          )),
          Obx(() => AbsorbPointer(
              absorbing: !AppController.to.isDrawerClosed.value,
              child: const ExplorePageView(),
          )),
          Obx(() => AbsorbPointer(
              absorbing: !AppController.to.isDrawerClosed.value,
              child: const SettingPageView(),
          )),
          Obx(() => AbsorbPointer(
              absorbing: !AppController.to.isDrawerClosed.value,
              child: const CoffeePageView(),
          )),
        ],
      )),
    );
  }
}
class MenuView extends GetView<AppController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
      padding: EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(9999)),
        color: Colors.black12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Obx(() => SimpleExtendedImage.avatar(
              '${controller.userData.value.profile?.avatarUrl ?? ''}?param=300y300',
              shape: BoxShape.circle,
            ),),
            onPressed: () {
              controller.zoomDrawerController.close!();
              Future.delayed(const Duration(milliseconds: 200), () {
                context.router.pushNamed(Routes.userSetting);
              });
            },
          ),
          Expanded(child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: controller.curHomePageTitle.value.split("").map((c) {
              return Text(
                c,
                style: context.textTheme.titleLarge,
              );
            }).toList(),
          ),
          )),
          ListView.builder(
            itemCount: controller.leftMenus.length,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              return IconButton(
                onPressed: () {
                  int onePageAnimationTime = 200;
                  Duration animationTime = Duration(milliseconds: onePageAnimationTime  * (controller.homePageController.page! - index).abs().toInt());
                  controller.homePageController.animateToPage(index, duration: animationTime, curve:Curves.linear);
                },
                icon: Obx(() => Icon(
                    controller.leftMenus[index].icon,
                    size: AppDimensions.albumMinSize * 2/3,
                    color: controller.curHomePageIndex.value == index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).iconTheme.color)),
              );
            },
          ),
          const SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
        ],
      ),
    );
  }
}

/// 左侧菜单栏bean
class LeftMenuBean {
  String title;
  IconData icon;
  String path;
  String pathUrl;

  LeftMenuBean(this.title, this.icon, this.path, this.pathUrl);
}