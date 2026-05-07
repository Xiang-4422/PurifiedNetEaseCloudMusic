/// 下载任务状态。
enum DownloadTaskStatus {
  /// 等待下载。
  queued,

  /// 正在下载。
  downloading,

  /// 已下载完成。
  completed,

  /// 下载失败。
  failed,
}

/// 下载任务领域实体。
class DownloadTask {
  /// 创建下载任务。
  const DownloadTask({
    required this.trackId,
    required this.status,
    required this.updatedAt,
    this.progress,
    this.temporaryPath,
    this.failureReason,
  });

  /// 歌曲 id。
  final String trackId;

  /// 当前任务状态。
  final DownloadTaskStatus status;

  /// 最近更新时间。
  final DateTime updatedAt;

  /// 下载进度。
  final double? progress;

  /// 临时文件路径。
  final String? temporaryPath;

  /// 失败原因。
  final String? failureReason;

  /// 复制下载任务并替换指定字段。
  DownloadTask copyWith({
    String? trackId,
    DownloadTaskStatus? status,
    DateTime? updatedAt,
    double? progress,
    String? temporaryPath,
    String? failureReason,
  }) {
    return DownloadTask(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      progress: progress ?? this.progress,
      temporaryPath: temporaryPath ?? this.temporaryPath,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
