import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// BottomPanelArtworkTransitionLayer。
class BottomPanelArtworkTransitionLayer extends StatelessWidget {
  /// 创建 BottomPanelArtworkTransitionLayer。
  const BottomPanelArtworkTransitionLayer({
    required this.controller,
    super.key,
  });

  /// controller。
  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Offstage(
        offstage: controller.isAlbumScaleEnded.isTrue,
        child: Container(
          alignment: Alignment.topRight,
          child: Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: controller.isBigAlbum.isTrue
                  ? EdgeInsets.only(
                      right: AppDimensions.paddingLarge,
                      top: AppDimensions.appBarHeight +
                          context.mediaQueryPadding.top +
                          AppDimensions.paddingLarge,
                    )
                  : EdgeInsets.only(
                      right: AppDimensions.paddingLarge,
                      top: context.mediaQueryPadding.top +
                          AppDimensions.paddingSmall,
                    ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(
                  controller.isBigAlbum.isTrue
                      ? AppDimensions.paddingLarge / 2
                      : AppDimensions.albumMinSize,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              width: controller.isBigAlbum.isTrue
                  ? context.width - AppDimensions.paddingLarge * 2
                  : AppDimensions.albumMinSize,
              height: controller.isBigAlbum.isTrue
                  ? context.width - AppDimensions.paddingLarge * 2
                  : AppDimensions.albumMinSize,
              child: Obx(() {
                final currentSong = PlayerController.to.currentSongState.value;
                return SimpleExtendedImage(
                  ArtworkPathResolver.resolveDisplayPath(
                    currentSong.artworkUrl ?? currentSong.localArtworkPath,
                  ),
                );
              }),
              onEnd: () => controller.isAlbumScaleEnded.value = true,
            ),
          ),
        ),
      ),
    );
  }
}

/// BottomPanelArtworkPageLayer。
class BottomPanelArtworkPageLayer extends StatelessWidget {
  /// 创建 BottomPanelArtworkPageLayer。
  const BottomPanelArtworkPageLayer({required this.controller, super.key});

  /// controller。
  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Offstage(
        offstage: controller.bottomPanelFullyOpened.isFalse ||
            controller.isBigAlbum.isFalse ||
            controller.isAlbumScaleEnded.isFalse,
        child: Container(
          margin: EdgeInsets.only(
            top: context.mediaQueryPadding.top + AppDimensions.appBarHeight,
          ),
          height: context.width,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                if (notification.dragDetails != null) {
                  controller.isAlbumScrollingManully = true;
                  controller.isAlbumScrollingProgrammatic = false;
                }
              } else if (notification is ScrollEndNotification) {
                controller.isAlbumScrollingManully = false;
              }
              return false;
            },
            child: PageView.builder(
              controller: controller.albumPageController,
              itemCount: PlayerController.to.queueState.length,
              allowImplicitScrolling: true,
              onPageChanged: controller.onAlbumPageChanged,
              itemBuilder: (BuildContext context, int index) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(AppDimensions.paddingLarge),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.paddingLarge / 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        controller.isAlbumScaleEnded.value = false;
                        controller.isBigAlbum.value = false;
                        if (controller.curPanelPageIndex.value == 1) {
                          PlayerController.to
                              .updateFullScreenLyricTimerCounter();
                        }
                      },
                      child: Obx(() {
                        final item = PlayerController.to.queueState[index];
                        return SimpleExtendedImage(
                          ArtworkPathResolver.resolveDisplayPath(
                            item.artworkUrl ?? item.localArtworkPath,
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
