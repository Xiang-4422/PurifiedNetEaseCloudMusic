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
    this.localPath,
    this.artworkPath,
    this.lyricsPath,
    this.failureReason,
  });

  final String trackId;
  final DownloadTaskStatus status;
  final DateTime updatedAt;
  final double? progress;
  final String? localPath;
  final String? artworkPath;
  final String? lyricsPath;
  final String? failureReason;

  DownloadTask copyWith({
    String? trackId,
    DownloadTaskStatus? status,
    DateTime? updatedAt,
    double? progress,
    String? localPath,
    String? artworkPath,
    String? lyricsPath,
    String? failureReason,
  }) {
    return DownloadTask(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      artworkPath: artworkPath ?? this.artworkPath,
      lyricsPath: lyricsPath ?? this.lyricsPath,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
