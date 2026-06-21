import 'dart:async';

import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/features/download/application/download_file_store.dart';
import 'package:bujuan/features/download/application/download_recovery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadRecoveryService', () {
    test('cleans temporary files before loading interrupted tasks', () async {
      final fileStore = _FakeDownloadFileStore();
      final taskDataSource = _FakeDownloadTaskDataSource(
        isCleanupCompleted: () => fileStore.cleanupCompleted,
      );
      final service = DownloadRecoveryService(
        taskDataSource: taskDataSource,
        fileStore: fileStore,
      );

      await service.recoverInterruptedTasks(
        markInterruptedFailed: (_) async => null,
        restartQueuedTask: (_) async => null,
      );

      expect(fileStore.cleanupCallCount, 1);
      expect(
        taskDataSource.cleanupCompletedBeforeFirstRead,
        isTrue,
        reason: '启动恢复读取任务前必须先清理孤立 .download 文件。',
      );
    });

    test('marks interrupted downloading tasks failed and removes temp file', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task(
            'downloading',
            DownloadTaskStatus.downloading,
            temporaryPath: '/tmp/downloading.mp3.download',
          ),
        ],
      );
      final fileStore = _FakeDownloadFileStore();
      final service = DownloadRecoveryService(
        taskDataSource: taskDataSource,
        fileStore: fileStore,
      );
      final failedTrackIds = <String>[];

      final failedTasks = await service.recoverInterruptedTasks(
        markInterruptedFailed: (trackId) async {
          failedTrackIds.add(trackId);
          await taskDataSource.saveTask(
            _task(
              trackId,
              DownloadTaskStatus.failed,
              failureReason: 'download_interrupted',
            ),
          );
          return null;
        },
        restartQueuedTask: (_) async => null,
      );

      expect(fileStore.deletedTemporaryPaths, ['/tmp/downloading.mp3.download']);
      expect(failedTrackIds, ['downloading']);
      expect(failedTasks.map((task) => task.trackId), ['downloading']);
      expect(failedTasks.single.failureReason, 'download_interrupted');
    });

    test('restarts queued tasks without blocking recovery result', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task('queued', DownloadTaskStatus.queued),
          _task('failed', DownloadTaskStatus.failed),
        ],
      );
      final service = DownloadRecoveryService(
        taskDataSource: taskDataSource,
        fileStore: _FakeDownloadFileStore(),
      );
      final restartedTrackIds = <String>[];
      final pendingRestart = Completer<Track?>();

      final failedTasks = await service.recoverInterruptedTasks(
        markInterruptedFailed: (_) async => null,
        restartQueuedTask: (trackId) {
          restartedTrackIds.add(trackId);
          return pendingRestart.future;
        },
      );

      expect(restartedTrackIds, ['queued']);
      expect(failedTasks.map((task) => task.trackId), ['failed']);
    });

    test('reports queued restart failure without failing recovery', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task('queued', DownloadTaskStatus.queued),
          _task('failed', DownloadTaskStatus.failed),
        ],
      );
      final restartError = StateError('restart failed');
      final reportedError = Completer<_QueuedRestartError>();
      final service = DownloadRecoveryService(
        taskDataSource: taskDataSource,
        fileStore: _FakeDownloadFileStore(),
        onQueuedRestartError: (trackId, error, stackTrace) {
          reportedError.complete(
            _QueuedRestartError(
              trackId: trackId,
              error: error,
              stackTrace: stackTrace,
            ),
          );
        },
      );

      final failedTasks = await service.recoverInterruptedTasks(
        markInterruptedFailed: (_) async => null,
        restartQueuedTask: (_) => Future<Track?>.error(restartError),
      );

      expect(failedTasks.map((task) => task.trackId), ['failed']);
      final error = await reportedError.future;
      expect(error.trackId, 'queued');
      expect(error.error, same(restartError));
      expect(error.stackTrace, isNotNull);
    });
  });
}

DownloadTask _task(
  String trackId,
  DownloadTaskStatus status, {
  String? temporaryPath,
  String? failureReason,
}) {
  return DownloadTask(
    trackId: trackId,
    status: status,
    updatedAt: DateTime(2026),
    temporaryPath: temporaryPath,
    failureReason: failureReason,
  );
}

class _FakeDownloadTaskDataSource implements DownloadTaskDataSource {
  _FakeDownloadTaskDataSource({
    List<DownloadTask> tasks = const [],
    bool Function()? isCleanupCompleted,
  })  : _isCleanupCompleted = isCleanupCompleted ?? (() => false),
        _tasks = {
          for (final task in tasks) task.trackId: task,
        };

  final Map<String, DownloadTask> _tasks;
  final bool Function() _isCleanupCompleted;
  bool cleanupCompletedBeforeFirstRead = false;

  @override
  Future<DownloadTask?> getTask(String trackId) async {
    return _tasks[trackId];
  }

  @override
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    cleanupCompletedBeforeFirstRead = _isCleanupCompleted();
    final tasks = _tasks.values.toList();
    if (statuses == null || statuses.isEmpty) {
      return tasks;
    }
    return tasks.where((task) => statuses.contains(task.status)).toList();
  }

  @override
  Future<void> saveTask(DownloadTask task) async {
    _tasks[task.trackId] = task;
  }

  @override
  Future<void> removeTask(String trackId) async {
    _tasks.remove(trackId);
  }

  @override
  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return Stream.fromFuture(getTasks(statuses: statuses));
  }
}

class _FakeDownloadFileStore extends DownloadFileStore {
  _FakeDownloadFileStore() : super();

  bool cleanupCompleted = false;
  final List<String?> deletedTemporaryPaths = [];
  int cleanupCallCount = 0;

  @override
  Future<void> cleanupOrphanTemporaryFiles() async {
    cleanupCallCount++;
    cleanupCompleted = true;
  }

  @override
  Future<void> deleteTemporaryDownloadIfExists(String? temporaryPath) async {
    deletedTemporaryPaths.add(temporaryPath);
  }
}

class _QueuedRestartError {
  const _QueuedRestartError({
    required this.trackId,
    required this.error,
    required this.stackTrace,
  });

  final String trackId;
  final Object error;
  final StackTrace stackTrace;
}
