import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:bujuan/widget/scroll_helpers.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class _PlaylistWidgetMetrics {
  _PlaylistWidgetMetrics(this.context);

  final BuildContext context;

  double get _textScale {
    return MediaQuery.textScalerOf(context).scale(1);
  }

  double get tileMinHeight => 52;

  double get tileVerticalPadding => (6 * _textScale).clamp(6.0, 10.0);

  double get thumbnailSize => (44 * _textScale).clamp(40.0, 52.0);

  double get tileGap => AppDimensions.paddingSmall;

  double get trailingMaxWidth {
    final width = MediaQuery.sizeOf(context).width;
    return math.max(72, width * 0.28).clamp(72.0, 132.0).toDouble();
  }

  double get indexWidth => (28 * _textScale).clamp(26.0, 36.0);

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

/// 这批组件都围绕歌单、歌曲列表和播放入口组织，放回 playlist feature 比继续挂在页面文件或 common 更清晰。
class Header extends StatelessWidget {
  /// 标题文本。
  final String title;

  /// 标题容器内边距。
  final double padding;

  /// 标题容器高度。
  final double height;

  /// 创建列表分区标题。
  const Header(
    this.title, {
    Key? key,
    this.padding = 0,
    this.height = AppDimensions.headerHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}

/// 统一歌曲、歌单、专辑、歌手搜索结果的行结构，避免页面为了一个 list item 再各自复制样式。
class UniversalListTile extends StatelessWidget {
  /// 主标题文本。
  final String titleString;

  /// 副标题文本。
  final String? subTitleString;

  /// 左侧图片地址。
  final String? picUrl;

  /// 点击回调。
  final GestureTapCallback? onTap;

  /// 长按回调。
  final GestureTapCallback? onLongPress;

  /// 标题和副标题颜色。
  final Color? stringColor;

  /// 左侧自定义前导组件。
  final Widget? leading;

  /// 右侧附加组件。
  final Widget? trailing;

  /// 创建通用列表行。
  const UniversalListTile({
    super.key,
    required this.titleString,
    this.subTitleString,
    this.picUrl,
    this.stringColor,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = _PlaylistWidgetMetrics(context);
    final localPicPath = ArtworkPathResolver.resolveDisplayPath(picUrl);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: metrics.tileMinHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: metrics.tileVerticalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: metrics.indexWidth),
                  child: leading!,
                ),
                SizedBox(width: metrics.tileGap),
              ],
              if (localPicPath.isNotEmpty) ...[
                SizedBox.square(
                  dimension: metrics.thumbnailSize,
                  child: SimpleExtendedImage(
                    localPicPath,
                    width: metrics.thumbnailSize,
                    height: metrics.thumbnailSize,
                    cacheWidth: 120,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: metrics.tileGap),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleString,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: stringColor ?? context.theme.colorScheme.onPrimary,
                            height: 1.15,
                          ),
                    ),
                    if (subTitleString != null)
                      Text(
                        subTitleString!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: (stringColor ?? context.theme.colorScheme.onPrimary).withValues(alpha: 0.5),
                          height: 1.15,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: EdgeInsets.only(left: metrics.tileGap),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: metrics.trailingMaxWidth,
                    ),
                    child: trailing!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongIndexLeading extends StatelessWidget {
  const _SongIndexLeading({
    required this.index,
    required this.color,
  });

  final int index;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${index + 1}',
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.titleMedium?.copyWith(
        color: (color ?? context.theme.colorScheme.onPrimary).withValues(alpha: 0.55),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// `SongItem` 统一承接“点击即按当前上下文播放”的行为，避免每个页面再手写一次播放入口。
class SongItem extends StatelessWidget {
  /// 歌曲在播放队列中的索引。
  final int index;

  /// 当前歌曲所属播放队列。
  final List<PlaybackQueueItem> playlist;

  /// 当前行歌曲；传入后列表项无需再从播放队列取值。
  final PlaybackQueueItem? item;

  /// 播放队列名称。
  final String playListName;

  /// 播放队列标题前缀。
  final String playListHeader;

  /// 点击播放前的可选前置动作。
  final Function()? beforeOnTap;

  /// 自定义点击行为。
  final Future<void> Function()? onTap;

  /// 播放回调。
  final Future<void> Function(
    List<PlaybackQueueItem> playlist,
    int index, {
    String playListName,
    String playListNameHeader,
  })? onPlay;

  /// 文本颜色。
  final Color? stringColor;

  /// 是否展示歌曲封面。
  final bool showPic;

  /// 是否展示歌曲序号。
  final bool showIndex;

  /// 创建歌曲列表项。
  const SongItem({
    super.key,
    this.item,
    this.onTap,
    this.beforeOnTap,
    this.onPlay,
    this.stringColor,
    this.showPic = true,
    this.showIndex = false,
    this.playListHeader = "",
    this.playlist = const <PlaybackQueueItem>[],
    required this.index,
    required this.playListName,
  });

  @override
  Widget build(BuildContext context) {
    final currentItem = item ?? playlist[index];
    return UniversalListTile(
      leading: showIndex
          ? _SongIndexLeading(
              index: index,
              color: stringColor,
            )
          : null,
      picUrl: showPic ? currentItem.artworkUrl : null,
      titleString: currentItem.title,
      subTitleString: currentItem.artist,
      stringColor: stringColor,
      onTap: () async {
        if (beforeOnTap != null) {
          await beforeOnTap!();
        }
        if (onTap != null) {
          await onTap!();
          return;
        }
        await onPlay?.call(
          playlist,
          index,
          playListName: playListName,
          playListNameHeader: playListHeader,
        );
      },
    );
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
    final metrics = _PlaylistWidgetMetrics(context);
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
        return SizedBox(
          height: widgetHeight,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            physics: SnappingScrollPhysics(
              itemExtent: (albumWidth + albumMargin) * (snappAllAlbum ? albumCountInWidget.floor() : 1),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(left: albumMargin),
                sliver: SliverList.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: playLists.length,
                  itemBuilder: (context, index) {
                    final playlist = playLists[index];
                    final playButtonSize = metrics.playButtonSize(albumWidth);
                    return KeepAliveWrapper(
                      child: Container(
                        width: albumWidth,
                        margin: EdgeInsets.only(right: albumMargin),
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
                                          'assets/lottie/music_playing.json',
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
