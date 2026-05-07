import 'dart:math' as math;

import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';

/// 个人首页在不同屏幕比例下的布局参数。
class PersonalHomeLayoutMetrics {
  /// 创建个人首页布局参数。
  const PersonalHomeLayoutMetrics(this.size);

  /// 当前可用屏幕尺寸。
  final Size size;

  /// 当前屏幕宽高比。
  double get aspectRatio => size.width / size.height;

  /// 是否接近 1:1 方屏。
  bool get isSquareLike => AdaptiveLayoutMetrics(size: size).isSquareLike;

  /// 方屏页标题高度。
  double get squareHeaderHeight => 44;

  /// 方屏页水平内边距。
  double get squareHorizontalPadding => AppDimensions.paddingSmall;

  /// 方屏 quick card 一屏展示数量。
  double get squareQuickCardCount => 1.25;

  /// 方屏歌单卡片一屏展示数量。
  double get squarePlaylistCardCount => 2.35;

  /// 方屏 quick card 尺寸。
  Size squareQuickCardSize({
    required double maxWidth,
    required double maxHeight,
  }) {
    final width = ((maxWidth - AppDimensions.paddingSmall * squareQuickCardCount.ceil()) / squareQuickCardCount).clamp(180.0, maxWidth);
    final height = math.min(maxHeight, width * 1.12).clamp(150.0, maxHeight);
    return Size(width, height);
  }

  /// 方屏歌单横滑区域高度。
  double squarePlaylistStripHeight({
    required double maxWidth,
    required double maxHeight,
  }) {
    final width = (maxWidth - AppDimensions.paddingSmall * squarePlaylistCardCount.ceil()) / squarePlaylistCardCount;
    return math.min(maxHeight, width * 1.18).clamp(130.0, maxHeight);
  }
}
