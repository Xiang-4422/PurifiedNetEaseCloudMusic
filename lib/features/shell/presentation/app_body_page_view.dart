import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/explore/presentation/explore_page.dart';
import 'package:bujuan/features/settings/presentation/setting_page.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/shell/presentation/coffee_page.dart';
import 'package:bujuan/features/user/presentation/personal_page.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/custom_zoom_drawer/src/flutter_zoom_drawer.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 应用主体页，组合侧边抽屉和首页主内容。
class AppBodyPageView extends GetView<ShellController> {
  /// 创建应用主体页。
  const AppBodyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: context.theme.colorScheme.primary,
          child: ZoomDrawer(
            controller: HomeShellController.to.zoomDrawerController,

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

/// 侧边抽屉主屏幕，按首页 tab 组合各 feature 页面。
class DrawerMainScreenView extends GetView<ShellController> {
  /// 创建侧边抽屉主屏幕。
  const DrawerMainScreenView({Key? key}) : super(key: key);

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Obx(() => AbsorbPointer(
              absorbing: !HomeShellController.to.isDrawerClosed.value,
              child: const PersonalPageView(),
            ));
      case 1:
        return Obx(() => AbsorbPointer(
              absorbing: !HomeShellController.to.isDrawerClosed.value,
              child: const ExplorePageView(),
            ));
      case 2:
        return Obx(() => AbsorbPointer(
              absorbing: !HomeShellController.to.isDrawerClosed.value,
              child: const SettingPageView(),
            ));
      case 3:
        return Obx(() => AbsorbPointer(
              absorbing: !HomeShellController.to.isDrawerClosed.value,
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
            physics: HomeShellController.to.isDrawerClosed.value
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: HomeShellController.to.homePageController,
            itemCount: 4,
            itemBuilder: (context, index) => _buildPage(index),
          )),
    );
  }
}

/// 左侧竖向菜单视图，负责切换首页主屏幕页。
class MenuView extends GetView<ShellController> {
  /// 创建左侧菜单视图。
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
                  UserSessionController.to.userInfo.value.avatarUrl,
                ),
                shape: BoxShape.circle,
              ),
            ),
            onPressed: () {
              final router = context.router;
              HomeShellController.to.zoomDrawerController.close?.call();
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
                    children: HomeShellController.to.curHomePageTitle.value
                        .split("")
                        .map((c) {
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
              children: List.generate(HomeShellController.to.leftMenus.length,
                  (index) {
                return IconButton(
                  onPressed: () {
                    int onePageAnimationTime = 200;
                    Duration animationTime = Duration(
                        milliseconds: onePageAnimationTime *
                            (HomeShellController.to.homePageController.page! -
                                    index)
                                .abs()
                                .toInt());
                    HomeShellController.to.homePageController.animateToPage(
                        index,
                        duration: animationTime,
                        curve: Curves.linear);
                  },
                  icon: Obx(() => Icon(
                      HomeShellController.to.leftMenus[index].icon,
                      size: AppDimensions.albumMinSize * 2 / 3,
                      color:
                          HomeShellController.to.curHomePageIndex.value == index
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
