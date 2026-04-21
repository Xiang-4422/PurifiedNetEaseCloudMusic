import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/widget/artwork_display.dart';
import 'package:bujuan/widget/cover_flow/coverflow.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// CoverFlow 仍是预留组件，这个页面单独承接它的交互验证，避免把实验性 UI 混进主流程。
///
/// 数据直接取当前播放列表里的封面，能让我们验证：
/// 1. 组件在真实音乐数据上的表现；
/// 2. 本地封面优先链路是否能被 `CoverFlow` 正常消费；
/// 3. 后续如果把它重新接回播放页，不需要再临时造假数据。
class CoverFlowDemoPageView extends StatefulWidget {
  const CoverFlowDemoPageView({super.key});

  @override
  State<CoverFlowDemoPageView> createState() => _CoverFlowDemoPageViewState();
}

class _CoverFlowDemoPageViewState extends State<CoverFlowDemoPageView> {
  double _visibleCoverCount = 4;
  CoverFlowInteractionMode _interactionMode =
      CoverFlowInteractionMode.pageSnap;

  String? _resolveArtwork(MediaItem mediaItem) {
    return ArtworkDisplay.resolvePreferredArtwork(
      mediaItem.extras?['image'] as String?,
      fallbackItems: [mediaItem],
    );
  }

  double _resolveCardSize(double screenWidth) {
    const horizontalPadding = 24.0;
    final availableWidth = (screenWidth - horizontalPadding).clamp(220.0, 520.0);
    return (availableWidth / _visibleCoverCount).clamp(180.0, 340.0);
  }

  Widget _buildCoverWidget(MediaItem mediaItem, int index) {
    final imageUrl = _resolveArtwork(mediaItem);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: .12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SimpleExtendedImage(
              imageUrl ?? '',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .18),
                    Colors.black.withValues(alpha: .72),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mediaItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${mediaItem.artist ?? '未知歌手'} · ${index + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerController = PlayerController.to;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final runtimeState = playerController.runtimeState.value;
        final queue = runtimeState.queue
            .where((item) => _resolveArtwork(item)?.isNotEmpty == true)
            .toList(growable: false);
        final currentDisplayIndex = queue.indexWhere(
          (item) => item.id == runtimeState.currentSong.id,
        );
        final safeDisplayIndex = currentDisplayIndex >= 0 ? currentDisplayIndex : 0;
        final currentArtwork = _resolveArtwork(runtimeState.currentSong) ??
            _resolveArtwork(
              queue.isNotEmpty ? queue[safeDisplayIndex] : runtimeState.currentSong,
            ) ??
            '';

        if (queue.isEmpty) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context),
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '当前播放列表没有可用封面。先播放一组歌曲，再回来查看 CoverFlow 效果。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final cardSize = _resolveCardSize(screenWidth);
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: currentArtwork.isEmpty
                    ? const ColoredBox(
                        key: ValueKey('empty-background'),
                        color: Colors.black,
                      )
                    : ImageFiltered(
                        key: ValueKey(currentArtwork),
                        imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                        child: Transform.scale(
                          scale: 1.18,
                          child: Opacity(
                            opacity: .42,
                            child: SimpleExtendedImage(
                              currentArtwork,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .45),
                      Colors.black.withValues(alpha: .18),
                      Colors.black.withValues(alpha: .78),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          runtimeState.currentSong.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${runtimeState.currentSong.artist ?? '未知歌手'} · 当前播放列表 ${queue.length} 张封面',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .74),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                      child: CoverFlow(
                        itemCount: queue.length,
                        itemBuilder: (_, index) =>
                            _buildCoverWidget(queue[index], index),
                        itemKeyBuilder: (index) => ValueKey(queue[index].id),
                        cardSize: cardSize,
                        currentIndex: safeDisplayIndex,
                        visibleRange: 6,
                        interactionMode: _interactionMode,
                      ),
                    ),
                  ),
                  _buildBottomControls(context),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'CoverFlow Demo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        18 + AppDimensions.bottomPanelHeaderHeight,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<CoverFlowInteractionMode>(
                  segments: const [
                    ButtonSegment<CoverFlowInteractionMode>(
                      value: CoverFlowInteractionMode.pageSnap,
                      label: Text('翻页'),
                    ),
                    ButtonSegment<CoverFlowInteractionMode>(
                      value: CoverFlowInteractionMode.inertialSnap,
                      label: Text('惯性'),
                    ),
                  ],
                  selected: {_interactionMode},
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.black;
                      }
                      return Colors.white;
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.white.withValues(alpha: .08);
                    }),
                    side: WidgetStateProperty.all(
                      BorderSide(color: Colors.white.withValues(alpha: .1)),
                    ),
                  ),
                  onSelectionChanged: (selection) {
                    setState(() {
                      _interactionMode = selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '单屏封面 ${_visibleCoverCount.round()} 张',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .7),
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: .18),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: .12),
                  ),
                  child: Slider(
                    min: 2,
                    max: 6,
                    divisions: 4,
                    label: '${_visibleCoverCount.round()}',
                    value: _visibleCoverCount,
                    onChanged: (value) {
                      setState(() {
                        _visibleCoverCount = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
