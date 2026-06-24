import 'package:auto_route/auto_route.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/pages/explore/explore_page.dart';
import 'package:bujuan/ui/pages/settings/setting_page.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/shell/personal_home_controller_bundle.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/coffee_page.dart';
import 'package:bujuan/ui/pages/shell/home_shell_scope.dart';
import 'package:bujuan/ui/pages/user/personal_page.dart';
import 'package:bujuan/ui/pages/user/recommended_playlists_page.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:bujuan/app/routing/router.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/shell/custom_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 应用主体页，组合侧边抽屉和首页主内容。
class AppBodyPageView extends GetView<ShellController> {
  /// 创建应用主体页。
  const AppBodyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeShellController = HomeShellScope.of(context);
    final personalHomeControllers = Get.find<PersonalHomeControllerBundle>();
    final isSquareLike = PersonalHomeLayoutMetrics(
      MediaQuery.sizeOf(context),
    ).isSquareLike;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeShellController.updateHomeLayoutMode(isSquareLike: isSquareLike);
    });
    return Stack(
      children: [
        Container(
          color: context.theme.colorScheme.primary,
          child: ZoomDrawer(
            controller: homeShellController.zoomDrawerController,

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

            menuScreen: MenuView(homeShellController: homeShellController),
            mainScreen: DrawerMainScreenView(
              homeShellController: homeShellController,
              personalHomeControllers: personalHomeControllers,
            ),
          ),
        ),
      ],
    );
  }
}

/// 侧边抽屉主屏幕，按首页 tab 组合各 feature 页面。
class DrawerMainScreenView extends GetView<ShellController> {
  /// 创建侧边抽屉主屏幕。
  const DrawerMainScreenView({
    required this.homeShellController,
    required this.personalHomeControllers,
    Key? key,
  }) : super(key: key);

  /// 首页壳层控制器，提供页面定义和抽屉状态。
  final HomeShellController homeShellController;

  /// 个人首页控制器组合。
  final PersonalHomeControllerBundle personalHomeControllers;

  Widget _buildPage(int index) {
    switch (homeShellController.pageKindAt(index)) {
      case HomeShellPageKind.personal:
        return _absorbed(
          PersonalPageView(
            playerController: personalHomeControllers.playerController,
            recentPlaybackController: personalHomeControllers.recentPlaybackController,
            recommendationController: personalHomeControllers.recommendationController,
            userLibraryController: personalHomeControllers.userLibraryController,
            shellController: controller,
          ),
        );
      case HomeShellPageKind.recommendedPlaylists:
        return _absorbed(const RecommendedPlaylistsPageView());
      case HomeShellPageKind.explore:
        return _absorbed(const ExplorePageView());
      case HomeShellPageKind.settings:
        return _absorbed(const SettingPageView());
      case HomeShellPageKind.coffee:
        return _absorbed(const CoffeePageView());
      case null:
        return const SizedBox.shrink();
    }
  }

  Widget _absorbed(Widget child) {
    return Obx(
      () => AbsorbPointer(
        absorbing: !homeShellController.isDrawerClosed.value,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: context.height,
      child: Obx(
        () => PageView.builder(
          physics: homeShellController.isDrawerClosed.value ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: homeShellController.homePageController,
          itemCount: homeShellController.homePageCount,
          itemBuilder: (context, index) => _buildPage(index),
        ),
      ),
    );
  }
}

/// 左侧竖向菜单视图，负责切换首页主屏幕页。
class MenuView extends GetView<ShellController> {
  /// 创建左侧菜单视图。
  const MenuView({
    required this.homeShellController,
    super.key,
  });

  /// 首页壳层控制器，提供菜单状态和分页控制器。
  final HomeShellController homeShellController;

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
            tooltip: drawerProfileActionLabel(),
            padding: EdgeInsets.zero,
            icon: Obx(
              () => SimpleExtendedImage.avatar(
                ArtworkPathResolver.resolveDisplayPath(
                  controller.menuAvatarUrl,
                ),
                shape: BoxShape.circle,
              ),
            ),
            onPressed: () {
              final router = context.router;
              homeShellController.zoomDrawerController.close?.call();
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
                    children: homeShellController.curHomePageTitle.value.split("").map((c) {
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
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Obx(
                () {
                  final menus = homeShellController.leftMenus;
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(menus.length, (index) {
                        final menu = menus[index];
                        final isCurrent = homeShellController.curHomePageIndex.value == index;
                        return IconButton(
                          tooltip: drawerMenuActionLabel(
                            title: menu.title,
                            isCurrent: isCurrent,
                          ),
                          onPressed: () {
                            homeShellController.switchHomePage(index);
                          },
                          icon: Icon(
                            menu.icon,
                            size: AppDimensions.albumMinSize * 2 / 3,
                            color: isCurrent ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
        ],
      ),
    );
  }
}

/// 生成抽屉头像入口的辅助语义标签。
@visibleForTesting
String drawerProfileActionLabel() {
  return '打开个人资料';
}

/// 生成抽屉菜单切换按钮的辅助语义标签。
@visibleForTesting
String drawerMenuActionLabel({
  required String title,
  required bool isCurrent,
}) {
  final resolvedTitle = title.trim().isEmpty ? '页面' : title.trim();
  if (isCurrent) {
    return '$resolvedTitle（当前页面）';
  }
  return '切换到$resolvedTitle';
}
