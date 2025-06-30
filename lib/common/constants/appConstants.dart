import 'package:flutter/material.dart';

// TODO YU4422 待完善规范

/// UI尺寸
class AppDimensions {
  // 私有构造函数，防止实例化
  AppDimensions._();

  // 通用 Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // 特定场景的 Padding
  static const EdgeInsets playListPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const EdgeInsets screenPadding = EdgeInsets.all(paddingMedium);
  static const EdgeInsets cardPadding = EdgeInsets.all(paddingSmall);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: paddingMedium, vertical: paddingSmall);

  // 通用 Border Radius
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(12.0));

  // 图标尺寸
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // 顶部AppBar尺寸
  static const double appBarHeight= 60;
  // 底部PanelHeader尺寸
  /// 屏幕圆角 xiaomi13
  static const double phoneCornerRadius = 42.5;
  static const double bottomPanelHeaderHeight = phoneCornerRadius * 2;
  static const double albumPadding = 10;
  static const double albumMinWidth = bottomPanelHeaderHeight - albumPadding * 2;
  /// 屏幕宽度的 5/6
  static const double albumMaxWidth = 5/6;

}

/// 颜色
class AppColors {
  AppColors._();

  static const Color primaryColor = Color(0xFF1976D2); // 深蓝色
  static const Color accentColor = Color(0xFFFFA000); // 橙色

  static const Color backgroundColor = Color(0xFFF5F5F5); // 浅灰色
  static const Color textColorPrimary = Colors.black87;
  static const Color textColorSecondary = Colors.black54;

  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;

}

/// 动画时长
class AppDurations {
  AppDurations._();

  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration splashDuration = Duration(seconds: 2);
}

