import 'dart:async';

import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';

/// 播放歌词 UI 状态控制器，负责歌词自动展开和当前行计算。
class PlaybackLyricUiStateController {
  Timer? _fullScreenLyricTimer;
  double _fullScreenLyricTimerCounter = 0.0;

  /// 更新全屏歌词自动展开计时器。
  void updateFullScreenLyricTimerCounter({
    required bool isPlaying,
    required void Function(bool isOpen) setFullScreenLyricOpen,
    bool cancelTimer = false,
  }) {
    const closeTime = 5000.0;
    if (cancelTimer) {
      _fullScreenLyricTimerCounter = 0;
      _fullScreenLyricTimer?.cancel();
      setFullScreenLyricOpen(false);
      return;
    }
    if (!isPlaying) {
      return;
    }
    if (_fullScreenLyricTimer == null || !_fullScreenLyricTimer!.isActive) {
      _fullScreenLyricTimerCounter = closeTime;
      _fullScreenLyricTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        _fullScreenLyricTimerCounter -= 50;
        if (_fullScreenLyricTimerCounter <= 0) {
          _fullScreenLyricTimerCounter = 0;
          timer.cancel();
          setFullScreenLyricOpen(true);
        }
      });
    } else {
      _fullScreenLyricTimerCounter = closeTime;
    }
  }

  /// 根据播放进度解析当前歌词行索引。
  int resolveCurrentLyricIndex({
    required List<LyricsLineModel> lines,
    required Duration position,
  }) {
    if (lines.isEmpty) {
      return -1;
    }
    final targetMs = position.inMilliseconds;
    var low = 0;
    var high = lines.length - 1;
    var result = -1;
    while (low <= high) {
      final middle = low + ((high - low) >> 1);
      final startTime = lines[middle].startTime ?? 0;
      if (startTime <= targetMs) {
        result = middle;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    return result;
  }

  /// 释放歌词 UI 状态计时器。
  void dispose() {
    _fullScreenLyricTimer?.cancel();
    _fullScreenLyricTimer = null;
  }
}
