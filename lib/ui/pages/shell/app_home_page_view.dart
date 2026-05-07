import 'package:auto_route/auto_route.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_view.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_view.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// 应用首页壳层，组合顶部搜索面板、底部播放面板和子路由。
class AppHomePageView extends GetView<ShellController> {
  /// 创建应用首页壳层。
  const AppHomePageView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.buildContext = context;
    final playerController = Get.find<PlayerController>();
    return Material(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => controller.onWillPop(),
        // child: SlidingUpPanel(
        //   controller: controller.bottomPanelController,
        //   onPanelSlide: (openDegree) => controller.onBottomPanelSlide(openDegree),
        //   color: Colors.transparent,
        //   boxShadow: null,
        //   // parallaxEnabled: true,
        //   // parallaxOffset: 1,
        //   minHeight: AppDimensions.bottomPanelHeaderHeight + context.mediaQueryPadding.bottom,
        //   maxHeight: context.height,
        //   header: const BottomPanelHeaderView(),
        //   panel: const BottomPanelView(),
        //   body: const AutoRouter(),
        // ),
        child: SlidingUpPanel(
          slideDirection: SlideDirection.DOWN,
          controller: controller.topPanelController,
          onPanelSlide: (openDegree) => controller.onTopPanelSlide(openDegree),
          color: Colors.transparent,
          // parallaxEnabled: true,
          // parallaxOffset: 1,
          maxHeight: context.height,
          minHeight: 0,
          boxShadow: null,
          // collapsed: const TopPanelHeaderAppBar(),
          panel: Obx(() {
            final shouldBuildTopPanel = controller.topPanelFullyClosed.isFalse || controller.searchContent.value.isNotEmpty;
            if (!shouldBuildTopPanel) {
              return const SizedBox.shrink();
            }
            return const TopPanelView();
          }),
          body: Obx(() {
            final hasCurrentSong = playerController.currentSongState.value.id.isNotEmpty;
            if (!hasCurrentSong) {
              return const AutoRouter();
            }
            return SlidingUpPanel(
              controller: controller.bottomPanelController,
              onPanelSlide: (openDegree) => controller.onBottomPanelSlide(openDegree),
              color: Colors.transparent,
              boxShadow: null,
              minHeight: AppDimensions.bottomPanelHeaderHeight + context.mediaQueryPadding.bottom,
              maxHeight: context.height,
              header: const BottomPanelHeaderView(),
              panel: const BottomPanelView(),
              body: const AutoRouter(),
            );
          }),
        ),
      ),
    );
  }
}
