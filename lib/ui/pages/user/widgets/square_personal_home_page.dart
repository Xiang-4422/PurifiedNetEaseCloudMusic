import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/quick_start_section.dart';
import 'package:bujuan/ui/pages/user/widgets/square_library_page.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:flutter/material.dart';

/// 方屏下的个人首页布局。
class SquarePersonalHomePage extends StatefulWidget {
  /// 创建方屏个人首页布局。
  const SquarePersonalHomePage({
    super.key,
    required this.metrics,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.recentPlaybackController,
    required this.shellController,
  });

  /// 方屏布局尺寸参数。
  final PersonalHomeLayoutMetrics metrics;

  /// 首页推荐控制器。
  final RecommendationController recommendationController;

  /// 用户资料库控制器。
  final UserLibraryController libraryController;

  /// 播放控制器。
  final PlayerController playbackAction;

  /// 最近播放控制器。
  final RecentPlaybackController recentPlaybackController;

  /// Shell 控制器。
  final ShellController shellController;

  @override
  State<SquarePersonalHomePage> createState() => _SquarePersonalHomePageState();
}

class _SquarePersonalHomePageState extends State<SquarePersonalHomePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const PageScrollPhysics(),
            children: [
              SquareQuickStartPage(
                metrics: widget.metrics,
                recommendationController: widget.recommendationController,
                libraryController: widget.libraryController,
                playbackAction: widget.playbackAction,
                shellController: widget.shellController,
              ),
              SquareLibraryPage(
                metrics: widget.metrics,
                recommendationController: widget.recommendationController,
                libraryController: widget.libraryController,
                playbackAction: widget.playbackAction,
                recentPlaybackController: widget.recentPlaybackController,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
      ],
    );
  }
}
