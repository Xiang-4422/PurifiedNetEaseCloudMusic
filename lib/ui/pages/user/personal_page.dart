import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/square_personal_home_page.dart';
import 'package:bujuan/ui/pages/user/widgets/standard_personal_home_page.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// 个人首页，展示快速播放、推荐歌单和用户歌单入口。
class PersonalPageView extends GetView<ShellController> {
  /// 创建个人首页。
  const PersonalPageView({Key? key}) : super(key: key);

  /// 横向区域中一屏展示的歌单卡片数量。
  final double albumCountInScreen = 3.2;

  /// 横向区域中一屏展示的快速入口卡片数量。
  final double userItemCountInScreen = 2.5;

  @override
  Widget build(BuildContext context) {
    final recommendationController = RecommendationController.to;
    final libraryController = UserLibraryController.to;
    final playbackAction = Get.find<PlayerController>();
    final recentPlaybackController = RecentPlaybackController.to;
    return Obx(() {
      if (recommendationController.dateLoaded.isFalse) {
        return const LoadingView();
      }
      final layoutMetrics = PersonalHomeLayoutMetrics(
        MediaQuery.sizeOf(context),
      );
      if (layoutMetrics.isSquareLike) {
        return SquarePersonalHomePage(
          metrics: layoutMetrics,
          recommendationController: recommendationController,
          libraryController: libraryController,
          playbackAction: playbackAction,
          recentPlaybackController: recentPlaybackController,
          shellController: controller,
        );
      }
      return StandardPersonalHomePage(
        albumCountInScreen: albumCountInScreen,
        userItemCountInScreen: userItemCountInScreen,
        recommendationController: recommendationController,
        libraryController: libraryController,
        playbackAction: playbackAction,
        recentPlaybackController: recentPlaybackController,
        shellController: controller,
      );
    });
  }
}
