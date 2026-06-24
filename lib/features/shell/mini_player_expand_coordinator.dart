import 'package:bujuan/core/diagnostics/performance_logger.dart';
import 'package:bujuan/core/diagnostics/performance_metric.dart';
import 'package:flutter/foundation.dart';

/// Coordinates mini player expand commands so repeated taps reuse one open task.
class MiniPlayerExpandCoordinator {
  /// Creates a mini player expand coordinator.
  MiniPlayerExpandCoordinator();

  Future<void>? _expandInFlight;

  /// Opens the bottom playback panel and records mini player feedback metrics.
  Future<void> open({
    required bool Function() isAttached,
    required bool Function() isFullyOpened,
    required Future<void> Function() openPanel,
  }) {
    final pending = _expandInFlight;
    if (pending != null) {
      return _recordFeedback(
        isAttached: isAttached,
        isFullyOpened: isFullyOpened,
        coalesced: true,
        action: () => pending,
      );
    }
    late final Future<void> command;
    command = _recordFeedback(
      isAttached: isAttached,
      isFullyOpened: isFullyOpened,
      coalesced: false,
      action: openPanel,
    ).whenComplete(() {
      if (identical(_expandInFlight, command)) {
        _expandInFlight = null;
      }
    });
    _expandInFlight = command;
    return command;
  }

  Future<void> _recordFeedback({
    required bool Function() isAttached,
    required bool Function() isFullyOpened,
    required bool coalesced,
    required Future<void> Function() action,
  }) async {
    final stopwatch = PerformanceLogger.start();
    final wasAttached = isAttached();
    final wasOpened = isFullyOpened();
    Object? commandError;
    var opened = false;
    try {
      await action();
      opened = isFullyOpened();
    } catch (error) {
      commandError = error;
      rethrow;
    } finally {
      PerformanceLogger.elapsedMetric(
        AppPerformanceMetrics.miniPlayerFeedback,
        stopwatch,
        details: miniPlayerExpandFeedbackMetricDetails(
          attached: wasAttached,
          alreadyOpened: wasOpened,
          opened: opened,
          coalesced: coalesced,
          error: commandError,
        ),
      );
    }
  }
}

/// Builds mini player expand feedback metric details.
@visibleForTesting
String miniPlayerExpandFeedbackMetricDetails({
  required bool attached,
  required bool alreadyOpened,
  required bool opened,
  bool coalesced = false,
  Object? error,
}) {
  final result = error != null
      ? 'error'
      : coalesced
          ? 'coalesced'
          : alreadyOpened
              ? 'already_open'
              : opened
                  ? 'success'
                  : 'skipped';
  final details = 'action=expand result=$result attached=$attached alreadyOpened=$alreadyOpened';
  final coalescedDetails = coalesced ? '$details coalesced=true' : details;
  if (error == null) {
    return coalescedDetails;
  }
  return '$coalescedDetails error=${error.runtimeType}';
}
