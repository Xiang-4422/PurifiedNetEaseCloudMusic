import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/home_content_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/image/async_image_color.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// 快速入口横向列表的预缓存边界。
const double quickStartCardRailCacheExtent = 360;

/// 首页第一屏保留的核心快速播放动作数量。
@visibleForTesting
const int quickStartPrimaryActionCount = 2;

/// 个人首页顶部的快速播放入口列表。
class QuickStartCardRail extends StatelessWidget {
  /// 创建快速播放入口列表。
  const QuickStartCardRail({
    super.key,
    required this.width,
    required this.height,
    required this.homeContentController,
    required this.playbackAction,
    required this.recentPlaybackController,
    required this.shellController,
  });

  /// 单张入口卡片宽度。
  final double width;

  /// 单张入口卡片高度。
  final double height;

  /// 首页内容控制器。
  final HomeContentController homeContentController;

  /// 播放控制器。
  final PlayerController playbackAction;

  /// 最近播放控制器，用于当前播放为空时提供本地优先的继续播放候选。
  final RecentPlaybackController recentPlaybackController;

  /// Shell 控制器，用于打开底部播放页。
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.only(left: AppDimensions.paddingSmall),
        scrollDirection: Axis.horizontal,
        cacheExtent: quickStartCardRailCacheExtent,
        itemExtent: width + AppDimensions.paddingSmall,
        itemCount: quickStartPrimaryActionCount,
        physics: SnappingScrollPhysics(
          itemExtent: width + AppDimensions.paddingSmall,
        ),
        itemBuilder: (context, index) => _buildQuickStartCard(index),
      ),
    );
  }

  Widget _buildQuickStartCard(int index) {
    late final Widget card;
    switch (index) {
      case 0:
        card = _ContinuePlaybackQuickStartCard(
          width: width,
          height: height,
          playbackAction: playbackAction,
          recentPlaybackController: recentPlaybackController,
          shellController: shellController,
        );
      case 1:
        card = _DailyRecommendQuickStartCard(
          width: width,
          height: height,
          homeContentController: homeContentController,
          playbackAction: playbackAction,
        );
      default:
        return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
      child: card,
    );
  }
}

class _DailyRecommendQuickStartCard extends StatelessWidget {
  const _DailyRecommendQuickStartCard({
    required this.width,
    required this.height,
    required this.homeContentController,
    required this.playbackAction,
  });

  final double width;
  final double height;
  final HomeContentController homeContentController;
  final PlayerController playbackAction;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final songs = homeContentController.todayRecommendSongs;
      final isPlayingDaily = playbackAction.isPlaying.value && playbackAction.sessionState.value.playlistName == '每日推荐';
      return QuickStartCard(
        width: width,
        height: height,
        albumUrl: _firstPlaybackArtworkPath(
          songs,
        ),
        icon: TablerIcons.calendar,
        title: '每日推荐',
        subtitle: '${songs.length} 首待播放',
        onTap: () => context.router.push(const gr.TodayRouteView()),
        trailing: _QuickStartPlayButton(
          isPlaying: isPlayingDaily,
          isEnabled: songs.isNotEmpty,
          tooltip: isPlayingDaily ? '暂停每日推荐' : '播放每日推荐',
          onPressed: () {
            if (isPlayingDaily) {
              playbackAction.playOrPause();
              return;
            }
            playbackAction.playPlaylist(
              songs,
              0,
              playListName: '每日推荐',
            );
          },
        ),
      );
    });
  }
}

class _ContinuePlaybackQuickStartCard extends StatelessWidget {
  const _ContinuePlaybackQuickStartCard({
    required this.width,
    required this.height,
    required this.playbackAction,
    required this.recentPlaybackController,
    required this.shellController,
  });

  final double width;
  final double height;
  final PlayerController playbackAction;
  final RecentPlaybackController recentPlaybackController;
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = playbackAction.currentSongState.value;
      final recentTracks = recentPlaybackController.recentTracks.toList(
        growable: false,
      );
      final currentSongId = currentSong.id.trim();
      final hasCurrentSong = currentSongId.isNotEmpty;
      final fallbackIndex = hasCurrentSong ? -1 : _firstPlayableRecentIndex(recentTracks);
      final fallbackSong = fallbackIndex >= 0 ? recentTracks[fallbackIndex] : const PlaybackQueueItem.empty();
      final displaySong = hasCurrentSong ? currentSong : fallbackSong;
      final hasPlayableSong = displaySong.id.trim().isNotEmpty;
      final subtitle = hasPlayableSong
          ? _continuePlaybackSubtitle(
              displaySong,
              isCurrentSong: hasCurrentSong,
            )
          : '最近播放为空';
      return QuickStartCard(
        width: width,
        height: height,
        albumUrl: _playbackArtworkPath(displaySong),
        icon: TablerIcons.player_play,
        title: '继续播放',
        subtitle: subtitle,
        onTap: hasPlayableSong
            ? () async {
                if (hasCurrentSong) {
                  shellController.jumpBottomPanelToPage(1);
                  shellController.openBottomPanel();
                  if (!playbackAction.isPlaying.value) {
                    await playbackAction.playOrPause();
                  }
                  return;
                }
                await playbackAction.playPlaylist(
                  recentTracks,
                  fallbackIndex,
                  playListName: '最近播放',
                  playListNameHeader: '最近播放',
                );
              }
            : null,
        trailing: _QuickStartPlayButton(
          isPlaying: hasCurrentSong && playbackAction.isPlaying.value,
          isEnabled: hasPlayableSong,
          tooltip: _continuePlaybackControlLabel(
            isPlaying: playbackAction.isPlaying.value && hasCurrentSong,
            isCurrentSong: hasCurrentSong,
          ),
          onPressed: () async {
            if (!hasPlayableSong) {
              return;
            }
            if (hasCurrentSong) {
              await playbackAction.playOrPause();
              return;
            }
            await playbackAction.playPlaylist(
              recentTracks,
              fallbackIndex,
              playListName: '最近播放',
              playListNameHeader: '最近播放',
            );
          },
        ),
      );
    });
  }
}

/// 个人首页顶部的快速播放入口卡片。
class QuickStartCard extends StatelessWidget {
  /// 创建快速播放入口卡片。
  const QuickStartCard({
    super.key,
    required this.width,
    required this.height,
    this.onTap,
    required this.albumUrl,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  /// 卡片宽度。
  final double width;

  /// 卡片高度。
  final double height;

  /// 点击卡片时触发的动作；为空时卡片呈禁用态。
  final Function()? onTap;

  /// 卡片背景封面地址。
  final String albumUrl;

  /// 卡片前景图标。
  final IconData? icon;

  /// 卡片标题。
  final String title;

  /// 卡片辅助信息。
  final String? subtitle;

  /// 右下角动作按钮。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = onTap != null;
    final semanticsLabel = quickStartCardSemanticsLabel(
      title: title,
      isEnabled: isEnabled,
    );
    final localAlbumPath = ArtworkPathResolver.resolveDisplayPath(albumUrl);
    final resolvedSubtitle = subtitle?.trim();

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticsLabel,
      child: Tooltip(
        message: semanticsLabel,
        excludeFromSemantics: true,
        child: Material(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppDimensions.borderRadiusMedium,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.52,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: AsyncImageColor(
                    imageUrl: localAlbumPath,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _QuickStartArtwork(
                          albumPath: localAlbumPath,
                          icon: icon,
                          size: math.min(width, height) * 0.72,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x99000000),
                                Color(0x1A000000),
                                Color(0xB3000000),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (icon != null)
                                    Icon(
                                      icon,
                                      size: AppDimensions.iconSizeSmall,
                                      color: Colors.white.withValues(alpha: 0.86),
                                    ),
                                  const Spacer(),
                                  if (trailing != null) trailing!,
                                ],
                              ),
                              const Spacer(),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (resolvedSubtitle != null && resolvedSubtitle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  resolvedSubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStartArtwork extends StatelessWidget {
  const _QuickStartArtwork({
    required this.albumPath,
    required this.icon,
    required this.size,
  });

  final String albumPath;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (albumPath.isEmpty) {
      return Center(
        child: Icon(
          icon ?? TablerIcons.music,
          size: math.max(32, size * 0.34),
          color: Colors.white.withValues(alpha: 0.56),
        ),
      );
    }
    return Align(
      alignment: Alignment.center,
      child: SizedBox.square(
        dimension: size,
        child: SimpleExtendedImage(
          albumPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: 360,
          borderRadius: AppDimensions.borderRadiusMedium,
        ),
      ),
    );
  }
}

class _QuickStartPlayButton extends StatelessWidget {
  const _QuickStartPlayButton({
    required this.isPlaying,
    required this.isEnabled,
    required this.tooltip,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isEnabled;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isEnabled ? tooltip : '暂无可播放歌曲',
      excludeFromSemantics: true,
      child: Material(
        color: Colors.white.withValues(alpha: isEnabled ? 0.18 : 0.08),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onPressed : null,
          child: SizedBox.square(
            dimension: 34,
            child: Icon(
              isPlaying ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
              size: AppDimensions.iconSizeSmall,
              color: Colors.white.withValues(alpha: isEnabled ? 0.95 : 0.38),
            ),
          ),
        ),
      ),
    );
  }
}

String _quickStartSongSubtitle(PlaybackQueueItem item) {
  final title = item.title.trim();
  final artist = item.artist?.trim();
  if (title.isEmpty && (artist == null || artist.isEmpty)) {
    return '当前歌曲';
  }
  if (artist == null || artist.isEmpty) {
    return title;
  }
  if (title.isEmpty) {
    return artist;
  }
  return '$title - $artist';
}

int _firstPlayableRecentIndex(List<PlaybackQueueItem> recentTracks) {
  return recentTracks.indexWhere((item) => item.id.trim().isNotEmpty);
}

String _continuePlaybackSubtitle(
  PlaybackQueueItem item, {
  required bool isCurrentSong,
}) {
  final prefix = isCurrentSong ? '当前播放' : '最近播放';
  return '$prefix · ${_quickStartSongSubtitle(item)}';
}

String _continuePlaybackControlLabel({
  required bool isPlaying,
  required bool isCurrentSong,
}) {
  if (isCurrentSong) {
    return isPlaying ? '暂停当前歌曲' : '继续播放当前歌曲';
  }
  return '播放最近播放';
}

/// 生成快速入口卡片的辅助语义标签。
@visibleForTesting
String quickStartCardSemanticsLabel({
  required String title,
  required bool isEnabled,
}) {
  final resolvedTitle = title.trim().isEmpty ? '快速入口' : title.trim();
  if (isEnabled) {
    return resolvedTitle;
  }
  return '$resolvedTitle（当前不可用）';
}

String _playbackArtworkPath(PlaybackQueueItem item) {
  return ArtworkPathResolver.resolvePlaybackArtwork(
        artworkUrl: item.artworkUrl,
        localArtworkPath: item.localArtworkPath,
      ) ??
      '';
}

String _firstPlaybackArtworkPath(List<PlaybackQueueItem> songs) {
  if (songs.isEmpty) {
    return '';
  }
  return _playbackArtworkPath(songs.first);
}
