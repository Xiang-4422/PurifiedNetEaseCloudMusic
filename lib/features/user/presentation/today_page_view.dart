import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/application/playback_action_port.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

/// TodayPageView。
class TodayPageView extends StatelessWidget {
  /// 创建 TodayPageView。
  const TodayPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playbackAction = Get.find<PlaybackActionPort>();
    final songs = RecommendationController.to.todayRecommendSongs;
    final albumUrl = songs.isEmpty ? '' : songs.first.artworkUrl ?? '';
    final localAlbumPath = ArtworkPathResolver.resolveDisplayPath(albumUrl);

    return Container(
      color: Colors.white,
      child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          toolbarHeight: AppDimensions.appBarHeight -
              context.mediaQueryPadding.top +
              AppDimensions.paddingLarge,
          collapsedHeight: AppDimensions.appBarHeight -
              context.mediaQueryPadding.top +
              AppDimensions.paddingLarge,
          expandedHeight: context.width - context.mediaQueryPadding.top,
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
            titlePadding: const EdgeInsets.only(
                bottom: AppDimensions.paddingMedium,
                left: AppDimensions.paddingMedium,
                right: AppDimensions.paddingMedium),
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
                    color: Colors.red,
                    child: IconButton(
                        icon: const Icon(
                          TablerIcons.player_play_filled,
                          color: Colors.white,
                        ),
                        onPressed: () => playbackAction.playPlaylist(
                              songs,
                              0,
                              playListName: "每日推荐",
                            )),
                  )
                ],
              ),
            ),
            // centerTitle: true,
            expandedTitleScale: 1.5,
            background: SimpleExtendedImage(
              width: context.width,
              height: context.width,
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
              return SongItem(
                      playlist: songs,
                      index: index,
                      playListName: "今日推荐",
                      stringColor: Colors.black,
                      showIndex: true,
                      onPlay: playbackAction.playPlaylist)
                  .paddingSymmetric(horizontal: AppDimensions.paddingMedium);
            },
          ),
        ),
      ]),
    );
  }
}
