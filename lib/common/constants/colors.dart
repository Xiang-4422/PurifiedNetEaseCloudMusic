import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  /// 亮色主题
  static ThemeData light = ThemeData.light().copyWith(
      colorScheme: ThemeData.light().colorScheme.copyWith(
        primary: primary,
        onPrimary: onPrimary.withOpacity(0.8),
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
      textTheme: TextTheme(
        titleLarge: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            color: onPrimary
        ) ,
        titleMedium: TextStyle(
            fontSize: 30.sp,
            color: onPrimary
        ) ,
        titleSmall: TextStyle(
            fontSize: 20.sp,
            color: onPrimary
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F3F3),
  );

  /// 黑暗模式主题
  static ThemeData dark = ThemeData.dark().copyWith(
      colorScheme: ThemeData.dark().colorScheme.copyWith(
            primary: primaryDark,
            onPrimary: onPrimaryDark.withOpacity(0.8),
            secondary: onSecondary,
            onSecondary: secondary,
            surface: surfaceDark,
            onSurface: onSurfaceDark,
          ),
      // 页面切换动画
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      }),
      cardColor: const Color(0xFFECEBEB),
      // 网易云红色
      primaryColor: const Color(0xffE20000),
      // 网易云主页背景色
      scaffoldBackgroundColor: const Color(0xFFF4F7F9),
      textTheme: TextTheme(
        titleLarge: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            color: onPrimaryDark
        ) ,
        titleMedium: TextStyle(
            fontSize: 30.sp,
            color: onPrimaryDark
        ) ,
        titleSmall: TextStyle(
            fontSize: 20.sp,
            color: onPrimaryDark
        ),
      ),
  );

  //right background
  static const primaryDark = Color(0xFF1c1d1f);
  static const onPrimaryDark = Color(0xF9F1F1F1);
  static const primary = Color(0xFFd7d9d8);
  static const onPrimary = Color(0xFF1c1d1f);

  //disabled or inactive background
  static const surfaceDark = Color(0xFF333436);
  static const onSurfaceDark = Color(0xFF2C2B2B);
  static const surface = Color(0xff787878);
  static const onSurface = Color(0xFFAEAEAE);

  //accent color
  //TODO change blue
  static const secondary = Color(0xFF1C1B1B);
  static const onSecondary = Colors.white;

  //charge colors
  //todo change colors
  static const min = Colors.red;
  static const middle = Colors.yellow;
  static const max = Colors.green;
  static const empty = Colors.grey;

  //rust red accent
  //TODO change red
  static const red = Colors.red;
  static const onRed = Colors.white;

  static const iconBorder = Colors.white;
  static const topTextColor = Colors.white;
}
