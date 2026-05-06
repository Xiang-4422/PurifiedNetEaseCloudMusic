import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 歌单详情加载性能诊断日志。
class PlaylistPerformanceLogger {
  PlaylistPerformanceLogger._();

  static const String _name = 'PlaylistPerf';

  /// 开始一段耗时测量。
  static Stopwatch start() {
    return Stopwatch()..start();
  }

  /// 输出诊断日志。
  static void log(String message) {
    if (!kDebugMode) {
      return;
    }
    developer.log(message, name: _name);
    debugPrint('[$_name] $message');
  }

  /// 输出一段耗时测量。
  static void elapsed(
    String event,
    Stopwatch stopwatch, {
    String details = '',
    int warnAfterMs = 0,
  }) {
    if (!kDebugMode) {
      return;
    }
    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;
    if (warnAfterMs > 0 && elapsedMs < warnAfterMs) {
      return;
    }
    final suffix = details.isEmpty ? '' : ' $details';
    developer.log('$event ${elapsedMs}ms$suffix', name: _name);
    debugPrint('[$_name] $event ${elapsedMs}ms$suffix');
  }
}
