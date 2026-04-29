import 'package:flutter/material.dart';

/// UI尺寸
class AppDimensions {
  AppDimensions._();

  static const double paddingSmall = 10;
  static const double paddingMedium = 20;
  static const double paddingLarge = 30;

  static const EdgeInsets playListPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const EdgeInsets screenPadding = EdgeInsets.all(paddingMedium);
  static const EdgeInsets cardPadding = EdgeInsets.all(paddingSmall);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: paddingMedium, vertical: paddingSmall);

  static const BorderRadius borderRadiusSmall =
      BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius borderRadiusMedium =
      BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius borderRadiusLarge =
      BorderRadius.all(Radius.circular(12.0));

  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double phoneCornerRadius = 42.5;
  static const double bottomPanelHeaderHeight = phoneCornerRadius * 2;
  static const double albumMinSize = bottomPanelHeaderHeight - paddingSmall * 2;

  static const double appBarHeight = bottomPanelHeaderHeight;
  static const double headerHeight = 50;
}

/// 动画时长
class AppDurations {
  AppDurations._();

  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration splashDuration = Duration(seconds: 2);
}
