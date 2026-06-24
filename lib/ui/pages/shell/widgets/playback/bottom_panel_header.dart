import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部播放面板顶部小封面入口的辅助语义标签。
@visibleForTesting
String bottomPanelHeaderArtworkControlLabel({
  required String title,
  required bool fullScreenLyricOpen,
}) {
  final resolvedTitle = title.trim().isEmpty ? '当前歌曲' : title.trim();
  return fullScreenLyricOpen ? '退出全屏歌词：$resolvedTitle' : '放大封面：$resolvedTitle';
}

/// 底部播放面板展开态的顶部歌曲信息栏。
class BottomPanelHeader extends StatelessWidget {
  /// 创建底部播放面板顶部信息栏。
  const BottomPanelHeader({
    required this.controller,
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 壳层控制器，提供面板展开和封面动画状态。
  final ShellController controller;

  /// 播放控制器。
  final PlayerController playerController;

  /// 设置控制器。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      height: AppDimensions.appBarHeight,
      width: context.width,
      child: Obx(
        () {
          final currentSong = playerController.currentSongState.value;
          return Visibility(
            visible: controller.bottomPanelFullyOpened.isTrue,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
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
                Obx(
                  () {
                    final artworkControlLabel = bottomPanelHeaderArtworkControlLabel(
                      title: currentSong.title,
                      fullScreenLyricOpen: playerController.isFullScreenLyricOpen.isTrue,
                    );
                    return Offstage(
                      offstage: controller.isBigAlbum.isTrue,
                      child: Visibility(
                        visible: controller.isAlbumScaleEnded.isTrue,
                        child: Tooltip(
                          message: artworkControlLabel,
                          child: Semantics(
                            button: true,
                            label: artworkControlLabel,
                            child: ExcludeSemantics(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (playerController.isFullScreenLyricOpen.isTrue) {
                                    playerController.isFullScreenLyricOpen.value = false;
                                  } else {
                                    controller.isAlbumScaleEnded.value = false;
                                    controller.isBigAlbum.value = true;
                                    playerController.updateFullScreenLyricTimerCounter(
                                      cancelTimer: true,
                                    );
                                  }
                                },
                                child: SimpleExtendedImage(
                                  width: AppDimensions.albumMinSize,
                                  height: AppDimensions.albumMinSize,
                                  shape: BoxShape.circle,
                                  ArtworkPathResolver.resolveDisplayPath(
                                    ArtworkPathResolver.resolvePlaybackArtwork(
                                      artworkUrl: currentSong.artworkUrl,
                                      localArtworkPath: currentSong.localArtworkPath,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
