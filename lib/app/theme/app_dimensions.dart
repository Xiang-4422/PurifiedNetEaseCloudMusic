import 'package:flutter/material.dart';

/// UI尺寸
class AppDimensions {
  AppDimensions._();

  /// 小号内边距。
  static const double paddingSmall = 10;

  /// 中号内边距。
  static const double paddingMedium = 20;

  /// 大号内边距。
  static const double paddingLarge = 30;

  /// 歌单条目默认内边距。
  static const EdgeInsets playListPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 10);

  /// 页面默认内边距。
  static const EdgeInsets screenPadding = EdgeInsets.all(paddingMedium);

  /// 卡片默认内边距。
  static const EdgeInsets cardPadding = EdgeInsets.all(paddingSmall);

  /// 按钮默认内边距。
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: paddingMedium, vertical: paddingSmall);

  /// 小号圆角。
  static const BorderRadius borderRadiusSmall =
      BorderRadius.all(Radius.circular(4.0));

  /// 中号圆角。
  static const BorderRadius borderRadiusMedium =
      BorderRadius.all(Radius.circular(8.0));

  /// 大号圆角。
  static const BorderRadius borderRadiusLarge =
      BorderRadius.all(Radius.circular(12.0));

  /// 小号图标尺寸。
  static const double iconSizeSmall = 18.0;

  /// 中号图标尺寸。
  static const double iconSizeMedium = 24.0;

  /// 大号图标尺寸。
  static const double iconSizeLarge = 32.0;

  /// 手机外观圆角半径。
  static const double phoneCornerRadius = 42.5;

  /// 底部播放面板头部高度。
  static const double bottomPanelHeaderHeight = phoneCornerRadius * 2;

  /// 播放封面最小尺寸。
  static const double albumMinSize = bottomPanelHeaderHeight - paddingSmall * 2;

  /// 应用栏默认高度。
  static const double appBarHeight = bottomPanelHeaderHeight;

  /// 通用头部高度。
  static const double headerHeight = 50;
}

/// 动画时长
class AppDurations {
  AppDurations._();

  /// 短动画时长。
  static const Duration animationDurationShort = Duration(milliseconds: 200);

  /// 中等动画时长。
  static const Duration animationDurationMedium = Duration(milliseconds: 400);

  /// 启动页停留时长。
  static const Duration splashDuration = Duration(seconds: 2);
}
