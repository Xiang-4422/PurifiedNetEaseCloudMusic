import 'package:flutter/material.dart';

/// ColorExtension。
extension ColorExtension on Color {
  /// invertedColor。
  Color get invertedColor =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light
          ? Colors.black
          : Colors.white;
}

/// StringNullOrEmpty。
extension StringNullOrEmpty on String? {
  /// orDefault。
  String orDefault(String defaultValue) {
    return (this == null || this!.isEmpty) ? defaultValue : this!;
  }

  /// isNullOrEmpty。
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
