import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/frequent_playlist_section.dart';
import 'package:bujuan/ui/pages/user/widgets/library_shortcut_section.dart';
import 'package:bujuan/ui/pages/user/widgets/quick_start_section.dart';
import 'package:bujuan/ui/pages/user/widgets/recent_playback_strip.dart';
import 'package:bujuan/ui/pages/user/widgets/recommended_playlist_slivers.dart';
import 'package:bujuan/ui/pages/user/widgets/square_library_page.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
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
        return _SquarePersonalPageView(
          metrics: layoutMetrics,
          recommendationController: recommendationController,
          libraryController: libraryController,
          playbackAction: playbackAction,
          recentPlaybackController: recentPlaybackController,
          shellController: controller,
        );
      }
      return AppSmartRefresher(
        controller: recommendationController.refreshController,
        enablePullUp: true,
        onLoading: () => recommendationController.updateRecoPlayLists(getMore: true),
        child: CustomScrollView(cacheExtent: 120, physics: const ClampingScrollPhysics(), slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: context.mediaQueryPadding.top,
            ),
          ),
          SliverToBoxAdapter(
            child: QuickStartSection(
              itemCountInScreen: userItemCountInScreen,
              recommendationController: recommendationController,
              libraryController: libraryController,
              playbackAction: playbackAction,
              shellController: controller,
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
              playbackAction: playbackAction,
              albumCountInWidget: albumCountInScreen,
              headerTopMargin: AppDimensions.paddingSmall,
            ),
          ),
          const SliverToBoxAdapter(
            child: LibraryShortcutSection(
              headerTopMargin: AppDimensions.paddingSmall,
            ),
          ),
          const RecommendedPlaylistPinnedHeaderSliver(),
          RecommendedPlaylistListSliver(controller: recommendationController),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
          ),
        ]),
      );
    });
  }
}

class _SquarePersonalPageView extends StatefulWidget {
  const _SquarePersonalPageView({
    required this.metrics,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.recentPlaybackController,
    required this.shellController,
  });

  final PersonalHomeLayoutMetrics metrics;
  final RecommendationController recommendationController;
  final UserLibraryController libraryController;
  final PlayerController playbackAction;
  final RecentPlaybackController recentPlaybackController;
  final ShellController shellController;

  @override
  State<_SquarePersonalPageView> createState() => _SquarePersonalPageViewState();
}

class _SquarePersonalPageViewState extends State<_SquarePersonalPageView> {
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
