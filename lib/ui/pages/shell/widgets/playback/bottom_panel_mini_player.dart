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
  const BottomPanelHeaderView({
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 播放控制器。
  final PlayerController playerController;

  /// 设置控制器。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = playerController.currentSongState.value;
      if (currentSong.id.isEmpty) {
        return const SizedBox.shrink();
      }
      final expandLabel = miniPlayerExpandControlLabel(
        title: currentSong.title,
        artist: currentSong.artist,
      );
      final swipeHint = miniPlayerSwipeControlHint();
      return Offstage(
        offstage: controller.bottomPanelFullyOpened.isTrue,
        child: Semantics(
          button: true,
          label: expandLabel,
          hint: swipeHint,
          decreasedValue: miniPlayerSkipActionLabel(skipToNext: false),
          increasedValue: miniPlayerSkipActionLabel(skipToNext: true),
          onDecrease: playerController.skipToPreviousTrackFromMiniPlayer,
          onIncrease: playerController.skipToNextTrackFromMiniPlayer,
          child: Tooltip(
            message: expandLabel,
            child: GestureDetector(
              onTap: () => controller.openBottomPanelFromMiniPlayer(),
              child: AnimatedBuilder(
                animation: controller.bottomPanelAnimationController,
                builder: (context, child) {
                  final layout = miniPlayerTransitionLayout(
                    panelOpenDegree: controller.bottomPanelAnimationController.value,
                    availableWidth: context.width,
                    topPadding: context.mediaQueryPadding.top,
                  );

                  return SizedBox(
                    width: context.width,
                    child: Stack(
                      children: [
                        // 歌名&歌手
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            left: layout.textHorizontalMargin,
                            right: layout.textHorizontalMargin,
                            top: layout.textTopMargin,
                          ),
                          child: SizedBox(
                            height: AppDimensions.bottomPanelHeaderHeight,
                            child: Swipeable(
                              background: const SizedBox.shrink(),
                              onSwipeLeft: () => playerController.skipToPreviousTrackFromMiniPlayer(),
                              onSwipeRight: () => playerController.skipToNextTrackFromMiniPlayer(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: context.textTheme.titleLarge?.copyWith(
                                      color: settingsController.panelWidgetColor.value,
                                    ),
                                  ),
                                  Text(
                                    currentSong.artist ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: context.textTheme.titleLarge?.copyWith(
                                      fontSize: context.textTheme.titleLarge!.fontSize! / 2,
                                      color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
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
                              top: layout.albumTopMargin,
                            ),
                            padding: EdgeInsets.all(layout.albumPadding),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  layout.albumBorderRadius,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: SimpleExtendedImage(
                                ArtworkPathResolver.resolveDisplayPath(
                                  ArtworkPathResolver.resolvePlaybackArtwork(
                                    artworkUrl: currentSong.artworkUrl,
                                    localArtworkPath: currentSong.localArtworkPath,
                                  ),
                                ),
                                width: layout.albumWidth,
                                height: layout.albumWidth,
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
                              top: layout.textTopMargin,
                              left: layout.smallAlbumLeft,
                            ),
                            child: SimpleExtendedImage(
                              ArtworkPathResolver.resolveDisplayPath(
                                ArtworkPathResolver.resolvePlaybackArtwork(
                                  artworkUrl: currentSong.artworkUrl,
                                  localArtworkPath: currentSong.localArtworkPath,
                                ),
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
                                      final currentDuration = playerController.currentPositionState.value;
                                      final progressLabel = playbackProgressSemanticsLabel(
                                        position: currentDuration,
                                        total: currentSong.duration,
                                      );
                                      return Tooltip(
                                        message: progressLabel,
                                        excludeFromSemantics: true,
                                        child: Semantics(
                                          label: progressLabel,
                                          child: CircularPlaybackProgress(
                                            progress: playbackProgressFraction(
                                              position: currentDuration,
                                              total: currentSong.duration,
                                            ),
                                            size: AppDimensions.albumMinSize,
                                            strokeWidth: 2,
                                            progressColor: settingsController.panelWidgetColor.value,
                                            backgroundColor: settingsController.panelWidgetColor.value.withAlpha(50),
                                          ),
                                        ),
                                      );
                                    }),
                                  // 播放按钮
                                  Obx(() {
                                    final isPlaying = playerController.isPlaying.value;
                                    return IconButton(
                                      tooltip: miniPlayerPlayPauseControlLabel(
                                        isPlaying: isPlaying,
                                      ),
                                      onPressed: () => playerController.playOrPause(),
                                      padding: const EdgeInsets.all(
                                        AppDimensions.albumMinSize * 1 / 3 / 2,
                                      ),
                                      icon: Icon(
                                        isPlaying ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                                        color: settingsController.panelWidgetColor.value,
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

/// mini player 收起到展开过程中的稳定布局数值。
class MiniPlayerTransitionLayout {
  /// 创建 mini player 过渡布局。
  const MiniPlayerTransitionLayout({
    required this.panelOpenDegree,
    required this.albumWidth,
    required this.albumPadding,
    required this.albumTopMargin,
    required this.albumBorderRadius,
    required this.textHorizontalMargin,
    required this.textTopMargin,
    required this.smallAlbumLeft,
  });

  /// 夹紧后的面板展开程度。
  final double panelOpenDegree;

  /// 当前封面尺寸。
  final double albumWidth;

  /// 当前封面外层内边距。
  final double albumPadding;

  /// 当前大封面顶部偏移。
  final double albumTopMargin;

  /// 当前封面圆角。
  final double albumBorderRadius;

  /// 歌名区左右边距。
  final double textHorizontalMargin;

  /// 歌名区顶部偏移。
  final double textTopMargin;

  /// 小封面左边距。
  final double smallAlbumLeft;
}

/// 计算 mini player 到完整播放页之间的过渡布局。
@visibleForTesting
MiniPlayerTransitionLayout miniPlayerTransitionLayout({
  required double panelOpenDegree,
  required double availableWidth,
  required double topPadding,
  double albumMinSize = AppDimensions.albumMinSize,
  double paddingSmall = AppDimensions.paddingSmall,
  double paddingLarge = AppDimensions.paddingLarge,
  double appBarHeight = AppDimensions.appBarHeight,
}) {
  final degree = _stableFraction(panelOpenDegree);
  final width = _atLeast(availableWidth, albumMinSize + paddingSmall * 2);
  final expandedAlbumWidth = _atLeast(width - paddingLarge * 2, albumMinSize);
  final collapsedTextMargin = albumMinSize + paddingSmall * 2;
  final expandedSmallAlbumLeft = _atLeast(width - paddingLarge - albumMinSize, paddingSmall);

  return MiniPlayerTransitionLayout(
    panelOpenDegree: degree,
    albumWidth: _lerp(albumMinSize, expandedAlbumWidth, degree),
    albumPadding: _lerp(paddingSmall, paddingLarge, degree),
    albumTopMargin: (topPadding + appBarHeight) * degree,
    albumBorderRadius: _lerp(albumMinSize, paddingLarge / 2, degree),
    textHorizontalMargin: _lerp(collapsedTextMargin, paddingLarge, degree),
    textTopMargin: topPadding * degree,
    smallAlbumLeft: _lerp(paddingSmall, expandedSmallAlbumLeft, degree),
  );
}

double _stableFraction(double value) {
  if (!value.isFinite) {
    return 0;
  }
  return value.clamp(0.0, 1.0).toDouble();
}

double _atLeast(double value, double minimum) {
  if (!value.isFinite) {
    return minimum;
  }
  return value < minimum ? minimum : value;
}

double _lerp(double start, double end, double fraction) {
  return start + (end - start) * fraction;
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

/// 生成 mini player 滑动切歌的辅助提示。
@visibleForTesting
String miniPlayerSwipeControlHint() {
  return '左滑上一首，右滑下一首';
}

/// 生成 mini player 辅助切歌动作的标签。
@visibleForTesting
String miniPlayerSkipActionLabel({required bool skipToNext}) {
  return skipToNext ? '下一首' : '上一首';
}
