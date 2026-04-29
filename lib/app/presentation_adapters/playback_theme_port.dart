import 'package:flutter/material.dart';

/// 播放主题展示端口，用于把封面主色应用到 UI 主题状态。
class PlaybackThemePort {
  /// 创建播放主题展示端口。
  const PlaybackThemePort({
    required this.applyDominantColor,
  });

  /// 应用当前歌曲封面主色的回调。
  final void Function(Color color) applyDominantColor;
}
