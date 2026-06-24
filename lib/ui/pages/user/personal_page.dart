import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/square_personal_home_page.dart';
import 'package:bujuan/ui/pages/user/widgets/standard_personal_home_page.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:bujuan/features/user/home_content_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// 个人首页，展示快速播放、最近播放和资料库入口。
class PersonalPageView extends StatelessWidget {
  /// 创建个人首页。
  const PersonalPageView({
    required this.playerController,
    required this.recentPlaybackController,
    required this.homeContentController,
    required this.userLibraryController,
    required this.shellController,
    Key? key,
  }) : super(key: key);

  /// 播放控制器。
  final PlayerController playerController;

  /// 最近播放控制器。
  final RecentPlaybackController recentPlaybackController;

  /// 首页内容控制器。
  final HomeContentController homeContentController;

  /// 用户资料库控制器。
  final UserLibraryController userLibraryController;

  /// Shell 控制器。
  final ShellController shellController;

  /// 横向区域中一屏展示的歌单卡片数量。
  final double albumCountInScreen = 3.2;

  /// 横向区域中一屏展示的快速入口卡片数量。
  final double userItemCountInScreen = 2.5;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (homeContentController.dateLoaded.isFalse) {
        return const LoadingView();
      }
      final layoutMetrics = PersonalHomeLayoutMetrics(
        MediaQuery.sizeOf(context),
      );
      if (layoutMetrics.isSquareLike) {
        return SquarePersonalHomePage(
          metrics: layoutMetrics,
          homeContentController: homeContentController,
          libraryController: userLibraryController,
          playbackAction: playerController,
          recentPlaybackController: recentPlaybackController,
          shellController: shellController,
        );
      }
      return StandardPersonalHomePage(
        albumCountInScreen: albumCountInScreen,
        userItemCountInScreen: userItemCountInScreen,
        homeContentController: homeContentController,
        libraryController: userLibraryController,
        playbackAction: playerController,
        recentPlaybackController: recentPlaybackController,
        shellController: shellController,
      );
    });
  }
}
