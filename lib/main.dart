import 'package:bujuan/app.dart';
import 'package:bujuan/app/bootstrap/app_bootstrap.dart';
import 'package:bujuan/core/diagnostics/performance_logger.dart';
import 'package:bujuan/core/diagnostics/performance_metric.dart';
import 'package:flutter/material.dart';

/// 仅保留应用启动顺序，避免初始化细节继续回流到入口文件。
Future<void> main() async {
  final startupStopwatch = PerformanceLogger.start();
  await bootstrapApplication();
  runApp(const App());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PerformanceLogger.elapsedMetric(
      AppPerformanceMetrics.coldStartInteractive,
      startupStopwatch,
    );
  });
}
