import 'dart:math' as math;

import 'package:bujuan/common/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// App 级响应式布局尺寸。
class AdaptiveLayoutMetrics {
  /// 创建响应式布局尺寸。
  const AdaptiveLayoutMetrics({
    required this.size,
    this.viewPadding = EdgeInsets.zero,
    this.textScale = 1,
  });

  /// 从当前上下文读取布局尺寸。
  factory AdaptiveLayoutMetrics.of(BuildContext context) {
    return AdaptiveLayoutMetrics(
      size: MediaQuery.sizeOf(context),
      viewPadding: MediaQuery.paddingOf(context),
      textScale: MediaQuery.textScalerOf(context).scale(1),
    );
  }

  /// 屏幕尺寸。
  final Size size;

  /// 系统安全区。
  final EdgeInsets viewPadding;

  /// 文本缩放倍率。
  final double textScale;

  /// 屏幕宽高比。
  double get aspectRatio => size.width / size.height;

  /// 是否接近方屏。
  bool get isSquareLike => aspectRatio >= 0.85 && aspectRatio <= 1.15;

  /// 是否属于垂直空间紧凑屏幕。
  bool get isCompactHeight => safeContentHeight <= 560 || isSquareLike;

  /// 扣除系统安全区后的高度。
  double get safeContentHeight {
    return math.max(0, size.height - viewPadding.vertical);
  }

  /// 底部播放器预留高度。
  double get bottomReservedHeight => AppDimensions.bottomPanelHeaderHeight;

  /// 自适应列表项最小高度。
  double get listTileMinHeight {
    return (52 * textScale).clamp(52.0, 76.0).toDouble();
  }

  /// 详情页头图展开高度。
  double get heroExtent {
    final raw = math.min(size.width, safeContentHeight * 0.42);
    final maxExtent = math.min(size.width, safeContentHeight * 0.55);
    final minExtent = math.min(maxExtent, isCompactHeight ? 160.0 : 200.0);
    return raw.clamp(minExtent, maxExtent).toDouble();
  }

  /// 播放器大封面 1:1 尺寸。
  double playbackArtworkExtent({
    double? availableHeight,
    double horizontalPadding = AppDimensions.paddingLarge,
  }) {
    final panelHeight = math.max(0, availableHeight ?? safeContentHeight);
    final maxByWidth = math.max(0, size.width - horizontalPadding * 2);
    final maxByHeight = panelHeight * 0.46;
    final raw = math.min(maxByWidth, maxByHeight);
    final maxExtent = math.min(maxByWidth, math.max(raw, maxByHeight));
    final minExtent = math.min(maxExtent, AppDimensions.albumMinSize);
    return raw.clamp(minExtent, maxExtent).toDouble();
  }
}
