import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_now_playing_metadata.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/lyric_view.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/keep_alive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部播放面板的正在播放页，组合歌词、专辑歌手信息和控制区。
class BottomPanelNowPlayingPage extends GetView<ShellController> {
  /// 创建正在播放页。
  const BottomPanelNowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return KeepAliveWrapper(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          PlayerController.to.updateFullScreenLyricTimerCounter();
        },
        onPointerMove: (event) {
          PlayerController.to.updateFullScreenLyricTimerCounter();
        },
        onPointerUp: (event) {
          PlayerController.to.updateFullScreenLyricTimerCounter();
        },
        child: Stack(
          children: [
            Obx(
              () => Offstage(
                offstage: controller.isBigAlbum.value,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (PlayerController.to.isFullScreenLyricOpen.isTrue) {
                      PlayerController.to.isFullScreenLyricOpen.value = false;
                    } else {
                      controller.isAlbumScaleEnded.value = false;
                      controller.isBigAlbum.value = true;
                      PlayerController.to.updateFullScreenLyricTimerCounter(
                        cancelTimer: true,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: albumPadding,
                    ),
                    child: const LyricView(EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
              ),
            ),
            Obx(
              () => Offstage(
                offstage: PlayerController.to.isFullScreenLyricOpen.isTrue && controller.isBigAlbum.isFalse,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                      () => Container(
                        height: controller.isBigAlbum.isTrue ? 0 : context.width - albumPadding,
                      ),
                    ),
                    const BottomPanelNowPlayingMetadata(),
                    const Expanded(child: BottomPanelPlaybackControls()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
