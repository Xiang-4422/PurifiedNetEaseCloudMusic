import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 通用性能诊断日志。
class PerformanceLogger {
  PerformanceLogger._();

  /// 开始一段耗时测量。
  static Stopwatch start() {
    return Stopwatch()..start();
  }

  /// 输出诊断日志。
  static void log(String message, {String name = 'Perf'}) {
    if (!kDebugMode) {
      return;
    }
    developer.log(message, name: name);
    debugPrint('[$name] $message');
  }

  /// 输出一段耗时测量。
  static void elapsed(
    String event,
    Stopwatch stopwatch, {
    String details = '',
    String name = 'Perf',
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
    developer.log('$event ${elapsedMs}ms$suffix', name: name);
    debugPrint('[$name] $event ${elapsedMs}ms$suffix');
  }
}
