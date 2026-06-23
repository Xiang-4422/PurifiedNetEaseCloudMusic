import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_order_mode.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/common/progress/circular_playback_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

const double _secondaryControlIconSize = AppDimensions.iconSizeMedium;
const double _primaryControlIconSize = 56;
const double _controlButtonPadding = 8;

/// 底部播放面板进度条。
class BottomPanelProgressBar extends StatelessWidget {
  /// 创建底部播放面板进度条。
  const BottomPanelProgressBar({
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 播放控制器，提供当前歌曲、播放进度和 seek 操作。
  final PlayerController playerController;

  /// 设置控制器，提供进度条颜色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = playerController.currentSongState.value;
      final currentPosition = playerController.currentPositionState.value;
      final total = safePlaybackProgressTotal(currentSong.duration);
      final safePosition = clampPlaybackProgressPosition(
        position: currentPosition,
        total: total,
      );
      return ProgressBar(
        progress: safePosition,
        buffered: safePosition,
        total: total,
        barHeight: AppDimensions.paddingLarge,
        barCapShape: BarCapShape.round,
        progressBarColor: settingsController.panelWidgetColor.value.withValues(alpha: .1),
        baseBarColor: settingsController.panelWidgetColor.value.withValues(alpha: .05),
        bufferedBarColor: Colors.transparent,
        thumbColor: settingsController.panelWidgetColor.value.withValues(alpha: .05),
        thumbRadius: AppDimensions.paddingLarge / 2,
        thumbGlowRadius: AppDimensions.paddingLarge * 2 / 3,
        thumbCanPaintOutsideBar: false,
        timeLabelLocation: TimeLabelLocation.below,
        timeLabelTextStyle: const TextStyle(fontSize: 0),
        onSeek: (duration) => playerController.seekTo(duration),
      );
    });
  }
}

/// 底部播放面板播放控制按钮组。
class BottomPanelPlaybackControls extends GetView<ShellController> {
  /// 创建播放控制按钮组。
  const BottomPanelPlaybackControls({
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 播放控制器，提供播放状态和控制意图。
  final PlayerController playerController;

  /// 设置控制器，提供按钮颜色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Obx(() {
        final currentSong = playerController.currentSongState.value;
        final isLiked = playerController.isPlaybackItemLiked(currentSong);
        final isPlaying = playerController.isPlaying.value;
        final preferHighQuality = playerController.isHighQualityPlaybackPreferred();
        final panelColor = settingsController.panelWidgetColor.value;
        final repeatIcon = playerController.getRepeatIcon();
        final playbackMode = playerController.playbackMode.value;
        final orderMode = playerController.curOrderMode.value;
        final repeatMode = playerController.curRepeatMode.value;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PlaybackControlButton(
              semanticsLabel: playbackLikeControlLabel(isLiked: isLiked),
              onTap: () => playerController.toggleLikeFromPlayback(currentSong),
              child: _ButtonBackground(
                settingsController: settingsController,
                child: Icon(
                  isLiked ? TablerIcons.heart_filled : TablerIcons.heart,
                  size: _secondaryControlIconSize,
                  color: isLiked ? Colors.red : panelColor,
                ),
              ),
            ),
            _PlaybackControlButton(
              semanticsLabel: '上一首',
              onTap: playerController.skipToPreviousTrack,
              child: _ButtonBackground(
                settingsController: settingsController,
                child: Icon(
                  TablerIcons.player_skip_back_filled,
                  size: _secondaryControlIconSize,
                  color: panelColor,
                ),
              ),
            ),
            _PlaybackControlButton(
              semanticsLabel: playbackPlayPauseControlLabel(
                isPlaying: isPlaying,
              ),
              onTap: playerController.playOrPause,
              child: _ButtonBackground(
                settingsController: settingsController,
                child: Icon(
                  isPlaying ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                  size: _primaryControlIconSize,
                  color: panelColor,
                ),
              ),
            ),
            _PlaybackControlButton(
              semanticsLabel: '下一首',
              onTap: playerController.skipToNextTrack,
              child: _ButtonBackground(
                settingsController: settingsController,
                child: Icon(
                  TablerIcons.player_skip_forward_filled,
                  size: _secondaryControlIconSize,
                  color: panelColor,
                ),
              ),
            ),
            _PlaybackControlButton(
              semanticsLabel: playbackQualityControlLabel(
                preferHighQuality: preferHighQuality,
              ),
              onTap: playerController.toggleHighQualityPlaybackPreference,
              child: _ButtonBackground(
                settingsController: settingsController,
                child: Icon(
                  preferHighQuality ? TablerIcons.diamond : TablerIcons.wave_sine,
                  size: _secondaryControlIconSize,
                  color: panelColor,
                ),
              ),
            ),
            _PlaybackControlButton(
              semanticsLabel: playbackModeControlLabel(
                playbackMode: playbackMode,
                orderMode: orderMode,
                repeatMode: repeatMode,
              ),
              onTap: playerController.handleRepeatModeTap,
              child: _ButtonBackground(
                settingsController: settingsController,
                child: Icon(
                  repeatIcon,
                  size: _secondaryControlIconSize,
                  color: panelColor,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PlaybackControlButton extends StatelessWidget {
  const _PlaybackControlButton({
    required this.semanticsLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticsLabel;
  final GestureTapCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: semanticsLabel,
      child: Tooltip(
        message: semanticsLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// 生成喜欢按钮的辅助语义标签。
@visibleForTesting
String playbackLikeControlLabel({required bool isLiked}) {
  return isLiked ? '取消喜欢' : '喜欢歌曲';
}

/// 生成播放按钮的辅助语义标签。
@visibleForTesting
String playbackPlayPauseControlLabel({required bool isPlaying}) {
  return isPlaying ? '暂停' : '播放';
}

/// 生成音质按钮的辅助语义标签。
@visibleForTesting
String playbackQualityControlLabel({required bool preferHighQuality}) {
  return preferHighQuality ? '音质：高音质优先' : '音质：标准音质';
}

/// 生成播放模式按钮的辅助语义标签。
@visibleForTesting
String playbackModeControlLabel({
  required PlaybackMode playbackMode,
  required PlaybackOrderMode orderMode,
  required PlaybackRepeatMode repeatMode,
}) {
  if (playbackMode == PlaybackMode.roaming) {
    return '播放模式：私人 FM';
  }
  if (playbackMode == PlaybackMode.heartbeat) {
    return '播放模式：心动模式';
  }
  if (orderMode == PlaybackOrderMode.shuffle) {
    return '播放模式：随机播放';
  }
  return switch (repeatMode) {
    PlaybackRepeatMode.one => '播放模式：单曲循环',
    PlaybackRepeatMode.none => '播放模式：不循环',
    PlaybackRepeatMode.all => '播放模式：列表循环',
    PlaybackRepeatMode.group => '播放模式：分组循环',
  };
}

class _ButtonBackground extends GetView<ShellController> {
  const _ButtonBackground({
    required this.settingsController,
    required this.child,
  });

  final SettingsController settingsController;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BlurryContainer(
        blur: controller.isBigAlbum.isTrue ? 0 : 5,
        padding: const EdgeInsets.all(_controlButtonPadding),
        borderRadius: BorderRadius.circular(100),
        color: settingsController.panelWidgetColor.value.withValues(
          alpha: controller.isBigAlbum.isTrue ? 0 : 0.05,
        ),
        child: child,
      ),
    );
  }
}
