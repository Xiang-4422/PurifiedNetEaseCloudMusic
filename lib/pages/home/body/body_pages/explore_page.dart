import 'package:bujuan/common/common_widget.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../play_list/playlist_page_view.dart';
import '../../../../controllers/explore_page_controller.dart';

/// 发现页
class ExplorePageView extends GetView<ExplorePageController> {
  const ExplorePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.isTrue) return const LoadingView();
      return SmartRefresher(
        onRefresh: () => controller.updateData(),
        enablePullUp: true,
        onLoading: () => controller.updateRankingPlayListSongs(offset: controller.curTopPlayListSongs.length),
        footer: ClassicFooter(
          height: 60 + AppDimensions.bottomPanelHeaderHeight,
          outerBuilder:(child){
            return Container(
              height: 60,
              margin: EdgeInsets.only(bottom: AppDimensions.bottomPanelHeaderHeight),
              alignment: Alignment.center,
              child: child
            );
          }
        ),
        controller: controller.refreshController,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: context.mediaQueryPadding.top),),

            // 歌单广场
            SliverToBoxAdapter(
                child: Header('歌单广场', padding: AppDimensions.paddingSmall).paddingOnly(top: AppDimensions.paddingSmall)
            ),
            SliverToBoxAdapter(
              child: Obx(() => PlayListWidget(playLists: controller.hqPlaylists.value, albumCountInWidget: 3.2, albumMargin: AppDimensions.paddingSmall, showSongCount: false,)),
            ),

            // 排行榜
            SliverToBoxAdapter(
              child: Container(
                  height: AppDimensions.headerHeight,
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                  // color: Colors.green,
                  child: Stack(
                    children: [
                      // 榜单选择
                      Visibility(
                          visible: controller.showChoosePlayList.isTrue,
                          replacement: Container(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => controller.showChoosePlayList.value = true,
                                    child: Container(
                                      padding: EdgeInsets.only(left: AppDimensions.headerHeight / 2),
                                      child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        controller.curTopPlayListName.value,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => controller.playCurRankingPlayListSongs(),
                                    iconSize: AppDimensions.headerHeight,
                                    padding: EdgeInsets.all(AppDimensions.headerHeight / 6),
                                    icon: Icon(
                                      TablerIcons.player_play_filled,
                                      color: Colors.white,
                                      size: AppDimensions.headerHeight * 2/3,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Container(
                              height: AppDimensions.headerHeight ,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                              ),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.curCategoryTopPlayLists.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => controller.changeCurTopPlayList(controller.curCategoryTopPlayLists[index]),
                                      child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 2),
                                          decoration: BoxDecoration(
                                            color: controller.curTopPlayListName.value == controller.curCategoryTopPlayLists[index]["name"]! ? Colors.red : Colors.transparent,
                                            borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                          ),
                                          child: Text(controller.curCategoryTopPlayLists[index]["name"]!)
                                      ),
                                    );
                                  }
                              ),
                            ),
                          )
                      ),
                      // 榜单分类
                      Visibility(
                        visible: controller.showChoosePlayList.isFalse,
                        child: Visibility(
                            visible: controller.showChooseCategory.isTrue,
                            replacement: GestureDetector(
                                onTap: () => controller.showChooseCategory.value = true,
                                child: Header(controller.curTopPlayListCategoryName.value)
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Container(
                                height: AppDimensions.headerHeight ,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                ),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.topPlayListCategoryNames.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () => controller.changeCurTopPlayListCategory(controller.topPlayListCategoryNames[index]),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 2),
                                            decoration: BoxDecoration(
                                              color: controller.curTopPlayListCategoryName.value == controller.topPlayListCategoryNames[index] ? Colors.red : Colors.transparent,
                                              borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                            ),
                                            child: Text(controller.topPlayListCategoryNames[index])
                                        ),
                                      );
                                    }
                                ),
                              ),
                            )
                        ),
                      ),
                    ],
                  )
              ).marginOnly(top: AppDimensions.paddingSmall),
            ),
            SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index) => SongItem(
                    index: index,
                    playlist: controller.curTopPlayListSongs.value,
                    playListName: controller.curTopPlayListName.value,
                    showIndex: true,
                  ).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              childCount: controller.curTopPlayListSongs.length,

            )),
          ],
        ),
      );
    });
  }
}
