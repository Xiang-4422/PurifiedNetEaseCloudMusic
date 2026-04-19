class DownloadTaskRecord {
  const DownloadTaskRecord({
    required this.trackId,
    required this.status,
    required this.updatedAtMs,
    this.progress,
    this.localPath,
    this.artworkPath,
    this.lyricsPath,
    this.failureReason,
  });

  final String trackId;
  final String status;
  final int updatedAtMs;
  final double? progress;
  final String? localPath;
  final String? artworkPath;
  final String? lyricsPath;
  final String? failureReason;

  Map<String, Object?> toMap() {
    return {
      'trackId': trackId,
      'status': status,
      'updatedAtMs': updatedAtMs,
      'progress': progress,
      'localPath': localPath,
      'artworkPath': artworkPath,
      'lyricsPath': lyricsPath,
      'failureReason': failureReason,
    };
  }

  factory DownloadTaskRecord.fromMap(Map<String, Object?> map) {
    return DownloadTaskRecord(
      trackId: map['trackId'] as String? ?? '',
      status: map['status'] as String? ?? '',
      updatedAtMs: map['updatedAtMs'] as int? ?? 0,
      progress: (map['progress'] as num?)?.toDouble(),
      localPath: map['localPath'] as String?,
      artworkPath: map['artworkPath'] as String?,
      lyricsPath: map['lyricsPath'] as String?,
      failureReason: map['failureReason'] as String?,
    );
  }
}
