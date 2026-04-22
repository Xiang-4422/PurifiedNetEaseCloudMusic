import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/pages/home/body/coffee_page.dart';
import 'package:bujuan/pages/home/body/explore_page.dart';
import 'package:bujuan/pages/home/body/personal_page.dart';
import 'package:bujuan/pages/home/body/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widget/custom_zoom_drawer/src/flutter_zoom_drawer.dart';
import 'package:bujuan/routes/router.dart';

import '../../../widget/artwork_path_resolver.dart';
import '../../../widget/simple_extended_image.dart';

class AppBodyPageView extends GetView<AppController> {
  const AppBodyPageView({super.key});

  @override
  Widget build(BuildContext context) {
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

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Obx(() => AbsorbPointer(
              absorbing: !AppController.to.isDrawerClosed.value,
              child: const PersonalPageView(),
            ));
      case 1:
        return Obx(() => AbsorbPointer(
              absorbing: !AppController.to.isDrawerClosed.value,
              child: const ExplorePageView(),
            ));
      case 2:
        return Obx(() => AbsorbPointer(
              absorbing: !AppController.to.isDrawerClosed.value,
              child: const SettingPageView(),
            ));
      case 3:
        return Obx(() => AbsorbPointer(
              absorbing: !AppController.to.isDrawerClosed.value,
              child: const CoffeePageView(),
            ));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: context.height,
      child: Obx(() => PageView.builder(
            physics: controller.isDrawerClosed.value
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: controller.homePageController,
            itemCount: 4,
            itemBuilder: (context, index) => _buildPage(index),
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
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(9999)),
        color: Colors.black12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Obx(
              () => SimpleExtendedImage.avatar(
                ArtworkPathResolver.resolveDisplayPath(
                  controller.userInfo.value.avatarUrl,
                ),
                shape: BoxShape.circle,
              ),
            ),
            onPressed: () {
              final router = context.router;
              controller.zoomDrawerController.close!();
              Future.delayed(const Duration(milliseconds: 200), () {
                router.pushNamed(Routes.userProfile);
              });
            },
          ),
          Expanded(
            child: Center(
              child: Obx(
                () => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        controller.curHomePageTitle.value.split("").map((c) {
                      return Text(
                        c,
                        style: context.textTheme.titleLarge,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(controller.leftMenus.length, (index) {
                return IconButton(
                  onPressed: () {
                    int onePageAnimationTime = 200;
                    Duration animationTime = Duration(
                        milliseconds: onePageAnimationTime *
                            (controller.homePageController.page! - index)
                                .abs()
                                .toInt());
                    controller.homePageController.animateToPage(index,
                        duration: animationTime, curve: Curves.linear);
                  },
                  icon: Obx(() => Icon(controller.leftMenus[index].icon,
                      size: AppDimensions.albumMinSize * 2 / 3,
                      color: controller.curHomePageIndex.value == index
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).iconTheme.color)),
                );
              }),
            ),
          ),
          const SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
        ],
      ),
    );
  }
}

/// 菜单项目前只服务首页壳层，保持在这里能避免为了一个轻量模型再扩散目录。
class LeftMenuBean {
  String title;
  IconData icon;
  String path;
  String pathUrl;

  LeftMenuBean(this.title, this.icon, this.path, this.pathUrl);
}
