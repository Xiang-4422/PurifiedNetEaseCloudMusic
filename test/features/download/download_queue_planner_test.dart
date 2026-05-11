import 'dart:async';

import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/features/download/application/download_queue_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadQueuePlanner', () {
    test('loads active tasks once and filters queued downloads in memory', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task('queued', DownloadTaskStatus.queued),
          _task('downloading', DownloadTaskStatus.downloading),
          _task('failed', DownloadTaskStatus.failed),
        ],
      );
      final planner = DownloadQueuePlanner(
        musicDataRepository: _FakeMusicDataRepository({
          'queued': _trackWithResources('queued'),
          'downloading': _trackWithResources('downloading'),
          'failed': _trackWithResources('failed'),
          'managed': _trackWithResources('managed', managedDownload: true),
          'local': _trackWithResources('local', sourceType: SourceType.local),
          'new': _trackWithResources('new'),
        }),
        taskDataSource: taskDataSource,
      );
      final downloadedTrackIds = <String>[];

      await planner.queueTracks(
        ['queued', 'downloading', 'failed', 'managed', 'local', 'missing', 'new'],
        downloadTrack: (
          trackId, {
          bool preferHighQuality = true,
        }) async {
          downloadedTrackIds.add(trackId);
          return null;
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(taskDataSource.getTaskCallCount, 0);
      expect(taskDataSource.getTasksCallCount, 1);
      expect(taskDataSource.requestedStatuses, {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      });
      expect(downloadedTrackIds, ['failed', 'new']);
    });
  });
}

DownloadTask _task(String trackId, DownloadTaskStatus status) {
  return DownloadTask(
    trackId: trackId,
    status: status,
    updatedAt: DateTime(2026),
  );
}

TrackWithResources _trackWithResources(
  String id, {
  SourceType sourceType = SourceType.netease,
  bool managedDownload = false,
}) {
  return TrackWithResources(
    track: Track(
      id: id,
      sourceType: sourceType,
      sourceId: id,
      title: 'Track $id',
    ),
    resources: TrackResourceBundle(
      audio: managedDownload
          ? LocalResourceEntry(
              trackId: id,
              kind: LocalResourceKind.audio,
              path: '/tmp/$id.mp3',
              origin: TrackResourceOrigin.managedDownload,
              sizeBytes: 1,
              createdAt: DateTime(2026),
              lastAccessedAt: DateTime(2026),
            )
          : null,
    ),
  );
}

class _FakeMusicDataRepository implements MusicDataRepository {
  const _FakeMusicDataRepository(this.tracksById);

  final Map<String, TrackWithResources> tracksById;

  @override
  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    return trackIds.map((trackId) => tracksById[trackId]).whereType<TrackWithResources>().toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadTaskDataSource implements DownloadTaskDataSource {
  _FakeDownloadTaskDataSource({required this.tasks});

  final List<DownloadTask> tasks;
  int getTaskCallCount = 0;
  int getTasksCallCount = 0;
  Set<DownloadTaskStatus>? requestedStatuses;

  @override
  Future<DownloadTask?> getTask(String trackId) async {
    getTaskCallCount++;
    return tasks.where((task) => task.trackId == trackId).firstOrNull;
  }

  @override
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    getTasksCallCount++;
    requestedStatuses = statuses;
    if (statuses == null || statuses.isEmpty) {
      return tasks;
    }
    return tasks.where((task) => statuses.contains(task.status)).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
