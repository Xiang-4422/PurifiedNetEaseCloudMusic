enum DownloadTaskStatus {
  queued,
  downloading,
  completed,
  failed,
}

class DownloadTask {
  const DownloadTask({
    required this.trackId,
    required this.status,
    required this.updatedAt,
    this.progress,
    this.temporaryPath,
    this.failureReason,
  });

  final String trackId;
  final DownloadTaskStatus status;
  final DateTime updatedAt;
  final double? progress;
  final String? temporaryPath;
  final String? failureReason;

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
