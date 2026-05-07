/// 下载任务持久化记录。
class DownloadTaskRecord {
  /// 创建下载任务记录。
  const DownloadTaskRecord({
    required this.trackId,
    required this.status,
    required this.updatedAtMs,
    this.progress,
    this.temporaryPath,
    this.failureReason,
  });

  /// 歌曲 id。
  final String trackId;

  /// 任务状态名称。
  final String status;

  /// 最近更新时间戳，单位毫秒。
  final int updatedAtMs;

  /// 下载进度。
  final double? progress;

  /// 临时下载文件路径。
  final String? temporaryPath;

  /// 失败原因。
  final String? failureReason;

  /// 转为可持久化的 Map。
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

  /// 从持久化 Map 创建下载任务记录。
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
