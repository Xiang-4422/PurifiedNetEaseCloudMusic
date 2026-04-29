import 'package:flutter/material.dart';

class PlaybackThemePort {
  const PlaybackThemePort({
    required this.applyDominantColor,
  });

  final void Function(Color color) applyDominantColor;
}
