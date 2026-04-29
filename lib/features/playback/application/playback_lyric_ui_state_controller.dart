import 'dart:async';

/// PlaybackLyricUiStateController。
class PlaybackLyricUiStateController {
  Timer? _fullScreenLyricTimer;
  double _fullScreenLyricTimerCounter = 0.0;

  /// updateFullScreenLyricTimerCounter。
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
      _fullScreenLyricTimer =
          Timer.periodic(const Duration(milliseconds: 50), (timer) {
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

  /// resolveCurrentLyricIndex。
  int resolveCurrentLyricIndex({
    required Iterable<dynamic> lines,
    required Duration position,
  }) {
    return lines.toList().lastIndexWhere(
          (element) => element.startTime! <= position.inMilliseconds,
        );
  }

  /// dispose。
  void dispose() {
    _fullScreenLyricTimer?.cancel();
    _fullScreenLyricTimer = null;
  }
}
