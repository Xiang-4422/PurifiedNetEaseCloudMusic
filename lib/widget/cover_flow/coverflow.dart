library coverflow;

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

typedef CoverFlowItemBuilder = Widget Function(BuildContext context, int index);
typedef CoverFlowItemKeyBuilder = Key? Function(int index);
typedef CoverFlowItemWidgetBuilder = Widget Function(int index);

enum CoverFlowInteractionMode {
  pageSnap,
  inertialSnap,
}

/// CoverFlow 的视觉参数。
///
/// 默认值保持当前封面流效果不变，但把关键比例显式暴露出来，后续如果要调整成更平或更夸张
/// 的版本，不需要再回到组件内部改公式。
class CoverFlowStyle {
  final double nearGapFactor;
  final double farGapFactor;
  final double nearAngle;
  final double farAngle;
  final double perspective;
  final double centerScale;
  final double sideScale;
  final double centerOpacity;
  final double sideOpacity;
  final double sideVerticalOffset;

  const CoverFlowStyle({
    this.nearGapFactor = .5,
    this.farGapFactor = .4,
    this.nearAngle = pi / 6,
    this.farAngle = pi / 3,
    this.perspective = .001,
    this.centerScale = 1,
    this.sideScale = .82,
    this.centerOpacity = 1,
    this.sideOpacity = .68,
    this.sideVerticalOffset = 18,
  });
}

/// 通用封面流组件。
///
/// 组件围绕“当前中心索引”工作，不再依赖透明滚动覆盖层或 `List<Widget>` 作为事实源。
/// 这样可以保证：
/// - 程序切换和手动拖动使用同一套索引语义；
/// - 子项仍然能接收点击、语义和焦点；
/// - 上层可以通过稳定 key 管理重排后的子树复用。
class CoverFlow extends StatefulWidget {
  final int itemCount;
  final CoverFlowItemBuilder itemBuilder;
  final CoverFlowItemKeyBuilder? itemKeyBuilder;
  final Size itemSize;
  final int currentIndex;
  final int visibleRange;
  final ValueChanged<int>? onIndexChanged;
  final ValueChanged<int>? onTapItem;
  final VoidCallback? onInteractionStart;
  final ValueChanged<int>? onInteractionEnd;
  final CoverFlowStyle style;
  final CoverFlowInteractionMode interactionMode;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;
  final Curve animationCurve;
  final Duration animationBaseDuration;
  final Duration animationPerItemDuration;
  final double dragSensitivity;
  final double pageSnapVelocityThreshold;
  final double inertialVelocityThreshold;
  final double inertialFriction;
  final double inertialSimulationMinDelta;

  CoverFlow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemSize,
    this.itemKeyBuilder,
    this.currentIndex = 0,
    this.visibleRange = 6,
    this.onIndexChanged,
    this.onTapItem,
    this.onInteractionStart,
    this.onInteractionEnd,
    this.style = const CoverFlowStyle(),
    this.interactionMode = CoverFlowInteractionMode.pageSnap,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.none,
    Curve? animationCurve,
    this.animationBaseDuration = const Duration(milliseconds: 180),
    this.animationPerItemDuration = const Duration(milliseconds: 110),
    this.dragSensitivity = 1,
    this.pageSnapVelocityThreshold = 320,
    this.inertialVelocityThreshold = 120,
    this.inertialFriction = .135,
    this.inertialSimulationMinDelta = .04,
  }) : assert(itemSize.width > 0 && itemSize.height > 0),
       assert(visibleRange >= 0),
       assert(dragSensitivity > 0),
       assert(pageSnapVelocityThreshold >= 0),
       assert(inertialVelocityThreshold >= 0),
       assert(inertialFriction > 0),
       assert(inertialSimulationMinDelta >= 0),
       animationCurve = animationCurve ?? Curves.easeOutQuart;

  @override
  State<CoverFlow> createState() => _CoverFlowState();
}

class _CoverFlowState extends State<CoverFlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _positionController;
  final Map<Object, _CachedCoverFlowChild> _itemChildCache = {};
  bool _isDragging = false;
  int _lastReportedIndex = -1;

  double get _pagePosition => _positionController.value;

  set _pagePosition(double value) {
    _positionController.value = value;
  }

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController.unbounded(
      vsync: this,
      value: _clampIndex(widget.currentIndex).toDouble(),
    )..addListener(_reportIndexIfNeeded);
    _lastReportedIndex = _clampIndex(widget.currentIndex);
  }

  @override
  void didUpdateWidget(covariant CoverFlow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.itemBuilder != widget.itemBuilder ||
        oldWidget.itemKeyBuilder != widget.itemKeyBuilder) {
      _itemChildCache.clear();
    }

    if (widget.itemCount <= 0) {
      _positionController.stop();
      if (_pagePosition != 0) {
        _pagePosition = 0;
      }
      _lastReportedIndex = -1;
      return;
    }

    final currentIndexChanged = oldWidget.currentIndex != widget.currentIndex;
    final countChanged = oldWidget.itemCount != widget.itemCount;

    if (countChanged) {
      final clampedIndex = _clampIndex(widget.currentIndex);
      if ((_pagePosition - clampedIndex).abs() >= 0.01) {
        _jumpToIndex(clampedIndex);
      }
      return;
    }

    if (currentIndexChanged && !_isDragging) {
      unawaited(_animateToIndex(_clampIndex(widget.currentIndex)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemChildCache.clear();
  }

  int _clampIndex(int index) {
    if (widget.itemCount <= 0) {
      return 0;
    }
    return index.clamp(0, widget.itemCount - 1);
  }

  void _reportIndexIfNeeded() {
    if (widget.onIndexChanged == null || widget.itemCount <= 0) {
      return;
    }
    final nextIndex = _clampIndex(_pagePosition.round());
    if (nextIndex == _lastReportedIndex) {
      return;
    }
    _lastReportedIndex = nextIndex;
    widget.onIndexChanged?.call(nextIndex);
  }

  void _jumpToIndex(int index) {
    _positionController.stop();
    _pagePosition = index.toDouble();
  }

  Future<void> _animateToIndex(int index) {
    if (widget.itemCount <= 0) {
      return Future<void>.value();
    }
    final targetIndex = _clampIndex(index);
    if ((_pagePosition - targetIndex).abs() < 0.01) {
      return Future<void>.value();
    }
    return _positionController.animateTo(
      targetIndex.toDouble(),
      duration: _buildAnimationDuration(targetIndex),
      curve: _resolveAnimationCurve(),
    );
  }

  Curve _resolveAnimationCurve() {
    return switch (widget.interactionMode) {
      CoverFlowInteractionMode.pageSnap => widget.animationCurve,
      CoverFlowInteractionMode.inertialSnap => Curves.easeOutCubic,
    };
  }

  Duration _buildAnimationDuration(int targetIndex) {
    final distance = (_pagePosition - targetIndex).abs();
    final base = widget.animationBaseDuration.inMilliseconds +
        switch (widget.interactionMode) {
          CoverFlowInteractionMode.pageSnap => 0,
          CoverFlowInteractionMode.inertialSnap => 40,
        };
    final perIndex = widget.animationPerItemDuration.inMilliseconds +
        switch (widget.interactionMode) {
          CoverFlowInteractionMode.pageSnap => 0,
          CoverFlowInteractionMode.inertialSnap => 30,
        };
    final milliseconds = (base + distance * perIndex).round().clamp(220, 680);
    return Duration(milliseconds: milliseconds);
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    if (widget.itemCount <= 0) {
      return;
    }
    _isDragging = true;
    _positionController.stop();
    widget.onInteractionStart?.call();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.itemCount <= 0) {
      return;
    }
    final nextPosition = (_pagePosition -
            details.primaryDelta! / widget.itemSize.width * widget.dragSensitivity)
        .clamp(0.0, max(0, widget.itemCount - 1).toDouble());
    _pagePosition = nextPosition;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (widget.itemCount <= 0) {
      return;
    }
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    if (widget.interactionMode == CoverFlowInteractionMode.inertialSnap) {
      unawaited(_animateInertialSnap(velocity));
      return;
    }
    final targetIndex = _resolvePageSnapTargetIndex(velocity);
    widget.onInteractionEnd?.call(targetIndex);
    unawaited(_animateToIndex(targetIndex));
  }

  int _resolvePageSnapTargetIndex(double velocity) {
    if (velocity.abs() < widget.pageSnapVelocityThreshold) {
      return _clampIndex(_pagePosition.round());
    }
    if (velocity < 0) {
      return _clampIndex(_pagePosition.ceil());
    }
    return _clampIndex(_pagePosition.floor());
  }

  Future<void> _animateInertialSnap(double velocity) async {
    final indexVelocity =
        -(velocity / widget.itemSize.width) * widget.dragSensitivity;
    const minPosition = 0.0;
    final maxPosition = max(0, widget.itemCount - 1).toDouble();

    if (velocity.abs() < widget.inertialVelocityThreshold) {
      final targetIndex = _clampIndex(_pagePosition.round());
      widget.onInteractionEnd?.call(targetIndex);
      await _animateToIndex(targetIndex);
      return;
    }

    final projectedPosition = _resolveInertialProjectedPosition(
      indexVelocity: indexVelocity,
      minPosition: minPosition,
      maxPosition: maxPosition,
    );
    final targetIndex = _resolveInertialTargetIndex(
      projectedPosition,
      indexVelocity,
    );

    widget.onInteractionEnd?.call(targetIndex);

    if ((projectedPosition - _pagePosition).abs() >=
        widget.inertialSimulationMinDelta) {
      await _positionController.animateTo(
        projectedPosition,
        duration: _buildInertialGlideDuration(projectedPosition, indexVelocity),
        curve: Curves.decelerate,
      );
    }

    if (!mounted) {
      return;
    }
    await _animateToIndex(targetIndex);
  }

  double _resolveInertialProjectedPosition({
    required double indexVelocity,
    required double minPosition,
    required double maxPosition,
  }) {
    final friction = widget.inertialFriction.clamp(.01, 1.0);
    final velocitySign = indexVelocity.sign;
    final projectedDistance =
        pow(indexVelocity.abs(), .92) / (friction * 14.5);
    final projectedDelta = projectedDistance * velocitySign;
    final clampedDelta = projectedDelta.clamp(-4.5, 4.5);
    return (_pagePosition + clampedDelta).clamp(minPosition, maxPosition);
  }

  Duration _buildInertialGlideDuration(
    double projectedPosition,
    double indexVelocity,
  ) {
    final distance = (projectedPosition - _pagePosition).abs();
    final velocityFactor = min(280, indexVelocity.abs() * 28);
    final milliseconds = (180 + distance * 150 + velocityFactor)
        .round()
        .clamp(220, 720);
    return Duration(milliseconds: milliseconds);
  }

  int _resolveInertialTargetIndex(
    double projectedPosition,
    double indexVelocity,
  ) {
    final roundedProjected = projectedPosition.round();
    final roundedCurrent = _pagePosition.round();

    if ((projectedPosition - _pagePosition).abs() < .2) {
      return _clampIndex(roundedCurrent);
    }

    if (indexVelocity > 0 && projectedPosition < roundedProjected) {
      return _clampIndex(max(roundedProjected, roundedCurrent + 1));
    }

    if (indexVelocity < 0 && projectedPosition > roundedProjected) {
      return _clampIndex(min(roundedProjected, roundedCurrent - 1));
    }

    return _clampIndex(roundedProjected);
  }

  void _handleItemTap(int index) {
    final targetIndex = _clampIndex(index);
    if (targetIndex != _pagePosition.round()) {
      unawaited(_animateToIndex(targetIndex));
    }
    widget.onTapItem?.call(targetIndex);
  }

  Object _itemCacheToken(int index) {
    return widget.itemKeyBuilder?.call(index) ?? index;
  }

  Widget _buildCachedItem(int index) {
    final token = _itemCacheToken(index);
    final cachedChild = _itemChildCache[token];
    if (cachedChild != null && cachedChild.index == index) {
      return cachedChild.widget;
    }

    final child = widget.itemBuilder(context, index);
    _itemChildCache[token] = _CachedCoverFlowChild(index: index, widget: child);
    return child;
  }

  void _trimItemCache(int centerIndex) {
    if (_itemChildCache.isEmpty || widget.itemCount <= 0) {
      return;
    }

    final start = max(0, centerIndex - widget.visibleRange - 2);
    final end = min(widget.itemCount, centerIndex + widget.visibleRange + 3);
    final keepTokens = <Object>{
      for (int index = start; index < end; index++) _itemCacheToken(index),
    };

    _itemChildCache.removeWhere((token, _) => !keepTokens.contains(token));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _positionController,
      builder: (context, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _handleHorizontalDragStart,
          onHorizontalDragUpdate: _handleHorizontalDragUpdate,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final currentCenterIndex =
                  _pagePosition.round().clamp(0, widget.itemCount - 1);
              _trimItemCache(currentCenterIndex);

              return CoverFlowCardItems(
                itemCount: widget.itemCount,
                itemBuilder: _buildCachedItem,
                itemKeyBuilder: widget.itemKeyBuilder,
                pagePosition: _pagePosition,
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
                itemSize: widget.itemSize,
                visibleRange: widget.visibleRange,
                style: widget.style,
                padding: widget.padding.resolve(Directionality.of(context)),
                clipBehavior: widget.clipBehavior,
                onTapItem: _handleItemTap,
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }
}

class CoverFlowCardItems extends StatelessWidget {
  final int itemCount;
  final CoverFlowItemWidgetBuilder itemBuilder;
  final CoverFlowItemKeyBuilder? itemKeyBuilder;
  final double pagePosition;
  final double maxHeight;
  final double maxWidth;
  final Size itemSize;
  final int visibleRange;
  final CoverFlowStyle style;
  final EdgeInsets padding;
  final Clip clipBehavior;
  final ValueChanged<int>? onTapItem;

  const CoverFlowCardItems({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.pagePosition,
    required this.maxHeight,
    required this.maxWidth,
    required this.itemSize,
    required this.visibleRange,
    required this.style,
    required this.padding,
    required this.clipBehavior,
    this.itemKeyBuilder,
    this.onTapItem,
  });

  double get _viewportWidth => max(0, maxWidth - padding.horizontal);

  double get _viewportHeight => max(0, maxHeight - padding.vertical);

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) {
      return const SizedBox.shrink();
    }

    final currentCenterIndex = pagePosition.round().clamp(0, itemCount - 1);
    final start = max(0, currentCenterIndex - visibleRange - 1);
    final end = min(itemCount, currentCenterIndex + visibleRange + 2);

    return SizedBox(
      height: maxHeight,
      width: maxWidth,
      child: Stack(
        clipBehavior: clipBehavior,
        children: _buildPaintOrderedCards(context, start, end),
      ),
    );
  }

  List<Widget> _buildPaintOrderedCards(
    BuildContext context,
    int start,
    int end,
  ) {
    final children = <Widget>[];
    var left = start;
    var right = end - 1;

    while (left <= right) {
      final leftDistance = (left - pagePosition).abs();
      final rightDistance = (right - pagePosition).abs();

      if (leftDistance > rightDistance) {
        children.add(_buildCard(context, left));
        left++;
        continue;
      }

      if (rightDistance > leftDistance) {
        children.add(_buildCard(context, right));
        right--;
        continue;
      }

      children.add(_buildCard(context, left));
      left++;
      if (left <= right) {
        children.add(_buildCard(context, right));
        right--;
      }
    }

    return children;
  }

  Widget _buildCard(BuildContext context, int index) {
    final metrics = _resolveMetrics(index);

    return Positioned(
      key: itemKeyBuilder?.call(index) ?? ValueKey(index),
      left: padding.left + metrics.left,
      top: padding.top + metrics.top,
      child: Transform(
        transform: metrics.transform,
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: onTapItem == null ? null : () => onTapItem?.call(index),
          child: Opacity(
            opacity: metrics.opacity,
            child: RepaintBoundary(
              child: SizedBox(
                width: itemSize.width,
                height: itemSize.height,
                child: itemBuilder(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _CoverFlowCardMetrics _resolveMetrics(int index) {
    final relative = index - pagePosition;
    final distance = relative.abs();
    final side = relative == 0 ? 0 : relative.sign.toInt();
    final centerLeft = (_viewportWidth - itemSize.width) / 2;
    final centerTop = (_viewportHeight - itemSize.height) / 2;
    final nearGap = itemSize.width * style.nearGapFactor;
    final farGap = itemSize.width * style.farGapFactor;
    final left = centerLeft + _resolveHorizontalOffset(distance, side, nearGap, farGap);
    final angle = _resolveAngle(distance, side);
    final scale = _lerpDistance(style.centerScale, style.sideScale, distance);
    final opacity = _lerpDistance(style.centerOpacity, style.sideOpacity, distance)
        .clamp(0.0, 1.0);
    final top = centerTop + _lerpDistance(0, style.sideVerticalOffset, distance);

    final pivot = side < 0 ? itemSize.width / 2 : -itemSize.width / 2;
    final transform = Matrix4.identity()
      ..translateByDouble(-pivot, 0, 0, 1)
      ..setEntry(3, 2, style.perspective)
      ..rotateY(angle)
      ..translateByDouble(pivot, 0, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);

    return _CoverFlowCardMetrics(
      left: left,
      top: top,
      opacity: opacity,
      transform: transform,
    );
  }

  double _resolveHorizontalOffset(
    double distance,
    int side,
    double nearGap,
    double farGap,
  ) {
    if (side == 0 || distance <= 0) {
      return 0;
    }
    if (distance <= 1) {
      return side * lerpDouble(0, nearGap, distance)!;
    }
    return side * (nearGap + farGap * (distance - 1));
  }

  double _resolveAngle(double distance, int side) {
    if (side == 0 || distance <= 0) {
      return 0;
    }
    final baseAngle = distance <= 1
        ? lerpDouble(0, style.nearAngle, distance)!
        : lerpDouble(style.nearAngle, style.farAngle, min(1, distance - 1))!;
    return side < 0 ? -baseAngle : baseAngle;
  }

  double _lerpDistance(double centerValue, double sideValue, double distance) {
    return lerpDouble(centerValue, sideValue, distance.clamp(0.0, 1.0))!;
  }
}

class _CoverFlowCardMetrics {
  final double left;
  final double top;
  final double opacity;
  final Matrix4 transform;

  const _CoverFlowCardMetrics({
    required this.left,
    required this.top,
    required this.opacity,
    required this.transform,
  });
}

class _CachedCoverFlowChild {
  final int index;
  final Widget widget;

  const _CachedCoverFlowChild({
    required this.index,
    required this.widget,
  });
}
