import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:bujuan/ui/widgets/common/interaction/swipeable.dart';
import 'package:bujuan/ui/widgets/common/progress/circular_playback_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// 底部播放面板收起态的迷你播放栏。
class BottomPanelHeaderView extends GetView<ShellController> {
  /// 创建迷你播放栏。
  const BottomPanelHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = PlayerController.to.currentSongState.value;
      if (currentSong.id.isEmpty) {
        return const SizedBox.shrink();
      }
      final expandLabel = miniPlayerExpandControlLabel(
        title: currentSong.title,
        artist: currentSong.artist,
      );
      return Offstage(
        offstage: controller.bottomPanelFullyOpened.isTrue,
        child: Semantics(
          button: true,
          label: expandLabel,
          child: Tooltip(
            message: expandLabel,
            child: GestureDetector(
              onTap: () => controller.openBottomPanel(),
              child: AnimatedBuilder(
                animation: controller.bottomPanelAnimationController,
                builder: (context, child) {
                  // 完全展开专辑图片状态
                  /// 完全展开，专辑图片Size
                  double albumMaxSize = context.width - AppDimensions.paddingLarge * 2;

                  /// 完全展开，专辑图片Margin
                  double albumMaxPadding = AppDimensions.paddingLarge;

                  /// 完全展开，专辑图片Radius
                  double albumMinBorderRadius = AppDimensions.paddingLarge / 2;

                  /// panel展开程度
                  double panelOpenDegree = controller.bottomPanelAnimationController.value;
                  // 实时Album宽度、margin
                  double realTimeAlbumWidth = AppDimensions.albumMinSize + (albumMaxSize - AppDimensions.albumMinSize) * panelOpenDegree;
                  double realTimeAlbumPadding = AppDimensions.paddingSmall + (albumMaxPadding - AppDimensions.paddingSmall) * panelOpenDegree;
                  double realTimeAlbumTopMargin = (context.mediaQueryPadding.top + AppDimensions.appBarHeight) * panelOpenDegree;
                  double realTimeAlbumBorderRadius = AppDimensions.albumMinSize + (albumMinBorderRadius - AppDimensions.albumMinSize) * panelOpenDegree;

                  return SizedBox(
                    width: context.width,
                    child: Stack(
                      children: [
                        // 歌名&歌手
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            left: (AppDimensions.albumMinSize + AppDimensions.paddingSmall * 2 - albumMaxPadding) * (1 - panelOpenDegree) + albumMaxPadding,
                            right: (AppDimensions.albumMinSize + AppDimensions.paddingSmall * 2 - albumMaxPadding) * (1 - panelOpenDegree) + albumMaxPadding,
                            top: context.mediaQueryPadding.top * panelOpenDegree,
                          ),
                          child: SizedBox(
                            height: AppDimensions.bottomPanelHeaderHeight,
                            child: Swipeable(
                              background: const SizedBox.shrink(),
                              onSwipeLeft: () => PlayerController.to.skipToPreviousTrack(),
                              onSwipeRight: () => PlayerController.to.skipToNextTrack(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: context.textTheme.titleLarge?.copyWith(
                                      color: SettingsController.to.panelWidgetColor.value,
                                    ),
                                  ),
                                  Text(
                                    currentSong.artist ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: context.textTheme.titleLarge?.copyWith(
                                      fontSize: context.textTheme.titleLarge!.fontSize! / 2,
                                      color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 大专辑图片
                        Visibility(
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          visible: controller.isBigAlbum.isTrue && controller.bottomPanelFullyOpened.isFalse,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: realTimeAlbumTopMargin,
                            ),
                            padding: EdgeInsets.all(realTimeAlbumPadding),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  realTimeAlbumBorderRadius,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: SimpleExtendedImage(
                                ArtworkPathResolver.resolveDisplayPath(
                                  currentSong.artworkUrl ?? currentSong.localArtworkPath,
                                ),
                                width: realTimeAlbumWidth,
                                height: realTimeAlbumWidth,
                              ),
                            ),
                          ),
                        ),
                        // 小专辑图片
                        Visibility(
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          visible: controller.isBigAlbum.isFalse && controller.bottomPanelFullyOpened.isFalse,
                          child: Container(
                            height: AppDimensions.bottomPanelHeaderHeight,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(
                              top: context.mediaQueryPadding.top * panelOpenDegree,
                              left: AppDimensions.paddingSmall + panelOpenDegree * (context.width - AppDimensions.paddingLarge - AppDimensions.albumMinSize - AppDimensions.paddingSmall),
                            ),
                            child: SimpleExtendedImage(
                              ArtworkPathResolver.resolveDisplayPath(
                                currentSong.artworkUrl ?? currentSong.localArtworkPath,
                              ),
                              width: AppDimensions.albumMinSize,
                              height: AppDimensions.albumMinSize,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // 播放按钮
                        Obx(
                          () => Offstage(
                            offstage: controller.bottomPanelFullyClosed.isFalse,
                            child: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.all(
                                AppDimensions.paddingSmall,
                              ),
                              child: Stack(
                                children: [
                                  // 播放进度
                                  if ((currentSong.duration?.inMilliseconds ?? 0) > 0)
                                    Obx(() {
                                      final currentDuration = PlayerController.to.currentPositionState.value;
                                      return CircularPlaybackProgress(
                                        progress: playbackProgressFraction(
                                          position: currentDuration,
                                          total: currentSong.duration,
                                        ),
                                        size: AppDimensions.albumMinSize,
                                        strokeWidth: 2,
                                        progressColor: SettingsController.to.panelWidgetColor.value,
                                        backgroundColor: SettingsController.to.panelWidgetColor.value.withAlpha(50),
                                      );
                                    }),
                                  // 播放按钮
                                  Obx(() {
                                    final isPlaying = PlayerController.to.isPlaying.value;
                                    return IconButton(
                                      tooltip: miniPlayerPlayPauseControlLabel(
                                        isPlaying: isPlaying,
                                      ),
                                      onPressed: () => PlayerController.to.playOrPause(),
                                      padding: const EdgeInsets.all(
                                        AppDimensions.albumMinSize * 1 / 3 / 2,
                                      ),
                                      icon: Icon(
                                        isPlaying ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                                        color: SettingsController.to.panelWidgetColor.value,
                                        size: AppDimensions.albumMinSize * 2 / 3,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// 生成 mini player 展开入口的辅助语义标签。
@visibleForTesting
String miniPlayerExpandControlLabel({
  required String title,
  String? artist,
}) {
  final resolvedTitle = title.trim().isEmpty ? '当前歌曲' : title.trim();
  final resolvedArtist = artist?.trim() ?? '';
  if (resolvedArtist.isEmpty) {
    return '打开播放器：$resolvedTitle';
  }
  return '打开播放器：$resolvedTitle - $resolvedArtist';
}

/// 生成 mini player 播放按钮的辅助语义标签。
@visibleForTesting
String miniPlayerPlayPauseControlLabel({required bool isPlaying}) {
  return isPlaying ? '暂停' : '播放';
}
