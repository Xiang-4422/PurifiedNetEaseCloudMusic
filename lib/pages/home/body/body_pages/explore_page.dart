import 'package:bujuan/common/common_widget.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../play_list/playlist_page_view.dart';
import '../../../../controllers/explore_page_controller.dart';

/// 发现页
class ExplorePageView extends GetView<ExplorePageController> {
  const ExplorePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
      visible: !controller.loading.value,
      replacement: const LoadingView(),
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.updateData();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: context.mediaQueryPadding.top),),

            // 精选歌单
            SliverToBoxAdapter(
              child: Header('精选歌单', padding: AppDimensions.paddingSmall).paddingOnly(top: AppDimensions.paddingSmall)
            ),
            SliverToBoxAdapter(
              child: Obx(() => PlayListWidget(playLists: controller.hqPlaylists.value, albumCountInWidget: 3.2, albumMargin: AppDimensions.paddingSmall, showSongCount: false,)),
            ),

            // 新歌推荐
            SliverToBoxAdapter(
              child: Header('新歌推荐', padding: AppDimensions.paddingSmall).paddingOnly(top: AppDimensions.paddingSmall)
            ),
            SliverList(delegate: SliverChildBuilderDelegate(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              childCount: controller.newSongs.length,
              (context, index) => SongItem(
                index: index,
                playlist: controller.newSongs,
              ).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
            )),

            const SliverPadding(padding: EdgeInsets.only(top: AppDimensions.bottomPanelHeaderHeight),),
          ],
        ),
      ),
    ));
  }
}
