import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/shell/app_home_controller_bundle.dart';
import 'package:bujuan/ui/pages/shell/home_shell_scope.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_mini_player.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_view.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_view.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// 应用首页壳层，组合顶部搜索面板、底部播放面板和子路由。
class AppHomePageView extends StatelessWidget {
  /// 创建应用首页壳层。
  const AppHomePageView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appHomeControllers = Get.find<AppHomeControllerBundle>();
    final shellController = appHomeControllers.shellController;
    shellController.buildContext = context;
    final commentControllerFactory = appHomeControllers.commentControllerFactory;
    final homeShellController = appHomeControllers.homeShellController;
    final playerController = appHomeControllers.playerController;
    final searchController = appHomeControllers.searchController;
    final settingsController = appHomeControllers.settingsController;
    return HomeShellScope(
      homeShellController: homeShellController,
      shellController: shellController,
      child: Material(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) => shellController.onWillPop(),
          child: SlidingUpPanel(
            slideDirection: SlideDirection.DOWN,
            controller: shellController.topPanelController,
            onPanelSlide: (openDegree) => shellController.onTopPanelSlide(openDegree),
            color: Colors.transparent,
            // parallaxEnabled: true,
            // parallaxOffset: 1,
            maxHeight: context.height,
            minHeight: 0,
            boxShadow: null,
            // collapsed: const TopPanelHeaderAppBar(),
            panel: Obx(() {
              final shouldBuildTopPanel = shellController.topPanelFullyClosed.isFalse || shellController.searchContent.value.isNotEmpty;
              if (!shouldBuildTopPanel) {
                return const SizedBox.shrink();
              }
              return TopPanelView(
                shellController: shellController,
                searchController: searchController,
                playerController: playerController,
              );
            }),
            body: Obx(() {
              final hasCurrentSong = playerController.currentSongState.value.id.isNotEmpty;
              if (!hasCurrentSong) {
                return const AutoRouter();
              }
              return SlidingUpPanel(
                controller: shellController.bottomPanelController,
                onPanelSlide: (openDegree) => shellController.onBottomPanelSlide(openDegree),
                color: Colors.transparent,
                boxShadow: null,
                minHeight: AppDimensions.bottomPanelHeaderHeight + context.mediaQueryPadding.bottom,
                maxHeight: context.height,
                header: BottomPanelHeaderView(
                  shellController: shellController,
                  playerController: playerController,
                  settingsController: settingsController,
                ),
                panel: BottomPanelView(
                  shellController: shellController,
                  commentControllerFactory: commentControllerFactory,
                  playerController: playerController,
                  settingsController: settingsController,
                ),
                body: const AutoRouter(),
              );
            }),
          ),
        ),
      ),
    );
  }
}
