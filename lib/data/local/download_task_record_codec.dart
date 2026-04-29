import 'package:bujuan/core/database/download_task_record.dart';
import 'package:bujuan/domain/entities/download_task.dart';

/// 下载任务记录 codec，负责领域实体和数据库记录互转。
class DownloadTaskRecordCodec {
  /// 禁止实例化下载任务记录 codec。
  const DownloadTaskRecordCodec._();

  /// 将下载任务实体编码为数据库记录。
  static DownloadTaskRecord encode(DownloadTask task) {
    return DownloadTaskRecord(
      trackId: task.trackId,
      status: task.status.name,
      updatedAtMs: task.updatedAt.millisecondsSinceEpoch,
      progress: task.progress,
      temporaryPath: task.temporaryPath,
      failureReason: task.failureReason,
    );
  }

  /// 将数据库记录解码为下载任务实体。
  static DownloadTask decode(DownloadTaskRecord record) {
    return DownloadTask(
      trackId: record.trackId,
      status: DownloadTaskStatus.values.firstWhere(
        (item) => item.name == record.status,
        orElse: () => DownloadTaskStatus.queued,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(record.updatedAtMs),
      progress: record.progress,
      temporaryPath: record.temporaryPath,
      failureReason: record.failureReason,
    );
  }
}
