import 'dart:async';

import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/core/diagnostics/playback_performance_logger.dart';
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
            () {
              final isBigAlbum = controller.isBigAlbum.isTrue;
              final size = isBigAlbum ? context.width - AppDimensions.paddingLarge * 2 : AppDimensions.albumMinSize;
              final borderRadius = isBigAlbum ? AppDimensions.paddingLarge / 2 : AppDimensions.albumMinSize;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: isBigAlbum
                    ? EdgeInsets.only(
                        right: AppDimensions.paddingLarge,
                        top: AppDimensions.appBarHeight + context.mediaQueryPadding.top + AppDimensions.paddingLarge,
                      )
                    : EdgeInsets.only(
                        right: AppDimensions.paddingLarge,
                        top: context.mediaQueryPadding.top + AppDimensions.paddingSmall,
                      ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                clipBehavior: Clip.hardEdge,
                width: size,
                height: size,
                child: Obx(() {
                  final currentSong = PlayerController.to.currentSongState.value;
                  final artworkPath = ArtworkPathResolver.resolveDisplayPath(
                    currentSong.artworkUrl ?? currentSong.localArtworkPath,
                  );
                  return SimpleExtendedImage(
                    artworkPath,
                    key: ValueKey(artworkPath),
                    width: size,
                    height: size,
                  );
                }),
                onEnd: () {
                  controller.isAlbumScaleEnded.value = true;
                  if (controller.isBigAlbum.isTrue) {
                    controller.syncAlbumPage(jump: true);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 底部面板大封面分页展示层。
class BottomPanelArtworkPageLayer extends StatefulWidget {
  /// 创建大封面分页展示层。
  const BottomPanelArtworkPageLayer({
    required this.controller,
    super.key,
  });

  /// 壳层控制器，提供专辑页控制器和面板状态。
  final ShellController controller;

  @override
  State<BottomPanelArtworkPageLayer> createState() => _BottomPanelArtworkPageLayerState();
}

class _BottomPanelArtworkPageLayerState extends State<BottomPanelArtworkPageLayer> {
  bool _wasVisible = false;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isVisible = widget.controller.bottomPanelFullyOpened.isTrue && widget.controller.isBigAlbum.isTrue && widget.controller.isAlbumScaleEnded.isTrue;
        if (isVisible && !_wasVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            widget.controller.syncAlbumPage(jump: true);
          });
        }
        _wasVisible = isVisible;
        return Offstage(
          offstage: !isVisible,
          child: Container(
            margin: EdgeInsets.only(
              top: context.mediaQueryPadding.top + AppDimensions.appBarHeight,
            ),
            height: context.width,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  if (notification.dragDetails != null) {
                    widget.controller.beginAlbumPageUserScroll();
                  }
                } else if (notification is ScrollEndNotification) {
                  unawaited(widget.controller.endAlbumPageUserScroll());
                }
                return false;
              },
              child: Obx(
                () {
                  final stopwatch = PlaybackPerformanceLogger.start();
                  final queue = PlayerController.to.artworkPageItems.toList();
                  final pageView = PageView.builder(
                    controller: widget.controller.albumPageController,
                    itemCount: queue.length,
                    allowImplicitScrolling: true,
                    onPageChanged: widget.controller.onAlbumPageChanged,
                    itemBuilder: (BuildContext context, int index) {
                      final item = queue[index];
                      final artworkPath = ArtworkPathResolver.resolveDisplayPath(
                        item.artworkUrl ?? item.localArtworkPath,
                      );
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Container(
                          key: ValueKey(item.id),
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
                              widget.controller.isAlbumScaleEnded.value = false;
                              widget.controller.isBigAlbum.value = false;
                              if (widget.controller.curPanelPageIndex.value == 1) {
                                PlayerController.to.updateFullScreenLyricTimerCounter();
                              }
                            },
                            child: SimpleExtendedImage(
                              artworkPath,
                              key: ValueKey(artworkPath),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                  PlaybackPerformanceLogger.elapsed(
                    'artworkPageLayer.buildPageView',
                    stopwatch,
                    details: 'queue=${queue.length}',
                    warnAfterMs: 2,
                  );
                  return pageView;
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
