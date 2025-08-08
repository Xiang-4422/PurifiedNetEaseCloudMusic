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
    return Visibility(
        visible: !controller.loading.value,
        replacement: const LoadingView(),
        child: Column(
          children:[
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(padding: EdgeInsets.only(top: context.mediaQueryPadding.top + AppDimensions.appBarHeight),),

                  // 推荐歌单
                  const SliverToBoxAdapter(
                      child: Header('推荐歌单')
                  ),
                  SliverList(delegate: SliverChildBuilderDelegate(
                    childCount: controller.playlists.length,
                    (BuildContext context, int index) => PlayListItem(controller.playlists[index])
                  )),
                  // 新歌推荐
                  const SliverToBoxAdapter(
                    child: Header('新歌推荐')
                  ),
                  SliverList(delegate: SliverChildBuilderDelegate(
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    childCount: controller.newSingles.length,
                    (context, index) => SongItem(
                      index: index,
                      playlist: controller.newSingles,
                    ),
                  )),

                  const SliverPadding(padding: EdgeInsets.only(top: AppDimensions.bottomPanelHeaderHeight),),
                ],
              ).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
            ),
          ],
        ),
      );
  }
}
