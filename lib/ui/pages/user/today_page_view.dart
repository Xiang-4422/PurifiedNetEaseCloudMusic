import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

/// 每日推荐歌曲页面。
class TodayPageView extends GetView<RecommendationController> {
  /// 创建每日推荐歌曲页面。
  const TodayPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final songs = controller.todayRecommendSongs;
    final albumUrl = songs.isEmpty
        ? ''
        : ArtworkPathResolver.resolvePlaybackArtwork(
              artworkUrl: songs.first.artworkUrl,
              localArtworkPath: songs.first.localArtworkPath,
            ) ??
            '';
    final localAlbumPath = ArtworkPathResolver.resolveDisplayPath(albumUrl);
    final layoutMetrics = AdaptiveLayoutMetrics.of(context);
    final canPlayDailyRecommendations = songs.isNotEmpty;
    final playAllLabel = todayPlayAllControlLabel(
      hasSongs: canPlayDailyRecommendations,
    );

    return Container(
      color: Colors.white,
      child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          toolbarHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
          collapsedHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
          expandedHeight: layoutMetrics.heroExtent,
          pinned: true,
          stretch: true,
          automaticallyImplyLeading: false,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const <StretchMode>[
              StretchMode.zoomBackground, // 背景图缩放
              // StretchMode.blurBackground, // 背景图模糊
              // StretchMode.fadeTitle,      // 标题渐隐
            ],
            titlePadding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium, left: AppDimensions.paddingMedium, right: AppDimensions.paddingMedium),
            title: BlurryContainer(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(9999),
              color: Colors.white.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Text(
                            " 每日推荐",
                            maxLines: 1,
                            style: context.textTheme.titleLarge!.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            " 每日推荐",
                            maxLines: 1,
                            style: context.textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  BlurryContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(9999),
                    color: Colors.red.withValues(
                      alpha: canPlayDailyRecommendations ? 1 : 0.45,
                    ),
                    child: IconButton(
                      tooltip: playAllLabel,
                      icon: Icon(
                        TablerIcons.player_play_filled,
                        color: Colors.white.withValues(
                          alpha: canPlayDailyRecommendations ? 1 : 0.6,
                        ),
                      ),
                      onPressed: canPlayDailyRecommendations
                          ? () => playerController.playPlaylist(
                                songs,
                                0,
                                playListName: "每日推荐",
                              )
                          : null,
                    ),
                  )
                ],
              ),
            ),
            // centerTitle: true,
            expandedTitleScale: 1.5,
            background: SimpleExtendedImage(
              width: context.width,
              height: layoutMetrics.heroExtent,
              localAlbumPath,
            ),
          ),
          // bottom:
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: songs.length + 1,
            (BuildContext context, int index) {
              if (index == songs.length) {
                return const SizedBox(
                  height: AppDimensions.bottomPanelHeaderHeight,
                );
              }
              return SongItem(playlist: songs, index: index, playListName: "今日推荐", stringColor: Colors.black, showIndex: true, onPlay: playerController.playPlaylist).paddingSymmetric(horizontal: AppDimensions.paddingMedium);
            },
          ),
        ),
      ]),
    );
  }
}

/// 生成每日推荐头部播放按钮的稳定标签。
@visibleForTesting
String todayPlayAllControlLabel({required bool hasSongs}) {
  return hasSongs ? '播放每日推荐' : '每日推荐暂无歌曲';
}
