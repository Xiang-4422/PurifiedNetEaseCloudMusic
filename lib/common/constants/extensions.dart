import 'package:flutter/material.dart';

/// 颜色相关的展示层辅助能力。
extension ColorExtension on Color {
  /// 根据当前颜色亮度返回适合作为前景色的黑色或白色。
  Color get invertedColor =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light
          ? Colors.black
          : Colors.white;
}

/// 可空字符串的默认值与空值判断辅助能力。
extension StringNullOrEmpty on String? {
  /// 当前字符串为空或 null 时返回 [defaultValue]。
  String orDefault(String defaultValue) {
    return (this == null || this!.isEmpty) ? defaultValue : this!;
  }

  /// 当前字符串是否为 null 或空字符串。
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
