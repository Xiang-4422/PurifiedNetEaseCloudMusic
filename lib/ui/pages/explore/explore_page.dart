import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/ui/pages/explore/widgets/explore_filter_strip.dart';
import 'package:bujuan/ui/pages/explore/widgets/explore_ranking_song_list_sliver.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';

Future<void> _playPlaylistSummary(
  ExplorePageController controller,
  PlayerController playerController,
  PlaylistSummaryData playlist,
) async {
  if (playerController.sessionState.value.playlistName == playlist.title) {
    await playerController.playOrPause();
    return;
  }
  final plan = await controller.resolvePlaylistPlayback(playlist);
  await playerController.playPlaylist(
    plan.songs,
    0,
    playListName: plan.playlistName,
    playListNameHeader: '歌单',
  );
}

/// 探索页当前仍直接消费首页控制器驱动的刷新节奏，所以先和 home body 放在同一层，避免再引入一层页面目录。
class ExplorePageView extends GetView<ExplorePageController> {
  /// 创建探索页视图。
  const ExplorePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
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
                    ExploreFilterStrip<String>(
                      items: List<String>.from(controller.tagCategorys),
                      height: tagStripHeight,
                      labelOf: (categoryName) => categoryName,
                      isSelected: (categoryName) => controller.curTagCategoryName.value == categoryName,
                      onSelected: (categoryName) => controller.curTagCategoryName.value = categoryName,
                    ),
                    ExploreFilterStrip<String>(
                      items: List<String>.from(
                        controller.tags[controller.curTagCategoryName.value] ?? const <String>[],
                      ),
                      height: tagStripHeight,
                      labelOf: (tag) => tag,
                      isSelected: (tag) => controller.curTag.value == tag,
                      onSelected: (tag) {
                        controller.curTag.value = tag;
                        controller.updatePlayLists();
                      },
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
                    isPlaying: playerController.isPlaying.value,
                    playingPlaylistName: playerController.sessionState.value.playlistName,
                    onPlayPlaylist: (playlist) => _playPlaylistSummary(
                      controller,
                      playerController,
                      playlist,
                    ),
                  )),
            ),
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
                    ExploreFilterStrip<String>(
                      items: controller.topPlayListCategoryNames,
                      height: AppDimensions.headerHeight * 2 / 3,
                      labelOf: (categoryName) => categoryName,
                      isSelected: (categoryName) => controller.curTopPlayListCategoryName.value == categoryName,
                      onSelected: controller.changeCurTopPlayListCategory,
                    ),
                    ExploreFilterStrip(
                      items: controller.curCategoryTopPlayLists.toList(),
                      height: AppDimensions.headerHeight * 2 / 3,
                      labelOf: (playlist) => playlist.name,
                      isSelected: (playlist) => controller.curTopPlayListName.value == playlist.name,
                      onSelected: controller.changeCurTopPlayList,
                    ),
                  ],
                ),
              ),
            ),
            ExploreRankingSongListSliver(
              songs: controller.curTopPlayListSongs,
              playlistName: controller.curTopPlayListName.value,
              onPlay: playerController.playPlaylist,
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
