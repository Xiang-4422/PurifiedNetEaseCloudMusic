import 'dart:async';
import 'dart:math' as math;

import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';

class _MusicListTileMetrics {
  _MusicListTileMetrics(this.context);

  final BuildContext context;

  double get _textScale => MediaQuery.textScalerOf(context).scale(1);

  double get tileMinHeight => 52;

  double get tileVerticalPadding => (6 * _textScale).clamp(6.0, 10.0);

  double get thumbnailSize => (44 * _textScale).clamp(40.0, 52.0);

  double get tileGap => AppDimensions.paddingSmall;

  double get trailingMaxWidth {
    final width = MediaQuery.sizeOf(context).width;
    return math.max(72, width * 0.28).clamp(72.0, 132.0).toDouble();
  }

  double get indexWidth => (28 * _textScale).clamp(26.0, 36.0);
}

/// 统一歌曲、歌单、专辑、歌手搜索结果的行结构。
class UniversalListTile extends StatelessWidget {
  /// 创建通用列表行。
  const UniversalListTile({
    super.key,
    required this.titleString,
    this.subTitleString,
    this.semanticLabel,
    this.picUrl,
    this.stringColor,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  /// 主标题文本。
  final String titleString;

  /// 副标题文本。
  final String? subTitleString;

  /// 辅助功能语义标签；为空时按标题和副标题自动生成。
  final String? semanticLabel;

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

  @override
  Widget build(BuildContext context) {
    final metrics = _MusicListTileMetrics(context);
    final localPicPath = ArtworkPathResolver.resolveDisplayPath(picUrl);
    final colorScheme = Theme.of(context).colorScheme;
    final interactive = onTap != null || onLongPress != null;
    return Semantics(
      container: true,
      button: interactive,
      enabled: interactive ? true : null,
      label: semanticLabel ?? universalListTileSemanticLabel(title: titleString, subtitle: subTitleString),
      onTap: onTap,
      onLongPress: onLongPress,
      child: ExcludeSemantics(
        child: InkWell(
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
                                color: stringColor ?? colorScheme.onPrimary,
                                height: 1.15,
                              ),
                        ),
                        if (subTitleString != null)
                          Text(
                            subTitleString!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: (stringColor ?? colorScheme.onPrimary).withValues(alpha: 0.5),
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
        ),
      ),
    );
  }
}

/// 生成通用列表项的辅助语义标签。
@visibleForTesting
String universalListTileSemanticLabel({
  required String title,
  String? subtitle,
}) {
  final resolvedTitle = title.trim().isEmpty ? '未命名内容' : title.trim();
  final resolvedSubtitle = subtitle?.trim() ?? '';
  if (resolvedSubtitle.isEmpty) {
    return resolvedTitle;
  }
  return '$resolvedTitle，$resolvedSubtitle';
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
    final theme = Theme.of(context);
    return Text(
      '${index + 1}',
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        color: (color ?? theme.colorScheme.onPrimary).withValues(alpha: 0.55),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// 歌曲列表项，点击后按当前上下文播放。
class SongItem extends StatelessWidget {
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
  final FutureOr<void> Function()? beforeOnTap;

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

  @override
  Widget build(BuildContext context) {
    final currentItem = item ?? playlist[index];
    final artworkPath = ArtworkPathResolver.resolvePlaybackArtwork(
      artworkUrl: currentItem.artworkUrl,
      localArtworkPath: currentItem.localArtworkPath,
    );
    return UniversalListTile(
      leading: showIndex
          ? _SongIndexLeading(
              index: index,
              color: stringColor,
            )
          : null,
      picUrl: showPic ? artworkPath : null,
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
