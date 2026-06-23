import 'dart:async';

/// 播放后台任务失败时的诊断回调。
typedef PlaybackBackgroundErrorHandler = void Function(
  String taskName,
  String? trackId,
  Object error,
  StackTrace stackTrace,
);

/// 播放链路 fire-and-forget 任务的统一错误边界。
class PlaybackBackgroundTaskRunner {
  /// 创建播放后台任务执行器。
  const PlaybackBackgroundTaskRunner({
    PlaybackBackgroundErrorHandler? onError,
  }) : _onError = onError;

  final PlaybackBackgroundErrorHandler? _onError;

  /// 运行一个不阻塞当前播放控制流的后台任务。
  void run({
    required String taskName,
    String? trackId,
    required FutureOr<void> Function() task,
  }) {
    unawaited(_runGuarded(
      taskName: taskName,
      trackId: trackId,
      task: task,
    ));
  }

  Future<void> _runGuarded({
    required String taskName,
    required String? trackId,
    required FutureOr<void> Function() task,
  }) async {
    try {
      await task();
    } catch (error, stackTrace) {
      try {
        _onError?.call(taskName, trackId, error, stackTrace);
      } catch (_) {}
    }
  }
}
