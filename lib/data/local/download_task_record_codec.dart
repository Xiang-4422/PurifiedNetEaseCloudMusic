import 'package:bujuan/core/database/download_task_record.dart';
import 'package:bujuan/core/database/isar_download_task_entity.dart';
import 'package:bujuan/domain/entities/download_task.dart';

class DownloadTaskRecordCodec {
  const DownloadTaskRecordCodec._();

  static DownloadTaskRecord encode(DownloadTask task) {
    return DownloadTaskRecord(
      trackId: task.trackId,
      status: task.status.name,
      updatedAtMs: task.updatedAt.millisecondsSinceEpoch,
      progress: task.progress,
      localPath: task.localPath,
      artworkPath: task.artworkPath,
      lyricsPath: task.lyricsPath,
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
      localPath: record.localPath,
      artworkPath: record.artworkPath,
      lyricsPath: record.lyricsPath,
      failureReason: record.failureReason,
    );
  }

  static IsarDownloadTaskEntity encodeEntity(DownloadTask task) {
    return IsarDownloadTaskEntity(
      schemaVersion: 1,
      trackId: task.trackId,
      status: task.status.name,
      updatedAtMs: task.updatedAt.millisecondsSinceEpoch,
      progress: task.progress,
      localPath: task.localPath,
      artworkPath: task.artworkPath,
      lyricsPath: task.lyricsPath,
      failureReason: task.failureReason,
    );
  }

  static DownloadTask decodeEntity(IsarDownloadTaskEntity entity) {
    return DownloadTask(
      trackId: entity.trackId,
      status: DownloadTaskStatus.values.firstWhere(
        (item) => item.name == entity.status,
        orElse: () => DownloadTaskStatus.queued,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtMs),
      progress: entity.progress,
      localPath: entity.localPath,
      artworkPath: entity.artworkPath,
      lyricsPath: entity.lyricsPath,
      failureReason: entity.failureReason,
    );
  }
}
