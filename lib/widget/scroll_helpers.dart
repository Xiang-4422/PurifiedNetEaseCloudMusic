import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 为横向卡片列表提供稳定吸附，避免每个页面各自维护一套近似但不兼容的滚动手感。
class SnappingScrollPhysics extends ScrollPhysics {
  /// 单个吸附项的滚动宽度。
  final double itemExtent;

  /// 创建吸附滚动物理。
  const SnappingScrollPhysics({
    required this.itemExtent,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingScrollPhysics(
      itemExtent: itemExtent,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    final page = (position.pixels / itemExtent).round();
    return math.min(page * itemExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    if (velocity.abs() > tolerance.velocity) {
      return ClampingScrollSimulation(
        position: position.pixels,
        velocity: velocity,
        tolerance: tolerance,
        // 卡片列表需要更长的惯性，否则快速滑动会像被硬拽停一样生硬。
        friction: 0.045,
      );
    }

    final target = _getTargetPixels(position, tolerance, velocity);
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}

/// 仅去掉 glow，不改滚动曲线，适合歌词、封面流等已经有自己交互反馈的列表。
class NoGlowScrollBehavior extends ScrollBehavior {
  /// 创建无 glow 滚动行为。
  const NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

/// 应用壳层统一使用这一行为，避免根路由再反向依赖页面文件里的滚动实现。
class NoStretchBouncingScrollBehavior extends ScrollBehavior {
  /// 创建无拉伸的回弹滚动行为。
  const NoStretchBouncingScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
