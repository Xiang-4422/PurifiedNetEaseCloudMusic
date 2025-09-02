import 'dart:ui';

import 'package:bujuan/common/constants/other.dart';
import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color get invertedColor => ThemeData.estimateBrightnessForColor(this) == Brightness.light ? Colors.black : Colors.white;
}

extension StringNullOrEmpty on String? {
  String orDefault(String defaultValue) {
    return (this == null || this!.isEmpty) ? defaultValue : this!;
  }

  bool get isNullOrEmpty => this == null || this!.isEmpty;
}


