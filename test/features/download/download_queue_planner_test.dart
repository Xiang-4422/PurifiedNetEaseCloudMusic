import 'dart:async';
import 'dart:io';

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
      final tempDirectory = Directory.systemTemp.createTempSync(
        'download-queue-planner-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });
      final managedAudio = File('${tempDirectory.path}/managed.mp3')..writeAsBytesSync([1, 2, 3]);
      final localImportAudio = File('${tempDirectory.path}/local import.mp3')..writeAsBytesSync([1, 2, 3]);
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
          'managed': _trackWithResources(
            'managed',
            audioPath: managedAudio.path,
            audioOrigin: TrackResourceOrigin.managedDownload,
          ),
          'local-import': _trackWithResources(
            'local-import',
            audioPath: localImportAudio.path,
            audioOrigin: TrackResourceOrigin.localImport,
          ),
          'local': _trackWithResources('local', sourceType: SourceType.local),
          'new': _trackWithResources('new'),
        }),
        taskDataSource: taskDataSource,
      );
      final downloadedTrackIds = <String>[];

      await planner.queueTracks(
        [
          'queued',
          'downloading',
          'failed',
          'managed',
          'local-import',
          'local',
          'missing',
          'new',
        ],
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

    test('queues managed download again when indexed file is missing', () async {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'download-queue-planner-missing-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });
      final missingAudio = '${tempDirectory.path}/missing-managed.mp3';
      final planner = DownloadQueuePlanner(
        musicDataRepository: _FakeMusicDataRepository({
          'managed': _trackWithResources(
            'managed',
            audioPath: missingAudio,
            audioOrigin: TrackResourceOrigin.managedDownload,
          ),
        }),
        taskDataSource: _FakeDownloadTaskDataSource(tasks: const []),
      );
      final downloadedTrackIds = <String>[];

      await planner.queueTracks(
        ['managed'],
        downloadTrack: (
          trackId, {
          bool preferHighQuality = true,
        }) async {
          downloadedTrackIds.add(trackId);
          return null;
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(downloadedTrackIds, ['managed']);
    });

    test('queues local import resource again when indexed file is missing', () async {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'download-queue-planner-missing-local-import-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });
      final missingAudio = '${tempDirectory.path}/missing-local-import.mp3';
      final planner = DownloadQueuePlanner(
        musicDataRepository: _FakeMusicDataRepository({
          'local-import': _trackWithResources(
            'local-import',
            audioPath: missingAudio,
            audioOrigin: TrackResourceOrigin.localImport,
          ),
        }),
        taskDataSource: _FakeDownloadTaskDataSource(tasks: const []),
      );
      final downloadedTrackIds = <String>[];

      await planner.queueTracks(
        ['local-import'],
        downloadTrack: (
          trackId, {
          bool preferHighQuality = true,
        }) async {
          downloadedTrackIds.add(trackId);
          return null;
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(downloadedTrackIds, ['local-import']);
    });

    test('queues completed task again when resource index is missing', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task('completed', DownloadTaskStatus.completed),
        ],
      );
      final planner = DownloadQueuePlanner(
        musicDataRepository: _FakeMusicDataRepository({
          'completed': _trackWithResources('completed'),
        }),
        taskDataSource: taskDataSource,
      );
      final downloadedTrackIds = <String>[];

      await planner.queueTracks(
        ['completed'],
        downloadTrack: (
          trackId, {
          bool preferHighQuality = true,
        }) async {
          downloadedTrackIds.add(trackId);
          return null;
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(taskDataSource.getTasksCallCount, 1);
      expect(taskDataSource.requestedStatuses, {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      });
      expect(downloadedTrackIds, ['completed']);
    });

    test('reports background download failure without leaking it', () async {
      final downloadError = StateError('download failed');
      final reported = Completer<void>();
      final reportedTrackIds = <String>[];
      final reportedErrors = <Object>[];
      final unhandledErrors = <Object>[];
      final planner = DownloadQueuePlanner(
        musicDataRepository: _FakeMusicDataRepository({
          'failed': _trackWithResources('failed'),
        }),
        taskDataSource: _FakeDownloadTaskDataSource(tasks: const []),
        onQueuedDownloadError: (trackId, error, stackTrace) {
          reportedTrackIds.add(trackId);
          reportedErrors.add(error);
          reported.complete();
          throw StateError('diagnostic callback failed');
        },
      );

      await runZonedGuarded(
        () async {
          await planner.queueTracks(
            ['failed'],
            downloadTrack: (
              trackId, {
              bool preferHighQuality = true,
            }) {
              return Future<Track?>.error(downloadError);
            },
          );
          await reported.future;
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(reportedTrackIds, ['failed']);
      expect(reportedErrors.single, same(downloadError));
      expect(unhandledErrors, isEmpty);
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
  String? audioPath,
  TrackResourceOrigin audioOrigin = TrackResourceOrigin.managedDownload,
}) {
  return TrackWithResources(
    track: Track(
      id: id,
      sourceType: sourceType,
      sourceId: id,
      title: 'Track $id',
    ),
    resources: TrackResourceBundle(
      audio: audioPath != null
          ? LocalResourceEntry(
              trackId: id,
              kind: LocalResourceKind.audio,
              path: audioPath,
              origin: audioOrigin,
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
