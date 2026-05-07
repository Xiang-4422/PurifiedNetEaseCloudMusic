import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/app/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/app/theme/app_constants.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';

Future<void> _playPlaylistSummary(PlaylistSummaryData playlist) async {
  final playerController = Get.find<PlayerController>();
  if (playerController.sessionState.value.playlistName == playlist.title) {
    await playerController.playOrPause();
    return;
  }
  final likedSongIds = UserLibraryController.to.likedSongIds.toList();
  final repository = Get.find<PlaylistRepository>();
  final index = await repository.fetchPlaylistIndex(
    playlist.id,
    likedSongIds: likedSongIds,
  );
  final songs = await repository.fetchPlaylistSongs(
    playlistId: playlist.id,
    likedSongIds: likedSongIds,
    playlistIndex: index,
  );
  await playerController.playPlaylist(
    songs,
    0,
    playListName: index.name,
    playListNameHeader: '歌单',
  );
}

/// 探索页当前仍直接消费首页控制器驱动的刷新节奏，所以先和 home body 放在同一层，避免再引入一层页面目录。
class ExplorePageView extends GetView<ExplorePageController> {
  /// 创建探索页视图。
  const ExplorePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playbackAction = Get.find<PlayerController>();
    final layoutMetrics = AdaptiveLayoutMetrics.of(context);
    final tagStripHeight = (34 * layoutMetrics.textScale).clamp(34.0, 44.0).toDouble();
    return Obx(() {
      if (controller.loading.isTrue) return const LoadingView();
      return AppSmartRefresher(
        controller: controller.refreshController,
        enablePullUp: true,
        onLoading: () => controller.updateRankingPlayListSongs(offset: controller.curTopPlayListSongs.length),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            PinnedHeaderSliver(
              child: Container(height: context.mediaQueryPadding.top),
            ),

            // 歌单广场
            SliverToBoxAdapter(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Header('歌单广场', padding: AppDimensions.paddingSmall),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    if (controller.curTag.value != "全部") {
                      controller.curTag.value = "全部";
                      controller.updatePlayLists();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                    decoration: BoxDecoration(
                      color: controller.curTag.value == "全部" ? Colors.black.withAlpha(24) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text("全部"),
                  ),
                )
              ],
            ).paddingOnly(top: AppDimensions.paddingSmall, right: AppDimensions.paddingSmall)),

            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
                child: Column(
                  spacing: AppDimensions.paddingSmall,
                  children: [
                    Container(
                      height: tagStripHeight,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.tagCategorys.length,
                          itemBuilder: (context, index) {
                            String categoryName = controller.tagCategorys[index];

                            return GestureDetector(
                              onTap: () => controller.curTagCategoryName.value = categoryName,
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                  decoration: BoxDecoration(
                                    color: controller.curTagCategoryName.value == categoryName ? Colors.black12 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                  ),
                                  child: Text(categoryName)),
                            );
                          }),
                    ),
                    Container(
                      height: tagStripHeight,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
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
                              child: Obx(
                                () => Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                    decoration: BoxDecoration(
                                      color: controller.curTag.value == tag ? Colors.black12 : Colors.transparent,
                                      // color: controller.curTag.value == tag ? Colors.transparent : Colors.black12,

                                      borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                    ),
                                    child: Text(tag)),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Obx(() => PlayListWidget(
                    playLists: controller.playLists,
                    albumCountInWidget: 3.2,
                    albumMargin: AppDimensions.paddingSmall,
                    showSongCount: false,
                    isPlaying: playbackAction.isPlaying.value,
                    playingPlaylistName: playbackAction.sessionState.value.playlistName,
                    onPlayPlaylist: _playPlaylistSummary,
                  )),
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
                padding: EdgeInsets.zero,
                child: Header(controller.curTopPlayListName.value).marginOnly(left: AppDimensions.paddingSmall),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
                child: Column(
                  spacing: AppDimensions.paddingSmall,
                  children: [
                    Container(
                      height: AppDimensions.headerHeight * 2 / 3,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.topPlayListCategoryNames.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => controller.changeCurTopPlayListCategory(controller.topPlayListCategoryNames[index]),
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                  decoration: BoxDecoration(
                                    color: controller.curTopPlayListCategoryName.value == controller.topPlayListCategoryNames[index] ? Colors.black12 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                  ),
                                  child: Text(controller.topPlayListCategoryNames[index])),
                            );
                          }),
                    ),
                    Container(
                      height: AppDimensions.headerHeight * 2 / 3,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      clipBehavior: Clip.hardEdge,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.curCategoryTopPlayLists.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => controller.changeCurTopPlayList(controller.curCategoryTopPlayLists[index]),
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.headerHeight / 4),
                                  decoration: BoxDecoration(
                                    color: controller.curTopPlayListName.value == controller.curCategoryTopPlayLists[index].name ? Colors.black12 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
                                  ),
                                  child: Text(controller.curCategoryTopPlayLists[index].name)),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) => SongItem(
                index: index,
                playlist: controller.curTopPlayListSongs,
                playListName: controller.curTopPlayListName.value,
                showIndex: true,
                onPlay: playbackAction.playPlaylist,
              ).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
              addAutomaticKeepAlives: false,
              childCount: controller.curTopPlayListSongs.length,
            )),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
            ),
          ],
        ),
      );
    });
  }
}

/// 自动尺寸的 SliverPersistentHeader 包装组件
class AutoSizeSliverPersistentHeader extends StatefulWidget {
  /// 固定显示的 header 内容。
  final Widget persistentHeader;

  /// 可折叠区域内容。
  final Widget foldableWidget;

  /// 创建自动测量高度的 SliverPersistentHeader。
  const AutoSizeSliverPersistentHeader({
    Key? key,
    required this.persistentHeader,
    required this.foldableWidget,
  }) : super(key: key);

  @override
  State<AutoSizeSliverPersistentHeader> createState() => _AutoSizeSliverHeaderState();
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
            SizedBox(
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

  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_AutoSizeSliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.minExtent != minExtent || oldDelegate.maxExtent != maxExtent || oldDelegate.child != child;
  }
}
