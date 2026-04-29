import 'dart:math';
import 'dart:ui';

import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
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
  /// 创建 CoverFlowDemoPageView。
  const CoverFlowDemoPageView({super.key});

  @override
  State<CoverFlowDemoPageView> createState() => _CoverFlowDemoPageViewState();
}

class _CoverFlowDemoPageViewState extends State<CoverFlowDemoPageView> {
  late final PageController _controlsPageController;
  double _coverWidth = 180;
  CoverFlowInteractionMode _interactionMode = CoverFlowInteractionMode.pageSnap;
  int _controlsPageIndex = 0;
  int? _previewIndex;
  bool _isInteracting = false;
  double _dragSensitivity = 1;
  double _pageSnapVelocityThreshold = 320;
  double _inertialVelocityThreshold = 120;
  double _inertialFriction = .135;
  double _animationBaseMilliseconds = 180;
  double _animationPerItemMilliseconds = 110;
  double _nearGapFactor = .5;
  double _farGapFactor = .4;
  double _nearAngle = 30;
  double _farAngle = 60;
  double _perspective = .001;
  double _centerScale = 1;
  double _sideScale = .84;
  double _centerOpacity = 1;
  double _sideOpacity = .58;
  double _sideVerticalOffset = 24;

  @override
  void initState() {
    super.initState();
    _controlsPageController = PageController();
  }

  @override
  void dispose() {
    _controlsPageController.dispose();
    super.dispose();
  }

  CoverFlowStyle get _coverFlowStyle => CoverFlowStyle(
        nearGapFactor: _nearGapFactor,
        farGapFactor: _farGapFactor,
        nearAngle: _nearAngle / 180 * 3.1415926535897932,
        farAngle: _farAngle / 180 * 3.1415926535897932,
        perspective: _perspective,
        centerScale: _centerScale,
        sideScale: _sideScale,
        centerOpacity: _centerOpacity,
        sideOpacity: _sideOpacity,
        sideVerticalOffset: _sideVerticalOffset,
      );

  String? _resolveArtwork(PlaybackQueueItem item) {
    return ArtworkPathResolver.resolvePreferredArtwork(
      item.artworkUrl,
      fallbackItems: [item],
    );
  }

  double _resolveCardExtent(Size screenSize, {required bool isLandscape}) {
    final availableWidth = screenSize.width;
    final availableHeight = screenSize.height;
    final requestedWidth = _coverWidth;

    if (isLandscape) {
      final maxCardExtent = min(availableWidth * .42, availableHeight * .72);
      return requestedWidth.clamp(180.0, max(180.0, min(360.0, maxCardExtent)));
    }

    final maxCardExtent = min(availableWidth - 48, availableHeight * .34);
    return requestedWidth.clamp(120.0, max(120.0, min(260.0, maxCardExtent)));
  }

  int _resolveDisplayIndex({
    required int queueLength,
    required int playerIndex,
  }) {
    if (queueLength <= 0) {
      return 0;
    }
    final previewIndex = _previewIndex;
    if (previewIndex == null) {
      return playerIndex.clamp(0, queueLength - 1);
    }
    return previewIndex.clamp(0, queueLength - 1);
  }

  void _updatePreviewIndex(int index, {bool interacting = true}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _previewIndex = index;
      _isInteracting = interacting;
    });
  }

  Widget _buildCoverWidget(PlaybackQueueItem item, int index) {
    final imageUrl = _resolveArtwork(item);
    return DecoratedBox(
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
                  item.title,
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
                  '${item.artist ?? '未知歌手'} · ${index + 1}',
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
    );
  }

  Widget _buildCoverFlowStage({
    required List<PlaybackQueueItem> queue,
    required int displayIndex,
    required double cardExtent,
    required bool isLandscape,
  }) {
    return CoverFlow(
      itemCount: queue.length,
      itemBuilder: (_, index) => _buildCoverWidget(queue[index], index),
      itemKeyBuilder: (index) => ValueKey(queue[index].id),
      itemSize: Size(cardExtent, cardExtent),
      currentIndex: displayIndex,
      visibleRange: isLandscape ? 8 : 6,
      interactionMode: _interactionMode,
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 40 : 24),
      dragSensitivity: _dragSensitivity,
      pageSnapVelocityThreshold: _pageSnapVelocityThreshold,
      inertialVelocityThreshold: _inertialVelocityThreshold,
      inertialFriction: _inertialFriction,
      animationBaseDuration:
          Duration(milliseconds: _animationBaseMilliseconds.round()),
      animationPerItemDuration:
          Duration(milliseconds: _animationPerItemMilliseconds.round()),
      onInteractionStart: () {
        _updatePreviewIndex(displayIndex);
      },
      onIndexChanged: _updatePreviewIndex,
      onInteractionEnd: (index) {
        _updatePreviewIndex(index, interacting: false);
      },
      onTapItem: (index) {
        _updatePreviewIndex(index, interacting: false);
      },
      style: _coverFlowStyle,
    );
  }

  Widget _buildPreviewHeader(PlaybackQueueItem displayItem, int queueLength) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            displayItem.title,
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
            '${displayItem.artist ?? '未知歌手'} · 当前播放列表 $queueLength 张封面'
            '${_isInteracting ? ' · 预览中' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .74),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _buildParameterSummary(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .56),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _buildParameterSummary() {
    return 'W${_coverWidth.toStringAsFixed(0)} '
        'G${_nearGapFactor.toStringAsFixed(2)}/${_farGapFactor.toStringAsFixed(2)} '
        'A${_nearAngle.toStringAsFixed(0)}/${_farAngle.toStringAsFixed(0)} '
        'S${_centerScale.toStringAsFixed(2)}/${_sideScale.toStringAsFixed(2)} '
        'O${_centerOpacity.toStringAsFixed(2)}/${_sideOpacity.toStringAsFixed(2)} '
        'D${_dragSensitivity.toStringAsFixed(2)} '
        'F${_inertialFriction.toStringAsFixed(3)}';
  }

  Widget _buildPortraitPreview({
    required List<PlaybackQueueItem> queue,
    required int displayIndex,
    required double cardExtent,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: SizedBox(
        height: cardExtent + 54,
        child: _buildCoverFlowStage(
          queue: queue,
          displayIndex: displayIndex,
          cardExtent: cardExtent,
          isLandscape: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerController = PlayerController.to;
    final screenSize = MediaQuery.sizeOf(context);
    final isLandscape = screenSize.width > screenSize.height;
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
        final safePlayerIndex =
            currentDisplayIndex >= 0 ? currentDisplayIndex : 0;
        final displayIndex = _resolveDisplayIndex(
          queueLength: queue.length,
          playerIndex: safePlayerIndex,
        );
        final displayItem = queue[displayIndex];
        final currentArtwork = _resolveArtwork(displayItem) ?? '';

        final cardExtent = _resolveCardExtent(
          screenSize,
          isLandscape: isLandscape,
        );
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
              child: isLandscape
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _buildCoverFlowStage(
                          queue: queue,
                          displayIndex: displayIndex,
                          cardExtent: cardExtent,
                          isLandscape: true,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildTopBar(context),
                        const SizedBox(height: 8),
                        _buildPreviewHeader(displayItem, queue.length),
                        const SizedBox(height: 14),
                        _buildPortraitPreview(
                          queue: queue,
                          displayIndex: displayIndex,
                          cardExtent: cardExtent,
                        ),
                        Expanded(child: _buildBottomControls(context)),
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
          const SizedBox(width: 6),
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
          const Spacer(),
          _buildInteractionModeToggle(compact: true),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    const pageTitles = ['布局', '旋转', '外观', '交互'];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18 + MediaQuery.paddingOf(context).bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    pageTitles[_controlsPageIndex],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .92),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  for (int index = 0; index < pageTitles.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: _controlsPageIndex == index ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _controlsPageIndex == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: .26),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView(
                  controller: _controlsPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _controlsPageIndex = index;
                    });
                  },
                  children: [
                    _buildControlsPage(
                      children: [
                        _buildSliderControl(
                          label: '封面宽度',
                          valueLabel: _coverWidth.toStringAsFixed(0),
                          value: _coverWidth,
                          min: 120,
                          max: 320,
                          divisions: 20,
                          onChanged: (value) {
                            setState(() {
                              _coverWidth = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '近侧间距',
                          valueLabel: _nearGapFactor.toStringAsFixed(2),
                          value: _nearGapFactor,
                          min: .2,
                          max: 1,
                          divisions: 16,
                          onChanged: (value) {
                            setState(() {
                              _nearGapFactor = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '远侧间距',
                          valueLabel: _farGapFactor.toStringAsFixed(2),
                          value: _farGapFactor,
                          min: .1,
                          max: .8,
                          divisions: 14,
                          onChanged: (value) {
                            setState(() {
                              _farGapFactor = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '侧边纵向位移',
                          valueLabel: _sideVerticalOffset.toStringAsFixed(0),
                          value: _sideVerticalOffset,
                          min: 0,
                          max: 48,
                          divisions: 24,
                          onChanged: (value) {
                            setState(() {
                              _sideVerticalOffset = value;
                            });
                          },
                        ),
                      ],
                    ),
                    _buildControlsPage(
                      children: [
                        _buildSliderControl(
                          label: '近侧角度',
                          valueLabel: '${_nearAngle.toStringAsFixed(0)}°',
                          value: _nearAngle,
                          min: 0,
                          max: 75,
                          divisions: 15,
                          onChanged: (value) {
                            setState(() {
                              _nearAngle = value;
                              if (_farAngle < value) {
                                _farAngle = value;
                              }
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '远侧角度',
                          valueLabel: '${_farAngle.toStringAsFixed(0)}°',
                          value: _farAngle,
                          min: _nearAngle,
                          max: 89,
                          divisions: ((_maxFarAngleSpan(_nearAngle)) / 2)
                              .floor()
                              .clamp(1, 44),
                          onChanged: (value) {
                            setState(() {
                              _farAngle = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '透视强度',
                          valueLabel: _perspective.toStringAsFixed(4),
                          value: _perspective,
                          min: 0,
                          max: .003,
                          divisions: 30,
                          onChanged: (value) {
                            setState(() {
                              _perspective = value;
                            });
                          },
                        ),
                      ],
                    ),
                    _buildControlsPage(
                      children: [
                        _buildSliderControl(
                          label: '中心缩放',
                          valueLabel: _centerScale.toStringAsFixed(2),
                          value: _centerScale,
                          min: .8,
                          max: 1.2,
                          divisions: 20,
                          onChanged: (value) {
                            setState(() {
                              _centerScale = value;
                              if (_sideScale > value) {
                                _sideScale = value;
                              }
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '侧边缩放',
                          valueLabel: _sideScale.toStringAsFixed(2),
                          value: _sideScale,
                          min: .5,
                          max: _centerScale,
                          divisions:
                              ((_centerScale - .5) * 20).round().clamp(1, 20),
                          onChanged: (value) {
                            setState(() {
                              _sideScale = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '中心透明度',
                          valueLabel: _centerOpacity.toStringAsFixed(2),
                          value: _centerOpacity,
                          min: .3,
                          max: 1,
                          divisions: 14,
                          onChanged: (value) {
                            setState(() {
                              _centerOpacity = value;
                              if (_sideOpacity > value) {
                                _sideOpacity = value;
                              }
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '侧边透明度',
                          valueLabel: _sideOpacity.toStringAsFixed(2),
                          value: _sideOpacity,
                          min: .1,
                          max: _centerOpacity,
                          divisions:
                              ((_centerOpacity - .1) * 20).round().clamp(1, 18),
                          onChanged: (value) {
                            setState(() {
                              _sideOpacity = value;
                            });
                          },
                        ),
                      ],
                    ),
                    _buildControlsPage(
                      children: [
                        _buildSliderControl(
                          label: '拖动灵敏度',
                          valueLabel: _dragSensitivity.toStringAsFixed(2),
                          value: _dragSensitivity,
                          min: .6,
                          max: 1.6,
                          divisions: 20,
                          onChanged: (value) {
                            setState(() {
                              _dragSensitivity = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '翻页触发速度',
                          valueLabel:
                              _pageSnapVelocityThreshold.toStringAsFixed(0),
                          value: _pageSnapVelocityThreshold,
                          min: 120,
                          max: 720,
                          divisions: 24,
                          onChanged: (value) {
                            setState(() {
                              _pageSnapVelocityThreshold = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '惯性触发速度',
                          valueLabel:
                              _inertialVelocityThreshold.toStringAsFixed(0),
                          value: _inertialVelocityThreshold,
                          min: 80,
                          max: 640,
                          divisions: 28,
                          onChanged: (value) {
                            setState(() {
                              _inertialVelocityThreshold = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '惯性摩擦',
                          valueLabel: _inertialFriction.toStringAsFixed(3),
                          value: _inertialFriction,
                          min: .08,
                          max: .24,
                          divisions: 16,
                          onChanged: (value) {
                            setState(() {
                              _inertialFriction = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '基础动画时长',
                          valueLabel:
                              _animationBaseMilliseconds.toStringAsFixed(0),
                          value: _animationBaseMilliseconds,
                          min: 120,
                          max: 320,
                          divisions: 20,
                          onChanged: (value) {
                            setState(() {
                              _animationBaseMilliseconds = value;
                            });
                          },
                        ),
                        _buildSliderControl(
                          label: '每项附加时长',
                          valueLabel:
                              _animationPerItemMilliseconds.toStringAsFixed(0),
                          value: _animationPerItemMilliseconds,
                          min: 60,
                          max: 220,
                          divisions: 16,
                          onChanged: (value) {
                            setState(() {
                              _animationPerItemMilliseconds = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionModeToggle({bool compact = false}) {
    return SegmentedButton<CoverFlowInteractionMode>(
      segments: [
        ButtonSegment<CoverFlowInteractionMode>(
          value: CoverFlowInteractionMode.pageSnap,
          label: Text(compact ? '翻页' : '翻页模式'),
        ),
        ButtonSegment<CoverFlowInteractionMode>(
          value: CoverFlowInteractionMode.inertialSnap,
          label: Text(compact ? '惯性' : '惯性模式'),
        ),
      ],
      selected: {_interactionMode},
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: compact ? VisualDensity.compact : null,
        tapTargetSize: compact
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 8 : 12,
          ),
        ),
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
    );
  }

  int _maxFarAngleSpan(double value) {
    return (89 - value).round().clamp(1, 89);
  }

  Widget _buildControlsPage({
    required List<Widget> children,
  }) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSliderControl({
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .82),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .62),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: .18),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: .12),
              trackHeight: 3,
            ),
            child: Slider(
              min: min,
              max: max,
              divisions: divisions,
              value: value.clamp(min, max),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
