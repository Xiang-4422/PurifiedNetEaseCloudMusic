part of 'player_controller.dart';

/// 生成 mini player 控制反馈指标的补充信息。
@visibleForTesting
String miniPlayerFeedbackMetricDetails({
  required String action,
  required bool succeeded,
  Object? error,
}) {
  final result = succeeded ? 'success' : 'error';
  if (succeeded || error == null) {
    return 'action=$action result=$result';
  }
  return 'action=$action result=$result error=${error.runtimeType}';
}

void _reportPlaybackControllerBackgroundError(
  String taskName,
  String? trackId,
  Object error,
  StackTrace stackTrace,
) {
  developer.log(
    'playback.controller.backgroundTask.failed task=$taskName trackId=${trackId ?? ''}',
    name: 'Playback',
    error: error,
    stackTrace: stackTrace,
  );
}
