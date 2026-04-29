import 'dart:async';

import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/application/download_file_store.dart';

/// 启动恢复服务，负责把中断中的下载任务转成可重试状态并恢复 queued 任务。
class DownloadRecoveryService {
  DownloadRecoveryService({
    required DownloadTaskDataSource taskDataSource,
    required DownloadFileStore fileStore,
  })  : _taskDataSource = taskDataSource,
        _fileStore = fileStore;

  final DownloadTaskDataSource _taskDataSource;
  final DownloadFileStore _fileStore;

  Future<List<DownloadTask>> recoverInterruptedTasks({
    required Future<Track?> Function(String trackId) markInterruptedFailed,
    required Future<Track?> Function(String trackId) restartQueuedTask,
  }) async {
    await _fileStore.cleanupOrphanTemporaryFiles();
    final interruptedTasks = await _taskDataSource.getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
    final queuedTasks = interruptedTasks
        .where((task) => task.status == DownloadTaskStatus.queued)
        .toList();
    final downloadingTasks = interruptedTasks
        .where((task) => task.status == DownloadTaskStatus.downloading)
        .toList();

    for (final task in downloadingTasks) {
      await _fileStore.deleteTemporaryDownloadIfExists(task.temporaryPath);
      await markInterruptedFailed(task.trackId);
    }
    for (final task in queuedTasks) {
      unawaited(restartQueuedTask(task.trackId));
    }
    return _taskDataSource.getTasks(
      statuses: const {
        DownloadTaskStatus.failed,
      },
    );
  }
}
