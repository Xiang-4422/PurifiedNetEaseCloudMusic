import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/recommended_playlist_slivers.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              child: SizedBox(height: MediaQuery.paddingOf(context).top),
            ),
            const RecommendedPlaylistHeaderSliver(),
            RecommendedPlaylistListSliver(controller: recommendationController),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
            ),
          ],
        ),
      );
    });
  }
}
