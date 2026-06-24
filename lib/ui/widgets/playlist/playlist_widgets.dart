import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/ui/assets/app_assets.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// 首页和资料库横向歌单轨道的预缓存边界。
const double playlistRailCacheExtent = 360;

class _PlaylistWidgetMetrics {
  const _PlaylistWidgetMetrics();

  double cardGap(double albumWidth) => (albumWidth * 0.04).clamp(6.0, 10.0);

  double cardTitleFontSize(double albumWidth) {
    return (albumWidth * 0.12).clamp(13.0, 16.0);
  }

  double cardSubtitleFontSize(double albumWidth) {
    return (albumWidth * 0.1).clamp(11.0, 13.0);
  }

  double cardTextBlockHeight({
    required double albumWidth,
    required bool showSongCount,
  }) {
    final titleLines = showSongCount ? 1 : 2;
    final titleHeight = cardTitleFontSize(albumWidth) * 1.15 * titleLines;
    final subtitleHeight = showSongCount ? cardSubtitleFontSize(albumWidth) * 1.2 : 0;
    return titleHeight + subtitleHeight;
  }

  double cardViewportHeight({
    required double albumWidth,
    required bool showSongCount,
  }) {
    return albumWidth +
        cardGap(albumWidth) +
        cardTextBlockHeight(
          albumWidth: albumWidth,
          showSongCount: showSongCount,
        );
  }

  double playButtonSize(double albumWidth) {
    return (albumWidth * 0.28).clamp(32.0, 46.0);
  }
}

/// 歌单列表项，点击后进入歌单详情页。
class PlayListItem extends StatelessWidget {
  /// 歌单摘要。
  final PlaylistSummaryData play;

  /// 跳转前执行的可选动作。
  final Function()? beforeOnTap;

  /// 创建歌单列表项。
  const PlayListItem(this.play, {Key? key, this.beforeOnTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = context.router;
    return UniversalListTile(
      picUrl: play.coverUrl,
      titleString: play.title,
      subTitleString: play.trackCount == null || play.trackCount == 0 ? null : "${play.trackCount}首",
      onTap: () async {
        if (beforeOnTap != null) {
          await beforeOnTap!();
        }
        router.push(
          gr.PlayListRouteView(
            playlistId: play.id,
            playlistName: play.title,
            coverUrl: play.coverUrl,
            trackCount: play.trackCount,
          ),
        );
      },
    );
  }
}

/// 歌单卡片既负责展示，也负责触发“播放整个歌单”，因此归在 playlist feature 比挂在 common 更合适。
class PlayListWidget extends StatelessWidget {
  /// 可视区域内期望展示的歌单数量。
  final double albumCountInWidget;

  /// 歌单卡片间距。
  final double albumMargin;

  /// 歌单列表。
  final List<PlaylistSummaryData> playLists;

  /// 是否展示歌曲数量。
  final bool showSongCount;

  /// 是否按整组歌单吸附滚动。
  final bool snappAllAlbum;

  /// 是否禁用横向滚动布局。
  final bool noScroll;

  /// 当前是否有歌单正在播放。
  final bool isPlaying;

  /// 当前正在播放的歌单名称。
  final String? playingPlaylistName;

  /// 点击播放歌单按钮时触发的回调。
  final Future<void> Function(PlaylistSummaryData playlist)? onPlayPlaylist;

  /// 根据卡片宽度计算横向区域高度。
  final double Function(double albumWidth)? heightForWidth;

  /// 创建横向歌单卡片列表。
  const PlayListWidget({
    Key? key,
    required this.playLists,
    this.albumCountInWidget = 2.5,
    this.albumMargin = 0,
    this.showSongCount = true,
    this.snappAllAlbum = false,
    this.noScroll = false,
    this.isPlaying = false,
    this.playingPlaylistName,
    this.onPlayPlaylist,
    this.heightForWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const metrics = _PlaylistWidgetMetrics();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (playLists.isEmpty) {
          return const SizedBox.shrink();
        }
        final maxWidth = constraints.maxWidth;
        final double effectiveCount = noScroll ? math.max(1, playLists.length).toDouble() : math.max(1.0, albumCountInWidget);
        final marginCount = noScroll ? math.max(1, playLists.length + 1) : albumCountInWidget.ceil();
        final availableWidth = math.max(0.0, maxWidth - albumMargin * marginCount);
        final albumWidth = availableWidth / effectiveCount;

        final naturalHeight = metrics.cardViewportHeight(
          albumWidth: albumWidth,
          showSongCount: showSongCount,
        );
        final customHeight = heightForWidth?.call(albumWidth);
        final widgetHeight = customHeight == null ? naturalHeight : math.max(customHeight, naturalHeight);
        final itemExtent = albumWidth + albumMargin;
        final snapCount = snappAllAlbum ? math.max(1, albumCountInWidget.floor()) : 1;
        final snapExtent = itemExtent * snapCount;
        return SizedBox(
          height: widgetHeight,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            cacheExtent: playlistRailCacheExtent,
            physics: SnappingScrollPhysics(
              itemExtent: snapExtent,
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(left: albumMargin),
                sliver: SliverFixedExtentList(
                  itemExtent: itemExtent,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final playlist = playLists[index];
                      final playButtonSize = metrics.playButtonSize(albumWidth);
                      return Padding(
                        padding: EdgeInsets.only(right: albumMargin),
                        child: GestureDetector(
                          onTap: () {
                            context.router.push(
                              gr.PlayListRouteView(
                                playlistId: playlist.id,
                                playlistName: playlist.title,
                                coverUrl: playlist.coverUrl,
                                trackCount: playlist.trackCount,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox.square(
                                dimension: albumWidth,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Positioned.fill(
                                      child: SimpleExtendedImage.avatar(
                                        width: albumWidth,
                                        height: albumWidth,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(albumMargin),
                                        ArtworkPathResolver.resolveDisplayPath(
                                          playlist.coverUrl,
                                        ),
                                      ),
                                    ),
                                    SizedBox.square(
                                      dimension: playButtonSize,
                                      child: Visibility(
                                        visible: isPlaying && playingPlaylistName == playlist.title,
                                        replacement: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: playButtonSize * 0.58,
                                          onPressed: onPlayPlaylist == null
                                              ? null
                                              : () => onPlayPlaylist!(
                                                    playlist,
                                                  ),
                                          icon: const Icon(
                                            TablerIcons.player_play_filled,
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Lottie.asset(
                                          AppAssets.lottieMusicPlaying,
                                          width: playButtonSize,
                                          height: playButtonSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: metrics.cardGap(albumWidth)),
                              Text(
                                playlist.title,
                                maxLines: showSongCount ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: metrics.cardTitleFontSize(albumWidth),
                                  height: 1.15,
                                ),
                              ),
                              if (showSongCount)
                                Text(
                                  playlist.trackCount == null || playlist.trackCount == 0 ? '' : '${playlist.trackCount}首',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: metrics.cardSubtitleFontSize(
                                      albumWidth,
                                    ),
                                    height: 1.2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    addAutomaticKeepAlives: false,
                    childCount: playLists.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
