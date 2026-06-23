import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/features/download/application/download_task_state_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadTaskStateStore', () {
    test('normalizes task writes and removes raw legacy alias', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task(
            ' 1 ',
            DownloadTaskStatus.downloading,
            progress: 0.5,
            temporaryPath: '/tmp/1.mp3.download',
          ),
        ],
      );
      final musicDataRepository = _FakeMusicDataRepository();
      final store = DownloadTaskStateStore(
        taskDataSource: taskDataSource,
        musicDataRepository: musicDataRepository,
      );

      final track = await store.markFailed(
        ' 1 ',
        reason: 'download_interrupted',
      );

      expect(track?.id, '1');
      expect(taskDataSource.savedTasks.single.trackId, '1');
      expect(taskDataSource.savedTasks.single.status, DownloadTaskStatus.failed);
      expect(taskDataSource.savedTasks.single.progress, 0.5);
      expect(
        taskDataSource.savedTasks.single.temporaryPath,
        '/tmp/1.mp3.download',
      );
      expect(taskDataSource.savedTasks.single.failureReason, 'download_interrupted');
      expect(taskDataSource.removedTrackIds, [' 1 ']);
      expect(await taskDataSource.getTask(' 1 '), isNull);
      expect((await taskDataSource.getTask('1'))?.status, DownloadTaskStatus.failed);
      expect(musicDataRepository.requestedTrackIds, ['1']);
    });

    test('clearTask removes normalized and raw task aliases', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task('1', DownloadTaskStatus.queued),
          _task(' 1 ', DownloadTaskStatus.queued),
        ],
      );
      final store = DownloadTaskStateStore(
        taskDataSource: taskDataSource,
        musicDataRepository: _FakeMusicDataRepository(),
      );

      await store.clearTask(' 1 ');

      expect(taskDataSource.removedTrackIds, ['1', ' 1 ']);
      expect(await taskDataSource.getTask('1'), isNull);
      expect(await taskDataSource.getTask(' 1 '), isNull);
    });
  });
}

DownloadTask _task(
  String trackId,
  DownloadTaskStatus status, {
  double? progress,
  String? temporaryPath,
}) {
  return DownloadTask(
    trackId: trackId,
    status: status,
    updatedAt: DateTime(2026),
    progress: progress,
    temporaryPath: temporaryPath,
  );
}

class _FakeDownloadTaskDataSource implements DownloadTaskDataSource {
  _FakeDownloadTaskDataSource({
    List<DownloadTask> tasks = const [],
  }) : _tasks = {
          for (final task in tasks) task.trackId: task,
        };

  final Map<String, DownloadTask> _tasks;
  final List<String> removedTrackIds = [];
  final List<DownloadTask> savedTasks = [];

  @override
  Future<DownloadTask?> getTask(String trackId) async {
    return _tasks[trackId];
  }

  @override
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    final tasks = _tasks.values.toList();
    if (statuses == null || statuses.isEmpty) {
      return tasks;
    }
    return tasks.where((task) => statuses.contains(task.status)).toList();
  }

  @override
  Future<void> saveTask(DownloadTask task) async {
    savedTasks.add(task);
    _tasks[task.trackId] = task;
  }

  @override
  Future<void> removeTask(String trackId) async {
    removedTrackIds.add(trackId);
    _tasks.remove(trackId);
  }

  @override
  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return Stream.fromFuture(getTasks(statuses: statuses));
  }
}

class _FakeMusicDataRepository implements MusicDataRepository {
  final List<String> requestedTrackIds = [];

  @override
  Future<Track?> getTrack(String trackId) async {
    requestedTrackIds.add(trackId);
    return Track(
      id: trackId,
      sourceType: SourceType.netease,
      sourceId: trackId,
      title: 'Track $trackId',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
