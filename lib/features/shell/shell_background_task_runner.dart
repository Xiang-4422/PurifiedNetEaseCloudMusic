import 'dart:async';

/// 壳层后台 UI 任务失败时的诊断回调。
typedef ShellBackgroundErrorHandler = void Function(
  String taskName,
  Object error,
  StackTrace stackTrace,
);

/// 壳层 fire-and-forget UI 任务的统一错误边界。
class ShellBackgroundTaskRunner {
  /// 创建壳层后台任务执行器。
  const ShellBackgroundTaskRunner({
    ShellBackgroundErrorHandler? onError,
  }) : _onError = onError;

  final ShellBackgroundErrorHandler? _onError;

  /// 运行一个不阻塞当前 UI 反馈的后台任务。
  void run({
    required String taskName,
    required FutureOr<void> Function() task,
  }) {
    unawaited(_runGuarded(
      taskName: taskName,
      task: task,
    ));
  }

  Future<void> _runGuarded({
    required String taskName,
    required FutureOr<void> Function() task,
  }) async {
    try {
      await task();
    } catch (error, stackTrace) {
      try {
        _onError?.call(taskName, error, stackTrace);
      } catch (_) {}
    }
  }
}
