import 'package:flutter/material.dart';

/// 颜色
class AppColors {
  AppColors._();

  /// 应用主色。
  static const Color primaryColor = Color(0xFF1976D2);

  /// 应用强调色。
  static const Color accentColor = Color(0xFFFFA000);

  /// 默认页面背景色。
  static const Color backgroundColor = Color(0xFFF5F5F5);

  /// 主要文本颜色。
  static const Color textColorPrimary = Colors.black87;

  /// 次要文本颜色。
  static const Color textColorSecondary = Colors.black54;

  /// 成功状态颜色。
  static const Color successColor = Colors.green;

  /// 错误状态颜色。
  static const Color errorColor = Colors.red;
}

/// 应用主题定义，集中提供亮色和暗色主题及基础色板。
class AppTheme {
  /// 亮色主题
  static ThemeData light = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: primary,
          onPrimary: onPrimary.withValues(alpha: 0.8),
          secondary: secondary,
          onSecondary: onSecondary,
          surface: surface,
          onSurface: onSurface,
        ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    }),
    cardColor: const Color(0xFF2C2C2C),
    iconTheme: const IconThemeData(color: Color(0xFF4D4D4D)),
    primaryColor: const Color(0xffe56260),
    textTheme: const TextTheme(
      labelLarge: TextStyle(fontSize: 20, color: onPrimary),
      labelMedium: TextStyle(fontSize: 15, color: onPrimary),
      labelSmall: TextStyle(fontSize: 10, color: onPrimary),
      titleLarge: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: onPrimary,
      ),
      titleMedium: TextStyle(fontSize: 20, color: onPrimary),
      titleSmall: TextStyle(fontSize: 15, color: onPrimary),
      bodyLarge: TextStyle(fontSize: 30, color: onPrimary),
      bodyMedium: TextStyle(fontSize: 20, color: onPrimary),
      bodySmall: TextStyle(fontSize: 10, color: onPrimary),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F3F3),
  );

  /// 黑暗模式主题
  static ThemeData dark = ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: primaryDark,
          onPrimary: onPrimaryDark.withValues(alpha: 0.8),
          secondary: onSecondary,
          onSecondary: secondary,
          surface: surfaceDark,
          onSurface: onSurfaceDark,
        ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    }),
    cardColor: const Color(0xFFECEBEB),
    primaryColor: const Color(0xffE20000),
    scaffoldBackgroundColor: const Color(0xFFF4F7F9),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: onPrimaryDark,
      ),
      titleMedium: TextStyle(fontSize: 30, color: onPrimaryDark),
      titleSmall: TextStyle(fontSize: 20, color: onPrimaryDark),
    ),
  );

  /// 暗色主题主色。
  static const primaryDark = Color(0xFF1c1d1f);

  /// 暗色主题主色上的内容色。
  static const onPrimaryDark = Color(0xF9F1F1F1);

  /// 亮色主题主色。
  static const primary = Colors.white;

  /// 亮色主题主色上的内容色。
  static const onPrimary = Color(0xFF1c1d1f);

  /// 暗色主题表面色。
  static const surfaceDark = Color(0xFF333436);

  /// 暗色主题表面上的内容色。
  static const onSurfaceDark = Color(0xFF2C2B2B);

  /// 亮色主题表面色。
  static const surface = Color(0xff787878);

  /// 亮色主题表面上的内容色。
  static const onSurface = Color(0xFFAEAEAE);

  /// 次级背景色。
  static const secondary = Color(0xFF1C1B1B);

  /// 次级背景上的内容色。
  static const onSecondary = Colors.white;

  /// 最低区间提示色。
  static const min = Colors.red;

  /// 中间区间提示色。
  static const middle = Colors.yellow;

  /// 最高区间提示色。
  static const max = Colors.green;

  /// 空状态提示色。
  static const empty = Colors.grey;

  /// 红色动作色。
  static const red = Colors.red;

  /// 红色背景上的内容色。
  static const onRed = Colors.white;

  /// 图标描边色。
  static const iconBorder = Colors.white;

  /// 顶部文字颜色。
  static const topTextColor = Colors.white;
}
