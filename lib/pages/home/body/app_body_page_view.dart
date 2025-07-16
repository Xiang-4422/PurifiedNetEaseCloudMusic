
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/home/body/body_pages/coffee_page.dart';
import 'package:bujuan/pages/home/body/body_pages/explore_page.dart';
import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:bujuan/pages/home/body/body_pages/setting_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/router.gr.dart';
import '../../../widget/custom_zoom_drawer/src/flutter_zoom_drawer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widget/simple_extended_image.dart';
import '../../../controllers/user_controller.dart';


class AppBodyPageView extends GetView<AppController> {
  const AppBodyPageView({super.key});

  /// 0-1，占据屏幕的比例
  final double _manuPanelWidth = 0.2;

  @override
  Widget build(BuildContext context) {
    log("building zoomDrawer");
    return Container(
      color: context.theme.colorScheme.primary,
      child: ZoomDrawer(
        controller: controller.zoomDrawerController,

        // 侧边抽屉配置
        menuScreenTapClose: true,
        slideWidth: context.width * _manuPanelWidth,
        menuScreenWidth: context.width * _manuPanelWidth,
        menuBackgroundColor: Colors.transparent,

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
        dragOffset: context.width * 0.5,

        menuScreen: const MenuView(),
        mainScreen: const DrawerMainScreenView(),
      ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
            child: Container(
              alignment: Alignment.center,
              child: ListView.separated(
                itemCount: controller.leftMenus.length + 1,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  if (index == controller.leftMenus.length / 2) {
                    return IconButton(
                      icon: Obx(() => SimpleExtendedImage.avatar(
                        '${controller.userData.value.profile?.avatarUrl ?? ''}?param=300y300',
                        shape: BoxShape.circle,
                        width: 50,
                      ),),
                      onPressed: () {
                        if (controller.loginStatus.value == LoginStatus.noLogin) {
                          context.router.pushNamed(Routes.login);
                          return;
                        }
                        controller.zoomDrawerController.close!();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          context.router.pushNamed(Routes.userSetting);
                        });
                      },
                    );
                  } else {
                    int menuIndex = index > controller.leftMenus.length / 2 ? index - 1 : index;
                    return IconButton(
                      onPressed: () {
                        controller.zoomDrawerController.close!();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          int onePageAnimationTime = 200;
                          Duration animationTime = Duration(milliseconds: onePageAnimationTime  * (controller.homePageController!.page! - menuIndex).abs().toInt());
                          controller.homePageController.animateToPage(menuIndex, duration: animationTime, curve:Curves.linear);
                          // AutoTabsRouter.of(context).setActiveIndex(menuIndex);
                        });
                      },
                      icon: Obx(() => Icon(
                          controller.leftMenus[menuIndex].icon,
                          size: 52,
                          color: controller.curHomePageIndex.value == menuIndex
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).iconTheme.color)),
                    );
                  }
                }, separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 15,
                );
              },
              ),
            )
        ),
        Container(
          height: MediaQuery.of(context).padding.top,
        )
      ],
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