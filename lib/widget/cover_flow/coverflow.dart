library coverflow;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

typedef CoverFlowItemBuilder = Widget Function(BuildContext context, int index);
typedef CoverFlowItemKeyBuilder = Key? Function(int index);

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

  const CoverFlowStyle({
    this.nearGapFactor = .5,
    this.farGapFactor = .4,
    this.nearAngle = pi / 6,
    this.farAngle = pi / 3,
    this.perspective = .001,
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
  final double cardSize;
  final int currentIndex;
  final int visibleRange;
  final ValueChanged<int>? onIndexChanged;
  final ValueChanged<int>? onTapItem;
  final CoverFlowStyle style;
  final CoverFlowInteractionMode interactionMode;

  const CoverFlow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.cardSize,
    this.itemKeyBuilder,
    this.currentIndex = 0,
    this.visibleRange = 6,
    this.onIndexChanged,
    this.onTapItem,
    this.style = const CoverFlowStyle(),
    this.interactionMode = CoverFlowInteractionMode.pageSnap,
  });

  @override
  State<CoverFlow> createState() => _CoverFlowState();
}

class _CoverFlowState extends State<CoverFlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _positionController;
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
    )..addListener(() {
        setState(() {});
        _reportIndexIfNeeded();
      });
    _lastReportedIndex = _clampIndex(widget.currentIndex);
  }

  @override
  void didUpdateWidget(covariant CoverFlow oldWidget) {
    super.didUpdateWidget(oldWidget);

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
      curve: Curves.easeOutQuart,
    );
  }

  Duration _buildAnimationDuration(int targetIndex) {
    final distance = (_pagePosition - targetIndex).abs();
    final base = switch (widget.interactionMode) {
      CoverFlowInteractionMode.pageSnap => 180,
      CoverFlowInteractionMode.inertialSnap => 220,
    };
    final perIndex = switch (widget.interactionMode) {
      CoverFlowInteractionMode.pageSnap => 110,
      CoverFlowInteractionMode.inertialSnap => 140,
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
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.itemCount <= 0) {
      return;
    }
    final nextPosition = (_pagePosition - details.primaryDelta! / widget.cardSize)
        .clamp(0.0, max(0, widget.itemCount - 1).toDouble());
    _pagePosition = nextPosition;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (widget.itemCount <= 0) {
      return;
    }
    _isDragging = false;
    final targetIndex = _resolveTargetIndex(details.primaryVelocity ?? 0);
    unawaited(_animateToIndex(targetIndex));
  }

  int _resolveTargetIndex(double velocity) {
    if (widget.interactionMode == CoverFlowInteractionMode.pageSnap) {
      if (velocity.abs() < 320) {
        return _clampIndex(_pagePosition.round());
      }
      if (velocity < 0) {
        return _clampIndex(_pagePosition.ceil());
      }
      return _clampIndex(_pagePosition.floor());
    }

    if (velocity.abs() < 220) {
      return _clampIndex(_pagePosition.round());
    }
    final projectedSteps = max(1, min(4, (velocity.abs() / 1100).round()));
    final baseIndex = velocity < 0 ? _pagePosition.ceil() : _pagePosition.floor();
    final targetIndex = velocity < 0
        ? baseIndex + projectedSteps
        : baseIndex - projectedSteps;
    return _clampIndex(targetIndex);
  }

  void _handleItemTap(int index) {
    final targetIndex = _clampIndex(index);
    if (targetIndex != _pagePosition.round()) {
      unawaited(_animateToIndex(targetIndex));
    }
    widget.onTapItem?.call(targetIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleHorizontalDragStart,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CoverFlowCardItems(
            itemCount: widget.itemCount,
            itemBuilder: widget.itemBuilder,
            itemKeyBuilder: widget.itemKeyBuilder,
            pagePosition: _pagePosition,
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
            cardSize: widget.cardSize,
            visibleRange: widget.visibleRange,
            style: widget.style,
            onTapItem: _handleItemTap,
          );
        },
      ),
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
  final CoverFlowItemBuilder itemBuilder;
  final CoverFlowItemKeyBuilder? itemKeyBuilder;
  final double pagePosition;
  final double maxHeight;
  final double maxWidth;
  final double cardSize;
  final int visibleRange;
  final CoverFlowStyle style;
  final ValueChanged<int>? onTapItem;

  const CoverFlowCardItems({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.pagePosition,
    required this.maxHeight,
    required this.maxWidth,
    required this.cardSize,
    required this.visibleRange,
    required this.style,
    this.itemKeyBuilder,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) {
      return const SizedBox.shrink();
    }
    final currentCenterIndex = pagePosition.round().clamp(0, itemCount - 1);
    final leftRangeStart = max(0, currentCenterIndex - visibleRange);
    final rightRangeEnd = min(itemCount, currentCenterIndex + visibleRange + 1);

    return SizedBox(
      height: maxHeight,
      child: Stack(
        alignment: AlignmentDirectional.center,
        clipBehavior: Clip.none,
        children: [
          for (int index = leftRangeStart; index < currentCenterIndex; index++)
            _buildCard(context, index),
          for (int index = rightRangeEnd - 1; index >= currentCenterIndex; index--)
            _buildCard(context, index),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    return Positioned(
      key: itemKeyBuilder?.call(index) ?? ValueKey(index),
      left: _getCardPosition(index),
      child: Transform(
        transform: _getTransform(index),
        alignment: FractionalOffset.center,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: onTapItem == null ? null : () => onTapItem?.call(index),
          child: SizedBox(
            width: cardSize,
            height: cardSize,
            child: itemBuilder(context, index),
          ),
        ),
      ),
    );
  }

  double _getCardPosition(int cardIndex) {
    final centerCardLeftPosition = maxWidth / 2 - cardSize / 2;
    final pageIndex = pagePosition.round();
    final rightScroll = pageIndex - pagePosition > 0;
    final isLeftCard = cardIndex == pageIndex ? !rightScroll : cardIndex < pageIndex;
    final pageScrollPercentage = (pageIndex - pagePosition).abs();
    final nearGap = cardSize * style.nearGapFactor;
    final farGap = cardSize * style.farGapFactor;

    late final double basePosition;
    late final double deltaPosition;

    if (cardIndex == pageIndex) {
      basePosition = centerCardLeftPosition;
      deltaPosition = rightScroll ? nearGap : -nearGap;
    } else if ((cardIndex - pageIndex).abs() == 1) {
      basePosition = centerCardLeftPosition + (isLeftCard ? -1 : 1) * nearGap;
      deltaPosition = isLeftCard
          ? rightScroll
              ? nearGap
              : -farGap
          : rightScroll
              ? farGap
              : -nearGap;
    } else {
      basePosition = centerCardLeftPosition +
          (isLeftCard ? -1 : 1) *
              (nearGap + farGap * ((cardIndex - pageIndex).abs() - 1));
      deltaPosition = rightScroll ? farGap : -farGap;
    }

    return basePosition + deltaPosition * pageScrollPercentage;
  }

  Matrix4 _getTransform(int cardIndex) {
    final pageIndex = pagePosition.round();
    final rightScroll = pageIndex - pagePosition > 0;
    final isLeftCard = cardIndex == pageIndex ? !rightScroll : cardIndex < pageIndex;
    final pageScrollPercentage = (pageIndex - pagePosition).abs();

    late final double baseAngle;
    late final double deltaAngle;

    if (cardIndex == pageIndex) {
      baseAngle = 0;
      deltaAngle = rightScroll ? style.nearAngle : -style.nearAngle;
    } else if ((cardIndex - pageIndex).abs() == 1) {
      baseAngle = isLeftCard ? -style.nearAngle : style.nearAngle;
      deltaAngle = isLeftCard
          ? rightScroll
              ? style.nearAngle
              : (style.nearAngle - style.farAngle)
          : rightScroll
              ? -(style.nearAngle - style.farAngle)
              : -style.nearAngle;
    } else if ((cardIndex - pageIndex).abs() == 2) {
      baseAngle = isLeftCard ? -style.farAngle : style.farAngle;
      deltaAngle = isLeftCard
          ? rightScroll
              ? -(style.nearAngle - style.farAngle)
              : 0
          : rightScroll
              ? 0
              : (style.nearAngle - style.farAngle);
    } else {
      baseAngle = isLeftCard ? -style.farAngle : style.farAngle;
      deltaAngle = 0;
    }

    final angle = baseAngle + deltaAngle * pageScrollPercentage;
    final centerOffset = isLeftCard ? cardSize / 2 : -cardSize / 2;

    return Matrix4.identity()
      ..translateByDouble(-centerOffset, 0, 0, 1)
      ..setEntry(3, 2, style.perspective)
      ..rotateY(angle)
      ..translateByDouble(centerOffset, 0, 0, 1);
  }
}
