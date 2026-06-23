import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/frequent_playlist_section.dart';
import 'package:bujuan/ui/pages/user/widgets/library_shortcut_bar.dart';
import 'package:bujuan/ui/pages/user/widgets/quick_start_card_rail.dart';
import 'package:bujuan/ui/pages/user/widgets/recent_playback_strip.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

          // 马上开始 Header
          SliverToBoxAdapter(
            child: const Header('马上开始', padding: AppDimensions.paddingSmall).marginOnly(top: AppDimensions.paddingSmall),
          ),

          // 快速播放卡片
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double userItemWidth = (constraints.maxWidth - AppDimensions.paddingSmall * userItemCountInScreen.ceil()) / userItemCountInScreen;
                final cardHeight = userItemWidth * 1.3;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  height: cardHeight,
                  child: QuickStartCardRail(
                    width: userItemWidth,
                    height: cardHeight,
                    recommendationController: recommendationController,
                    libraryController: libraryController,
                    playbackAction: playbackAction,
                    shellController: controller,
                  ),
                );
              },
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
          SliverToBoxAdapter(
            child: const Header('资料库', padding: AppDimensions.paddingSmall).marginOnly(top: AppDimensions.paddingSmall),
          ),
          const SliverToBoxAdapter(
            child: LibraryShortcutBar(),
          ),

          // 推荐歌单 Header
          SliverLayoutBuilder(
            builder: (BuildContext context, SliverConstraints constraints) {
              // 计算是否处于悬浮状态
              // 当 scrollOffset > 0 时，说明 Header 已经触顶并开始“固定”了
              final bool isPinned = constraints.scrollOffset > 0;
              return PinnedHeaderSliver(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Colors.white,
                  padding: isPinned ? EdgeInsets.only(top: context.mediaQueryPadding.top) : EdgeInsets.zero,
                  child: const Header('推荐歌单', padding: AppDimensions.paddingSmall),
                ),
              );
            },
          ),
          // 推荐歌单列表
          SliverList.builder(
            itemCount: recommendationController.recoPlayLists.length,
            itemBuilder: (BuildContext context, int index) {
              return PlayListItem(recommendationController.recoPlayLists[index]).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
            },
          ),
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
              _buildQuickStartPage(context),
              _buildLibraryPage(context),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
      ],
    );
  }

  Widget _buildQuickStartPage(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentHeight = constraints.maxHeight - widget.metrics.squareHeaderHeight - AppDimensions.paddingSmall * 2;
          final cardSize = widget.metrics.squareQuickCardSize(
            maxWidth: constraints.maxWidth,
            maxHeight: contentHeight,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                '马上开始',
                padding: AppDimensions.paddingSmall,
                height: widget.metrics.squareHeaderHeight,
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: cardSize.height,
                    child: _buildQuickStartCards(
                      context,
                      cardSize: cardSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLibraryPage(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        cacheExtent: 120,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: RecentPlaybackStrip(
              controller: widget.recentPlaybackController,
              playbackAction: widget.playbackAction,
            ),
          ),
          SliverToBoxAdapter(
            child: FrequentPlaylistSection(
              libraryController: widget.libraryController,
              playbackAction: widget.playbackAction,
              albumCountInWidget: widget.metrics.squarePlaylistCardCount,
              headerHeight: widget.metrics.squareHeaderHeight,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingSmall),
          ),
          SliverToBoxAdapter(
            child: Header(
              '资料库',
              padding: AppDimensions.paddingSmall,
              height: widget.metrics.squareHeaderHeight,
            ),
          ),
          const SliverToBoxAdapter(
            child: LibraryShortcutBar(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingSmall),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartCards(
    BuildContext context, {
    required Size cardSize,
  }) {
    return QuickStartCardRail(
      width: cardSize.width,
      height: cardSize.height,
      recommendationController: widget.recommendationController,
      libraryController: widget.libraryController,
      playbackAction: widget.playbackAction,
      shellController: widget.shellController,
    );
  }
}

/// 方屏首页侧边菜单中的独立推荐歌单页。
class RecommendedPlaylistsPageView extends StatelessWidget {
  /// 创建独立推荐歌单页。
  const RecommendedPlaylistsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final recommendationController = RecommendationController.to;
    return Obx(() {
      if (recommendationController.dateLoaded.isFalse) {
        return const LoadingView();
      }
      return AppSmartRefresher(
        controller: recommendationController.refreshController,
        enablePullUp: true,
        onLoading: () => recommendationController.updateRecoPlayLists(getMore: true),
        child: CustomScrollView(
          cacheExtent: 120,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.mediaQueryPadding.top),
            ),
            const SliverToBoxAdapter(
              child: Header(
                '推荐歌单',
                padding: AppDimensions.paddingSmall,
              ),
            ),
            SliverList.builder(
              itemCount: recommendationController.recoPlayLists.length,
              itemBuilder: (BuildContext context, int index) {
                return PlayListItem(recommendationController.recoPlayLists[index]).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
            ),
          ],
        ),
      );
    });
  }
}
