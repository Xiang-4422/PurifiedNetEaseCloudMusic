import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// 歌单详情页顶部的封面、标题和主操作区。
class PlaylistHeaderSliver extends StatelessWidget {
  /// 创建歌单详情页头部。
  const PlaylistHeaderSliver({
    super.key,
    required this.playlistName,
    required this.coverUrl,
    required this.trackCount,
    required this.loadedTrackCount,
    required this.heroExtent,
    required this.albumColor,
    required this.widgetColor,
    required this.isSubscribed,
    required this.isMyPlaylist,
    required this.canPlayLoadedPlaylist,
    required this.onPlaySequential,
    required this.onPlayShuffle,
    required this.onToggleSubscribe,
  });

  /// 歌单标题。
  final String playlistName;

  /// 已解析的封面地址。
  final String? coverUrl;

  /// 歌单总歌曲数。
  final int? trackCount;

  /// 当前已加载歌曲数。
  final int loadedTrackCount;

  /// 顶部展开区高度。
  final double heroExtent;

  /// 背景主色。
  final Color albumColor;

  /// 前景文字和图标颜色。
  final Color widgetColor;

  /// 当前账号是否已收藏歌单。
  final bool isSubscribed;

  /// 是否是当前账号自己的歌单。
  final bool isMyPlaylist;

  /// 当前歌单是否可以直接播放。
  final bool canPlayLoadedPlaylist;

  /// 顺序播放回调。
  final Future<void> Function() onPlaySequential;

  /// 随机播放回调。
  final Future<void> Function() onPlayShuffle;

  /// 收藏/取消收藏回调。
  final Future<void> Function() onToggleSubscribe;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final mediaSize = MediaQuery.sizeOf(context);
    final mediaPadding = MediaQuery.paddingOf(context);
    final textTheme = Theme.of(context).textTheme;
    return SliverAppBar(
      toolbarHeight: AppDimensions.appBarHeight,
      expandedHeight: heroExtent,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: true,
      foregroundColor: widgetColor,
      surfaceTintColor: Colors.transparent,
      backgroundColor: albumColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const <StretchMode>[
          StretchMode.zoomBackground,
        ],
        collapseMode: CollapseMode.pin,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playlistName,
              style: textTheme.titleLarge?.copyWith(
                color: widgetColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '歌单·${trackCount ?? loadedTrackCount}首',
              style: textTheme.titleSmall?.copyWith(
                color: widgetColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        expandedTitleScale: 1.5,
        titlePadding: EdgeInsets.only(
          bottom: 60 + AppDimensions.paddingSmall,
          top: mediaPadding.top,
          left: AppDimensions.paddingSmall,
          right: AppDimensions.paddingSmall,
        ),
        background: SimpleExtendedImage(
          coverUrl ?? '',
          width: mediaSize.width,
          height: heroExtent,
          cacheWidth: _resolveImageCacheDimension(
            mediaSize.width,
            devicePixelRatio,
          ),
          cacheHeight: _resolveImageCacheDimension(
            heroExtent,
            devicePixelRatio,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: Row(
            spacing: AppDimensions.paddingSmall,
            children: [
              Flexible(
                child: _PlaylistActionButton(
                  color: widgetColor.withValues(alpha: 0.05),
                  actionColor: _actionColor,
                  icon: TablerIcons.repeat,
                  label: '顺序播放',
                  onPressed: canPlayLoadedPlaylist
                      ? () async {
                          await onPlaySequential();
                        }
                      : null,
                ),
              ),
              if (!isMyPlaylist)
                _PlaylistSubscribeButton(
                  color: widgetColor.withValues(alpha: 0.05),
                  iconColor: isSubscribed ? Colors.red : widgetColor,
                  isSubscribed: isSubscribed,
                  onPressed: () async {
                    await onToggleSubscribe();
                  },
                ),
              Flexible(
                child: _PlaylistActionButton(
                  color: widgetColor.withValues(alpha: 0.05),
                  actionColor: _actionColor,
                  icon: TablerIcons.arrows_shuffle,
                  label: '随机播放',
                  onPressed: canPlayLoadedPlaylist
                      ? () async {
                          await onPlayShuffle();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _actionColor => canPlayLoadedPlaylist ? widgetColor : widgetColor.withValues(alpha: 0.35);

  int _resolveImageCacheDimension(double logicalSize, double devicePixelRatio) {
    return (logicalSize * devicePixelRatio).round().clamp(1, 1080).toInt();
  }
}

class _PlaylistActionButton extends StatelessWidget {
  const _PlaylistActionButton({
    required this.color,
    required this.actionColor,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final Color actionColor;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = onPressed != null;
    return _PlaylistActionButtonSurface(
      color: color,
      child: IconButton(
        tooltip: playlistPlayActionLabel(
          label: label,
          isEnabled: isEnabled,
        ),
        onPressed: onPressed,
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              icon,
              color: actionColor,
            ),
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: actionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistSubscribeButton extends StatelessWidget {
  const _PlaylistSubscribeButton({
    required this.color,
    required this.iconColor,
    required this.isSubscribed,
    required this.onPressed,
  });

  final Color color;
  final Color iconColor;
  final bool isSubscribed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _PlaylistActionButtonSurface(
      color: color,
      child: IconButton(
        tooltip: playlistSubscribeControlLabel(isSubscribed: isSubscribed),
        color: Colors.red,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          isSubscribed ? TablerIcons.heart_filled : TablerIcons.heart,
          color: iconColor,
        ),
      ),
    );
  }
}

/// 生成歌单播放动作按钮的辅助语义标签。
@visibleForTesting
String playlistPlayActionLabel({
  required String label,
  required bool isEnabled,
}) {
  final resolvedLabel = label.trim().isEmpty ? '播放歌单' : label.trim();
  if (isEnabled) {
    return resolvedLabel;
  }
  return '$resolvedLabel（等待歌曲加载）';
}

/// 生成歌单收藏按钮的辅助语义标签。
@visibleForTesting
String playlistSubscribeControlLabel({required bool isSubscribed}) {
  return isSubscribed ? '取消收藏歌单' : '收藏歌单';
}

class _PlaylistActionButtonSurface extends StatelessWidget {
  const _PlaylistActionButtonSurface({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(60),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
