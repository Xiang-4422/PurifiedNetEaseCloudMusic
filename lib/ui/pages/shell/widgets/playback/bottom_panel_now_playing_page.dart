import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_now_playing_metadata.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/lyric_view.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/keep_alive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 歌词区域点击入口的辅助语义标签。
@visibleForTesting
String bottomPanelLyricAreaControlLabel({
  required String title,
  required bool fullScreenLyricOpen,
}) {
  final resolvedTitle = title.trim().isEmpty ? '当前歌曲' : title.trim();
  return fullScreenLyricOpen ? '退出全屏歌词：$resolvedTitle' : '放大封面：$resolvedTitle';
}

/// 底部播放面板的正在播放页，组合歌词、专辑歌手信息和控制区。
class BottomPanelNowPlayingPage extends GetView<ShellController> {
  /// 创建正在播放页。
  const BottomPanelNowPlayingPage({
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 播放控制器，处理歌词全屏和封面切换交互。
  final PlayerController playerController;

  /// 设置控制器，提供播放面板取色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return KeepAliveWrapper(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          playerController.updateFullScreenLyricTimerCounter();
        },
        onPointerMove: (event) {
          playerController.updateFullScreenLyricTimerCounter();
        },
        onPointerUp: (event) {
          playerController.updateFullScreenLyricTimerCounter();
        },
        child: Stack(
          children: [
            Obx(
              () {
                final currentSong = playerController.currentSongState.value;
                final lyricAreaLabel = bottomPanelLyricAreaControlLabel(
                  title: currentSong.title,
                  fullScreenLyricOpen: playerController.isFullScreenLyricOpen.isTrue,
                );
                return Offstage(
                  offstage: controller.isBigAlbum.value,
                  child: Tooltip(
                    message: lyricAreaLabel,
                    child: Semantics(
                      button: true,
                      label: lyricAreaLabel,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _handleLyricAreaTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: albumPadding,
                          ),
                          child: LyricView(
                            const EdgeInsets.symmetric(vertical: 10),
                            playerController: playerController,
                            settingsController: settingsController,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Obx(
              () => Offstage(
                offstage: playerController.isFullScreenLyricOpen.isTrue && controller.isBigAlbum.isFalse,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                      () => Container(
                        height: controller.isBigAlbum.isTrue ? 0 : context.width - albumPadding,
                      ),
                    ),
                    BottomPanelNowPlayingMetadata(
                      playerController: playerController,
                      settingsController: settingsController,
                    ),
                    Expanded(
                      child: BottomPanelPlaybackControls(
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLyricAreaTap() {
    if (playerController.isFullScreenLyricOpen.isTrue) {
      playerController.isFullScreenLyricOpen.value = false;
      return;
    }
    controller.isAlbumScaleEnded.value = false;
    controller.isBigAlbum.value = true;
    playerController.updateFullScreenLyricTimerCounter(
      cancelTimer: true,
    );
  }
}
