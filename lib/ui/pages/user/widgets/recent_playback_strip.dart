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
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
              ),
              itemCount: recentTracks.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.paddingSmall),
              itemBuilder: (context, index) {
                final song = recentTracks[index];
                return _RecentPlaybackTile(
                  song: song,
                  isCurrent: song.id == currentSongId,
                  onTap: () => playbackAction.playPlaylist(
                    recentTracks,
                    index,
                    playListName: '最近播放',
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
      width: 220,
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
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist ?? '未知艺人',
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
    );
  }
}
