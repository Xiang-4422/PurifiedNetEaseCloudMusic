import 'dart:async';

import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部面板从迷你封面到大封面的过渡层。
class BottomPanelArtworkTransitionLayer extends StatelessWidget {
  /// 创建封面过渡层。
  const BottomPanelArtworkTransitionLayer({
    required this.controller,
    super.key,
  });

  /// 壳层控制器，提供封面展开动画状态。
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

/// 底部面板大封面分页展示层。
class BottomPanelArtworkPageLayer extends StatelessWidget {
  /// 创建大封面分页展示层。
  const BottomPanelArtworkPageLayer({required this.controller, super.key});

  /// 壳层控制器，提供专辑页控制器和面板状态。
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
                  controller.beginAlbumPageUserScroll();
                }
              } else if (notification is ScrollEndNotification) {
                unawaited(controller.endAlbumPageUserScroll());
              }
              return false;
            },
            child: Obx(
              () {
                final queue = PlayerController.to.artworkPageItems.toList();
                return PageView.builder(
                  controller: controller.albumPageController,
                  itemCount: queue.length,
                  allowImplicitScrolling: true,
                  onPageChanged: controller.onAlbumPageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    final item = queue[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Container(
                        key: ValueKey(item.id),
                        clipBehavior: Clip.hardEdge,
                        margin:
                            const EdgeInsets.all(AppDimensions.paddingLarge),
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
                          child: SimpleExtendedImage(
                            ArtworkPathResolver.resolveDisplayPath(
                              item.artworkUrl ?? item.localArtworkPath,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
