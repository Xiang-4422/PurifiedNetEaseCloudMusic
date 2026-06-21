import 'dart:async';

import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/features/download/application/download_background_error_handler.dart';
import 'package:bujuan/features/download/application/download_file_store.dart';

/// 启动恢复服务，负责把中断中的下载任务转成可重试状态并恢复 queued 任务。
class DownloadRecoveryService {
  /// 创建下载恢复服务。
  DownloadRecoveryService({
    required DownloadTaskDataSource taskDataSource,
    required DownloadFileStore fileStore,
    DownloadBackgroundErrorHandler? onQueuedRestartError,
  })  : _taskDataSource = taskDataSource,
        _fileStore = fileStore,
        _onQueuedRestartError = onQueuedRestartError;

  final DownloadTaskDataSource _taskDataSource;
  final DownloadFileStore _fileStore;
  final DownloadBackgroundErrorHandler? _onQueuedRestartError;

  /// 恢复中断下载任务。
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
    final queuedTasks = interruptedTasks.where((task) => task.status == DownloadTaskStatus.queued).toList();
    final downloadingTasks = interruptedTasks.where((task) => task.status == DownloadTaskStatus.downloading).toList();

    for (final task in downloadingTasks) {
      await _fileStore.deleteTemporaryDownloadIfExists(task.temporaryPath);
      await markInterruptedFailed(task.trackId);
    }
    for (final task in queuedTasks) {
      unawaited(_restartQueuedTask(task.trackId, restartQueuedTask));
    }
    return _taskDataSource.getTasks(
      statuses: const {
        DownloadTaskStatus.failed,
      },
    );
  }

  Future<void> _restartQueuedTask(
    String trackId,
    Future<Track?> Function(String trackId) restartQueuedTask,
  ) async {
    try {
      await restartQueuedTask(trackId);
    } catch (error, stackTrace) {
      try {
        _onQueuedRestartError?.call(trackId, error, stackTrace);
      } catch (_) {}
    }
  }
}
