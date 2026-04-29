import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// 底部播放面板进度条。
class BottomPanelProgressBar extends StatelessWidget {
  /// 创建底部播放面板进度条。
  const BottomPanelProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = PlayerController.to.currentSongState.value;
      final currentPosition = PlayerController.to.currentPositionState.value;
      return ProgressBar(
        progress: currentPosition,
        buffered: currentPosition,
        total: currentSong.duration ?? const Duration(seconds: 10),
        barHeight: AppDimensions.paddingLarge,
        barCapShape: BarCapShape.round,
        progressBarColor:
            SettingsController.to.panelWidgetColor.value.withValues(alpha: .1),
        baseBarColor:
            SettingsController.to.panelWidgetColor.value.withValues(alpha: .05),
        bufferedBarColor: Colors.transparent,
        thumbColor:
            SettingsController.to.panelWidgetColor.value.withValues(alpha: .05),
        thumbRadius: AppDimensions.paddingLarge / 2,
        thumbGlowRadius: AppDimensions.paddingLarge * 2 / 3,
        thumbCanPaintOutsideBar: false,
        timeLabelLocation: TimeLabelLocation.below,
        timeLabelTextStyle: const TextStyle(fontSize: 0),
        onSeek: (duration) => PlayerController.to.seekTo(duration),
      );
    });
  }
}

/// 底部播放面板播放控制按钮组。
class BottomPanelPlaybackControls extends GetView<ShellController> {
  /// 创建播放控制按钮组。
  const BottomPanelPlaybackControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      child: Obx(() {
        final currentSong = PlayerController.to.currentSongState.value;
        final currentSongId = int.tryParse(currentSong.sourceId);
        final isLiked =
            UserLibraryController.to.likedSongIds.contains(currentSongId);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ButtonBackground(
              child: GestureDetector(
                onTap: () async {
                  final updatedSong = await UserLibraryController.to
                      .toggleLikeStatus(currentSong);
                  if (updatedSong != null) {
                    await PlayerController.to.updatePlaybackQueueItem(
                      updatedSong,
                    );
                  }
                },
                child: Icon(
                  isLiked ? TablerIcons.heart_filled : TablerIcons.heart,
                  size: 30,
                  color: isLiked
                      ? Colors.red
                      : SettingsController.to.panelWidgetColor.value,
                ),
              ),
            ),
            _ButtonBackground(
              child: GestureDetector(
                onTap: PlayerController.to.skipToPreviousTrack,
                child: Obx(
                  () => Icon(
                    TablerIcons.player_skip_back_filled,
                    size: 30,
                    color: SettingsController.to.panelWidgetColor.value,
                  ),
                ),
              ),
            ),
            _ButtonBackground(
              child: GestureDetector(
                onTap: PlayerController.to.playOrPause,
                child: Obx(
                  () => Icon(
                    PlayerController.to.isPlaying.value
                        ? TablerIcons.player_pause_filled
                        : TablerIcons.player_play_filled,
                    size: 60,
                    color: SettingsController.to.panelWidgetColor.value,
                  ),
                ),
              ),
            ),
            _ButtonBackground(
              child: GestureDetector(
                onTap: PlayerController.to.skipToNextTrack,
                child: Obx(
                  () => Icon(
                    TablerIcons.player_skip_forward_filled,
                    size: 30,
                    color: SettingsController.to.panelWidgetColor.value,
                  ),
                ),
              ),
            ),
            _ButtonBackground(
              child: GestureDetector(
                onTap: PlayerController.to.handleRepeatModeTap,
                child: Obx(
                  () => Icon(
                    PlayerController.to.getRepeatIcon(),
                    size: 30,
                    color: SettingsController.to.panelWidgetColor.value,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ButtonBackground extends GetView<ShellController> {
  const _ButtonBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BlurryContainer(
        blur: controller.isBigAlbum.isTrue ? 0 : 5,
        padding: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(100),
        color: SettingsController.to.panelWidgetColor.value.withValues(
          alpha: controller.isBigAlbum.isTrue ? 0 : 0.05,
        ),
        child: child,
      ),
    );
  }
}
