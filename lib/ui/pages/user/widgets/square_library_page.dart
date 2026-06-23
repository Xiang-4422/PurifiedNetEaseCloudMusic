import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/frequent_playlist_section.dart';
import 'package:bujuan/ui/pages/user/widgets/library_shortcut_section.dart';
import 'package:bujuan/ui/pages/user/widgets/recent_playback_strip.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:flutter/material.dart';

/// 方屏个人页中的资料库页片。
class SquareLibraryPage extends StatelessWidget {
  /// 创建方屏资料库页片。
  const SquareLibraryPage({
    super.key,
    required this.metrics,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.recentPlaybackController,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        cacheExtent: 120,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: RecentPlaybackStrip(
              controller: recentPlaybackController,
              playbackAction: playbackAction,
            ),
          ),
          SliverToBoxAdapter(
            child: FrequentPlaylistSection(
              libraryController: libraryController,
              recommendationController: recommendationController,
              playbackAction: playbackAction,
              albumCountInWidget: metrics.squarePlaylistCardCount,
              headerHeight: metrics.squareHeaderHeight,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingSmall),
          ),
          SliverToBoxAdapter(
            child: LibraryShortcutSection(
              libraryController: libraryController,
              headerHeight: metrics.squareHeaderHeight,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingSmall),
          ),
        ],
      ),
    );
  }
}
