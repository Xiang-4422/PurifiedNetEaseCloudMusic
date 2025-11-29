import 'package:blurrycontainer/blurrycontainer.dart';
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
            PinnedHeaderSliver(child: Container(height: context.mediaQueryPadding.top),),

            // 歌单广场
            SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Header('歌单广场', padding: AppDimensions.paddingSmall),
                    Expanded(child: Container()),
                    GestureDetector(
                      onTap: () {
                        if (controller.curTag.value != "全部") {
                          controller.curTag.value = "全部";
                          controller.updatePlayLists();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                        decoration: BoxDecoration(
                          color: controller.curTag.value == "全部" ? Colors.black.withAlpha(24) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text("全部"),
                      ),
                    )
                  ],
                ).paddingOnly(top: AppDimensions.paddingSmall, right: AppDimensions.paddingSmall)
            ),

            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
                child: Column(
                  spacing: AppDimensions.paddingSmall,
                  children: [
                    Container(
                      height: AppDimensions.headerHeight * 2/3,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.tagCategorys.value.length,
                          itemBuilder: (context, index) {
                            String categoryName = controller.tagCategorys.value[index];

                            return GestureDetector(
                              onTap: () => controller.curTagCategoryName.value = categoryName,
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                  decoration: BoxDecoration(
                                    color: controller.curTagCategoryName.value == categoryName ? Colors.black12 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                  ),
                                  child: Text(categoryName)
                              ),
                            );
                          }
                      ),
                    ),
                    Container(
                      height: AppDimensions.headerHeight * 2/3,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      clipBehavior: Clip.hardEdge,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.tags[controller.curTagCategoryName.value] == null ? 0 : controller.tags[controller.curTagCategoryName.value].length,
                          itemBuilder: (context, index) {
                            String tag = controller.tags[controller.curTagCategoryName.value][index];
                            return GestureDetector(
                              onTap: () {
                                controller.curTag.value = tag;
                                controller.updatePlayLists();
                              },
                              child: Obx(() => Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                    decoration: BoxDecoration(
                                      color: controller.curTag.value == tag ? Colors.black12 : Colors.transparent,
                                      // color: controller.curTag.value == tag ? Colors.transparent : Colors.black12,

                                      borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                    ),
                                    child: Text(tag)
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),


            SliverToBoxAdapter(
              child: Obx(() => PlayListWidget(playLists: controller.playLists.value, albumCountInWidget: 3.2, albumMargin: AppDimensions.paddingSmall, showSongCount: false,)),
            ),
            // // 排行榜
            // PinnedHeaderSliver(
            //   child: BlurryContainer(
            //       borderRadius: BorderRadius.circular(9999),
            //       color: Colors.black12,
            //       height: AppDimensions.headerHeight,
            //       padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
            //       // color: Colors.green,
            //       child: Stack(
            //         children: [
            //           // 榜单选择
            //           Visibility(
            //               visible: controller.showChoosePlayList.isTrue,
            //               replacement: Container(
            //                 alignment: Alignment.centerRight,
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     color: Colors.yellow,
            //                     borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
            //                   ),
            //                   child: Row(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       GestureDetector(
            //                         onTap: () => controller.showChoosePlayList.value = true,
            //                         child: Container(
            //                           padding: EdgeInsets.only(left: AppDimensions.headerHeight / 2),
            //                           child: Text(
            //                             maxLines: 1,
            //                             overflow: TextOverflow.ellipsis,
            //                             controller.curTopPlayListName.value,
            //                           ),
            //                         ),
            //                       ),
            //                       IconButton(
            //                         onPressed: () => controller.playCurRankingPlayListSongs(),
            //                         iconSize: AppDimensions.headerHeight,
            //                         padding: EdgeInsets.all(AppDimensions.headerHeight / 6),
            //                         icon: Icon(
            //                           TablerIcons.player_play_filled,
            //                           color: Colors.white,
            //                           size: AppDimensions.headerHeight * 2/3,
            //                         ),
            //                         style: IconButton.styleFrom(
            //                           backgroundColor: Colors.red,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //               child: Container(
            //                 alignment: Alignment.center,
            //                 child: Container(
            //                   height: AppDimensions.headerHeight ,
            //                   clipBehavior: Clip.hardEdge,
            //                   decoration: BoxDecoration(
            //                     color: Colors.yellow,
            //                     borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
            //                   ),
            //                   child:
            //                 ),
            //               )
            //           ),
            //           // 榜单分类
            //           Visibility(
            //             visible: controller.showChoosePlayList.isFalse,
            //             child: Visibility(
            //                 visible: controller.showChooseCategory.isTrue,
            //                 replacement: GestureDetector(
            //                     onTap: () => controller.showChooseCategory.value = true,
            //                     child: Header(controller.curTopPlayListCategoryName.value)
            //                 ),
            //                 child: Container(
            //                   alignment: Alignment.center,
            //                   child: Container(
            //                     height: AppDimensions.headerHeight ,
            //                     clipBehavior: Clip.hardEdge,
            //                     decoration: BoxDecoration(
            //                       color: Colors.yellow,
            //                       borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
            //                     ),
            //                     child: ,
            //                   ),
            //                 )
            //             ),
            //           ),
            //         ],
            //       )
            //   ).marginOnly(top: AppDimensions.paddingSmall),
            // ),

            // 排行榜分类
            PinnedHeaderSliver(
              child: BlurryContainer(
                borderRadius: BorderRadius.circular(9999),
                color: Colors.white70,
                padding: EdgeInsetsGeometry.zero,
                child: Header(controller.curTopPlayListName.value).marginOnly(left: AppDimensions.paddingSmall),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
                child: Column(
                  spacing: AppDimensions.paddingSmall,
                  children: [
                    Container(
                      height: AppDimensions.headerHeight * 2/3,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.topPlayListCategoryNames.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => controller.changeCurTopPlayListCategory(controller.topPlayListCategoryNames[index]),
                            child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                decoration: BoxDecoration(
                                  color: controller.curTopPlayListCategoryName.value == controller.topPlayListCategoryNames[index] ? Colors.black12 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                ),
                                child: Text(controller.topPlayListCategoryNames[index])
                            ),
                          );
                        }
                      ),
                    ),
                    Container(
                      height: AppDimensions.headerHeight * 2/3,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      clipBehavior: Clip.hardEdge,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.curCategoryTopPlayLists.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => controller.changeCurTopPlayList(controller.curCategoryTopPlayLists[index]),
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                  decoration: BoxDecoration(
                                    color: controller.curTopPlayListName.value == controller.curCategoryTopPlayLists[index]["name"]! ? Colors.black12 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                  ),
                                  child: Text(controller.curCategoryTopPlayLists[index]["name"]!)
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
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

/// 自动尺寸的 SliverPersistentHeader 包装组件
class AutoSizeSliverPersistentHeader extends StatefulWidget {
  final Widget persistentHeader;
  final Widget foldableWidget;

  const AutoSizeSliverPersistentHeader({
    Key? key,
    required this.persistentHeader,
    required this.foldableWidget,
  }) : super(key: key);

  @override
  _AutoSizeSliverHeaderState createState() => _AutoSizeSliverHeaderState();
}
class _AutoSizeSliverHeaderState extends State<AutoSizeSliverPersistentHeader> {
  final GlobalKey _measurePersistentHeaderKey = GlobalKey();
  final GlobalKey _measureFoldableWidgetKey = GlobalKey();
  double? _measuredPersistentHeaderHeight;
  double? _measuredFoldableWidgetHeight;

  bool _isMeasuring = true;

  @override
  void initState() {
    super.initState();
    // 在下一帧测量组件尺寸
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureContentSize();
    });
  }

  @override
  void didUpdateWidget(covariant AutoSizeSliverPersistentHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果构建器发生变化，重新测量
    if (oldWidget.persistentHeader != widget.persistentHeader || oldWidget.foldableWidget != widget.foldableWidget) {
      setState(() {
        _isMeasuring = true;
        _measuredPersistentHeaderHeight = null;
        _measuredFoldableWidgetHeight = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureContentSize();
      });
    }
  }

  void _measureContentSize() {
    try {
      if (_measurePersistentHeaderKey.currentContext != null && _measureFoldableWidgetKey.currentContext != null) {
        setState(() {
          _measuredPersistentHeaderHeight = (_measurePersistentHeaderKey.currentContext!.findRenderObject() as RenderBox).size.height;
          _measuredFoldableWidgetHeight = (_measureFoldableWidgetKey.currentContext!.findRenderObject() as RenderBox).size.height;
          _isMeasuring = false;
        });
      }
    } catch (e) {
      // 处理测量错误，使用默认高度
      print('测量组件高度时出错: $e');
      setState(() {
        _measuredPersistentHeaderHeight = 100; // 默认高度
        _measuredFoldableWidgetHeight = 100;
        _isMeasuring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果正在测量或尚未测量完成，渲染测量用的组件
    if (_isMeasuring || _measuredPersistentHeaderHeight == null || _measuredFoldableWidgetHeight == null) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            Container(
              key: _measurePersistentHeaderKey,
              child: widget.persistentHeader,
            ),
            Container(
              key: _measureFoldableWidgetKey,
              child: widget.foldableWidget,
            ),
          ],
        ),
      );
    }

    // 测量完成后，渲染实际的 SliverPersistentHeader
    return SliverPersistentHeader(
      delegate: _AutoSizeSliverPersistentHeaderDelegate(
        minExtent: _measuredPersistentHeaderHeight ?? 100,
        maxExtent: (_measuredPersistentHeaderHeight ?? 100) + (_measuredFoldableWidgetHeight ?? 100),
        child: Column(
          children: [
            Container(
              height: _measuredPersistentHeaderHeight,
              key: _measurePersistentHeaderKey,
              child: widget.persistentHeader,
            ),
            Expanded(
              child: Container(
                key: _measureFoldableWidgetKey,
                child: widget.foldableWidget,
              ),
            ),
          ],
        ),
      ),
      pinned: true,
    );
  }
}
/// 自定义的 SliverPersistentHeaderDelegate
class _AutoSizeSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _AutoSizeSliverPersistentHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  final double minExtent;
  final double maxExtent;
  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_AutoSizeSliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.child != child;
  }
}
