import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/frequent_playlist_section.dart';
import 'package:bujuan/ui/pages/user/widgets/library_shortcut_section.dart';
import 'package:bujuan/ui/pages/user/widgets/quick_start_section.dart';
import 'package:bujuan/ui/pages/user/widgets/recent_playback_strip.dart';
import 'package:bujuan/ui/pages/user/widgets/recommended_playlist_slivers.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:flutter/material.dart';

/// 常规屏幕下的个人首页布局。
class StandardPersonalHomePage extends StatelessWidget {
  /// 创建常规个人首页布局。
  const StandardPersonalHomePage({
    super.key,
    required this.albumCountInScreen,
    required this.userItemCountInScreen,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.recentPlaybackController,
    required this.shellController,
  });

  /// 横向区域中一屏展示的歌单卡片数量。
  final double albumCountInScreen;

  /// 横向区域中一屏展示的快速入口卡片数量。
  final double userItemCountInScreen;

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
  Widget build(BuildContext context) {
    return AppSmartRefresher(
      controller: recommendationController.refreshController,
      enablePullUp: true,
      onLoading: () => recommendationController.updateRecoPlayLists(getMore: true),
      child: CustomScrollView(
        cacheExtent: 120,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).top,
            ),
          ),
          SliverToBoxAdapter(
            child: QuickStartSection(
              itemCountInScreen: userItemCountInScreen,
              recommendationController: recommendationController,
              libraryController: libraryController,
              playbackAction: playbackAction,
              shellController: shellController,
            ),
          ),
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
              albumCountInWidget: albumCountInScreen,
              headerTopMargin: AppDimensions.paddingSmall,
            ),
          ),
          SliverToBoxAdapter(
            child: LibraryShortcutSection(
              libraryController: libraryController,
              headerTopMargin: AppDimensions.paddingSmall,
            ),
          ),
          const RecommendedPlaylistPinnedHeaderSliver(),
          RecommendedPlaylistListSliver(controller: recommendationController),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
          ),
        ],
      ),
    );
  }
}
