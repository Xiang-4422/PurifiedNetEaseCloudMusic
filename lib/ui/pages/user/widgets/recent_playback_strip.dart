import 'dart:async';

import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

const double _recentPlaybackStripHeight = 76;
const double _recentPlaybackTileWidth = 220;
const double _recentPlaybackItemExtent = _recentPlaybackTileWidth + AppDimensions.paddingSmall;
const double _recentPlaybackCacheExtent = 360;

/// 个人页中的最近播放横向列表。
class RecentPlaybackStrip extends StatelessWidget {
  /// 创建最近播放横向列表。
  const RecentPlaybackStrip({
    super.key,
    required this.controller,
    required this.playbackAction,
  });

  /// 最近播放数据控制器。
  final RecentPlaybackController controller;

  /// 播放控制器，用于高亮当前歌曲并响应点击播放。
  final PlayerController playbackAction;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recentTracks = controller.recentTracks.toList(growable: false);
      if (recentTracks.isEmpty) {
        return const SizedBox.shrink();
      }
      final currentSongId = playbackAction.currentSongState.value.id;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(
            '最近播放',
            padding: AppDimensions.paddingSmall,
          ).marginOnly(top: AppDimensions.paddingSmall),
          SizedBox(
            height: _recentPlaybackStripHeight,
            child: ListView.builder(
              cacheExtent: _recentPlaybackCacheExtent,
              scrollDirection: Axis.horizontal,
              itemExtent: _recentPlaybackItemExtent,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
              ),
              itemCount: recentTracks.length,
              itemBuilder: (context, index) {
                final song = recentTracks[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
                  child: _RecentPlaybackTile(
                    song: song,
                    isCurrent: song.id == currentSongId,
                    onTap: () => playbackAction.playPlaylist(
                      recentTracks,
                      index,
                      playListName: '最近播放',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _RecentPlaybackTile extends StatelessWidget {
  const _RecentPlaybackTile({
    required this.song,
    required this.isCurrent,
    required this.onTap,
  });

  final PlaybackQueueItem song;
  final bool isCurrent;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semanticsLabel = recentPlaybackTileSemanticsLabel(
      title: song.title,
      artist: song.artist,
      isCurrent: isCurrent,
    );
    final artworkPath = ArtworkPathResolver.resolveDisplayPath(
      ArtworkPathResolver.resolvePlaybackArtwork(
        artworkUrl: song.artworkUrl,
        localArtworkPath: song.localArtworkPath,
      ),
    );
    final backgroundColor = Color.alphaBlend(
      (isCurrent ? colorScheme.primary : colorScheme.onSurface).withValues(
        alpha: isCurrent ? 0.12 : 0.06,
      ),
      colorScheme.surface,
    );

    return SizedBox(
      width: _recentPlaybackTileWidth,
      child: Semantics(
        button: true,
        selected: isCurrent,
        label: semanticsLabel,
        onTap: () => unawaited(onTap()),
        child: Tooltip(
          message: semanticsLabel,
          excludeFromSemantics: true,
          child: ExcludeSemantics(
            child: Material(
              color: backgroundColor,
              borderRadius: AppDimensions.borderRadiusMedium,
              child: InkWell(
                borderRadius: AppDimensions.borderRadiusMedium,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall / 2),
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: 52,
                        child: SimpleExtendedImage(
                          artworkPath,
                          width: 52,
                          height: 52,
                          cacheWidth: 120,
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recentPlaybackValue(song.title, fallback: '未知歌曲'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _recentPlaybackValue(song.artist, fallback: '未知艺人'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.58),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Icon(
                          TablerIcons.player_play_filled,
                          size: AppDimensions.iconSizeSmall,
                          color: colorScheme.primary,
                        ),
                    ],
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

/// 生成最近播放卡片的辅助语义标签。
@visibleForTesting
String recentPlaybackTileSemanticsLabel({
  required String title,
  required String? artist,
  required bool isCurrent,
}) {
  final resolvedTitle = _recentPlaybackValue(title, fallback: '未知歌曲');
  final resolvedArtist = _recentPlaybackValue(artist, fallback: '未知艺人');
  final prefix = isCurrent ? '当前播放' : '播放最近播放';
  return '$prefix：$resolvedTitle - $resolvedArtist';
}

String _recentPlaybackValue(String? value, {required String fallback}) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}
