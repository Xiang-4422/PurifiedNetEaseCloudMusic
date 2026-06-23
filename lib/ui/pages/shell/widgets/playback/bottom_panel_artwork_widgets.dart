import 'package:bujuan/core/diagnostics/performance_logger.dart';
import 'package:bujuan/features/playback/playback_artwork_page_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部播放面板过渡层中的当前歌曲封面。
class BottomPanelCurrentArtworkImage extends StatelessWidget {
  /// 使用 [size] 固定封面尺寸，避免过渡动画期间布局抖动。
  const BottomPanelCurrentArtworkImage({
    required this.size,
    required this.playerController,
    super.key,
  });

  /// 封面宽高。
  final double size;

  /// 播放控制器，提供当前歌曲封面。
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final currentSong = playerController.currentSongState.value;
        final artworkPath = ArtworkPathResolver.resolveDisplayPath(
          ArtworkPathResolver.resolvePlaybackArtwork(
            artworkUrl: currentSong.artworkUrl,
            localArtworkPath: currentSong.localArtworkPath,
          ),
        );
        return SimpleExtendedImage(
          artworkPath,
          key: ValueKey(artworkPath),
          width: size,
          height: size,
        );
      },
    );
  }
}

/// 底部播放面板的大封面分页视图。
class BottomPanelArtworkPageViewport extends StatelessWidget {
  /// 使用 [controller] 承接封面分页控制和用户滚动状态。
  const BottomPanelArtworkPageViewport({
    required this.controller,
    required this.playerController,
    super.key,
  });

  /// 壳层控制器，持有封面分页 controller 和滚动同步逻辑。
  final ShellController controller;

  /// 播放控制器，提供封面分页队列和歌词计时器操作。
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Obx(
        () {
          final stopwatch = PerformanceLogger.start();
          final queue = playerController.artworkPageItems.toList();
          final pageView = PageView.builder(
            controller: controller.albumPageController,
            itemCount: queue.length,
            allowImplicitScrolling: true,
            onPageChanged: controller.onAlbumPageChanged,
            itemBuilder: (BuildContext context, int index) {
              return BottomPanelArtworkPageCard(
                item: queue[index],
                onTap: _collapseArtworkPage,
              );
            },
          );
          PerformanceLogger.elapsed(
            'artworkPageLayer.buildPageView',
            stopwatch,
            details: 'queue=${queue.length}',
            warnAfterMs: 2,
          );
          return pageView;
        },
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null) {
        controller.beginAlbumPageUserScroll();
      }
    } else if (notification is ScrollEndNotification) {
      controller.endAlbumPageUserScroll();
    }
    return false;
  }

  void _collapseArtworkPage() {
    controller.isAlbumScaleEnded.value = false;
    controller.isBigAlbum.value = false;
    if (controller.curPanelPageIndex.value == 1) {
      playerController.updateFullScreenLyricTimerCounter();
    }
  }
}

/// 大封面分页中的单个封面卡片。
class BottomPanelArtworkPageCard extends StatelessWidget {
  /// 使用轻量 [item] 渲染封面，并在点击时触发 [onTap]。
  const BottomPanelArtworkPageCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  /// 封面分页展示项。
  final PlaybackArtworkPageItem item;

  /// 点击封面卡片时触发。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artworkPath = ArtworkPathResolver.resolveDisplayPath(
      ArtworkPathResolver.resolvePlaybackArtwork(
        artworkUrl: item.artworkUrl,
        localArtworkPath: item.localArtworkPath,
      ),
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
          onTap: onTap,
          child: SimpleExtendedImage(
            artworkPath,
            key: ValueKey(artworkPath),
          ),
        ),
      ),
    );
  }
}
