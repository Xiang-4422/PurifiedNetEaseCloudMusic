import 'dart:async';

/// 当前歌曲后台副作用失败时的诊断回调。
typedef CurrentTrackSideEffectErrorHandler = void Function(
  String channel,
  String trackId,
  Object error,
  StackTrace stackTrace,
);

/// 当前歌曲副作用调度器。
///
/// 切歌期间歌词、取色、封面补全和缓存写入都不能直接抢占 selection 更新。
/// 这里按 channel 统一延迟和取消旧任务，避免旧歌曲的异步结果回写到新 UI。
class CurrentTrackSideEffectCoordinator {
  /// 创建当前歌曲副作用调度器。
  CurrentTrackSideEffectCoordinator({
    CurrentTrackSideEffectErrorHandler? onError,
  }) : _onError = onError;

  final Map<String, Timer> _timers = <String, Timer>{};
  final Map<String, int> _versions = <String, int>{};
  final CurrentTrackSideEffectErrorHandler? _onError;

  /// 调度当前歌曲副作用。
  void schedule({
    required String channel,
    required Duration delay,
    required String trackId,
    required bool Function(String trackId) isStillCurrent,
    required Future<void> Function() run,
  }) {
    final version = (_versions[channel] ?? 0) + 1;
    _versions[channel] = version;
    _timers.remove(channel)?.cancel();
    _timers[channel] = Timer(
      delay,
      () => unawaited(
        _runSideEffect(
          channel: channel,
          version: version,
          trackId: trackId,
          isStillCurrent: isStillCurrent,
          run: run,
        ),
      ),
    );
  }

  Future<void> _runSideEffect({
    required String channel,
    required int version,
    required String trackId,
    required bool Function(String trackId) isStillCurrent,
    required Future<void> Function() run,
  }) async {
    try {
      if (_versions[channel] != version || !isStillCurrent(trackId)) {
        return;
      }
      await run();
    } catch (error, stackTrace) {
      try {
        _onError?.call(channel, trackId, error, stackTrace);
      } catch (_) {}
    } finally {
      if (_versions[channel] == version) {
        _timers.remove(channel);
      }
    }
  }

  /// 取消指定 channel 的副作用。
  void cancel(String channel) {
    _versions[channel] = (_versions[channel] ?? 0) + 1;
    _timers.remove(channel)?.cancel();
  }

  /// 取消所有已调度副作用。
  void cancelAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    for (final entry in _versions.entries.toList()) {
      _versions[entry.key] = entry.value + 1;
    }
  }
}
