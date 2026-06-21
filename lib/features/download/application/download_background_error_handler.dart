/// 下载后台任务失败时的诊断回调。
typedef DownloadBackgroundErrorHandler = void Function(
  String trackId,
  Object error,
  StackTrace stackTrace,
);
