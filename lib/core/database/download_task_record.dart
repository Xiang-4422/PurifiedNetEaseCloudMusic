class DownloadTaskRecord {
  const DownloadTaskRecord({
    required this.trackId,
    required this.status,
    required this.updatedAtMs,
    this.progress,
    this.temporaryPath,
    this.failureReason,
  });

  final String trackId;
  final String status;
  final int updatedAtMs;
  final double? progress;
  final String? temporaryPath;
  final String? failureReason;

  Map<String, Object?> toMap() {
    return {
      'trackId': trackId,
      'status': status,
      'updatedAtMs': updatedAtMs,
      'progress': progress,
      'temporaryPath': temporaryPath,
      'failureReason': failureReason,
    };
  }

  factory DownloadTaskRecord.fromMap(Map<String, Object?> map) {
    return DownloadTaskRecord(
      trackId: map['trackId'] as String? ?? '',
      status: map['status'] as String? ?? '',
      updatedAtMs: map['updatedAtMs'] as int? ?? 0,
      progress: (map['progress'] as num?)?.toDouble(),
      temporaryPath: map['temporaryPath'] as String?,
      failureReason: map['failureReason'] as String?,
    );
  }
}
