import 'package:bujuan/core/database/download_task_record.dart';
import 'package:bujuan/domain/entities/download_task.dart';

class DownloadTaskRecordCodec {
  const DownloadTaskRecordCodec._();

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
