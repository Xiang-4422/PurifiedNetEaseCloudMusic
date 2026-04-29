import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomPanelHeader extends StatelessWidget {
  const BottomPanelHeader({required this.controller, super.key});

  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      height: AppDimensions.appBarHeight,
      width: context.width,
      child: Obx(
        () => Visibility(
          visible: controller.bottomPanelFullyOpened.isTrue,
          child: Builder(
            builder: (context) {
              final currentSong = PlayerController.to.currentSongState.value;
              return Row(
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
                            color: SettingsController.to.panelWidgetColor.value,
                          ),
                        ),
                        Text(
                          currentSong.artist ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontSize:
                                context.textTheme.titleLarge!.fontSize! / 2,
                            color: SettingsController.to.panelWidgetColor.value
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Offstage(
                      offstage: controller.isBigAlbum.isTrue,
                      child: Visibility(
                        visible: controller.isAlbumScaleEnded.isTrue,
                        child: GestureDetector(
                          onTap: () {
                            if (PlayerController
                                .to.isFullScreenLyricOpen.isTrue) {
                              PlayerController
                                  .to.isFullScreenLyricOpen.value = false;
                            } else {
                              controller.isAlbumScaleEnded.value = false;
                              controller.isBigAlbum.value = true;
                              PlayerController.to
                                  .updateFullScreenLyricTimerCounter(
                                cancelTimer: true,
                              );
                            }
                          },
                          child: SimpleExtendedImage(
                            width: AppDimensions.albumMinSize,
                            height: AppDimensions.albumMinSize,
                            shape: BoxShape.circle,
                            ArtworkPathResolver.resolveDisplayPath(
                              currentSong.artworkUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
