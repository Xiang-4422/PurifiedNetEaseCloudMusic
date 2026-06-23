import 'dart:async';
import 'dart:io';

import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/download/application/download_file_store.dart';
import 'package:bujuan/features/download/application/download_resource_writer.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadRepository workflow', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('download-workflow-');
    });

    tearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('clears task only after downloaded audio is indexed', () async {
      final taskDataSource = _FakeDownloadTaskDataSource();
      final resourceWriter = _FakeDownloadResourceWriter(saveManagedResult: true);
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: _FakeDownloadFileStore(tempDirectory),
        resourceWriter: resourceWriter,
      );

      final track = await repository.performDownloadTrack(
        '1',
        preferHighQuality: true,
      );

      expect(track?.id, '1');
      expect(await taskDataSource.getTask('1'), isNull);
      expect(taskDataSource.removedTrackIds, contains('1'));
      expect(resourceWriter.savedLocalPaths.single, endsWith('/audio/1.mp3'));
      expect(File(resourceWriter.savedLocalPaths.single).existsSync(), isTrue);
    });

    test('keeps failed task when downloaded audio cannot be indexed', () async {
      final taskDataSource = _FakeDownloadTaskDataSource();
      final resourceWriter = _FakeDownloadResourceWriter(saveManagedResult: false);
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: _FakeDownloadFileStore(tempDirectory),
        resourceWriter: resourceWriter,
      );

      final track = await repository.performDownloadTrack(
        '1',
        preferHighQuality: true,
      );
      final task = await taskDataSource.getTask('1');

      expect(track?.id, '1');
      expect(task?.status, DownloadTaskStatus.failed);
      expect(task?.failureReason, 'local_resource_index_unavailable');
      expect(taskDataSource.removedTrackIds, isNot(contains('1')));
      expect(resourceWriter.savedLocalPaths.single, endsWith('/audio/1.mp3'));
      expect(File(resourceWriter.savedLocalPaths.single).existsSync(), isFalse);
    });

    test('removes playback cache files when cache audio cannot be indexed', () async {
      final taskDataSource = _FakeDownloadTaskDataSource();
      final resourceWriter = _FakeDownloadResourceWriter(
        saveManagedResult: true,
        savePlaybackCacheResult: false,
      );
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: _FakeDownloadFileStore(tempDirectory),
        resourceWriter: resourceWriter,
      );

      final track = await repository.performCacheTrackForPlayback(
        '1',
        preferHighQuality: true,
      );

      expect(track?.id, '1');
      expect(await taskDataSource.getTask('1'), isNull);
      expect(resourceWriter.savedPlaybackCacheAudioPaths.single, endsWith('/cache-audio/1.mp3'));
      expect(File(resourceWriter.savedPlaybackCacheAudioPaths.single).existsSync(), isFalse);
    });

    test('redownloads when only a completed task remains without resource index', () async {
      final taskDataSource = _FakeDownloadTaskDataSource(
        tasks: [
          _task('1', DownloadTaskStatus.completed),
        ],
      );
      final resourceWriter = _FakeDownloadResourceWriter(saveManagedResult: true);
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: _FakeDownloadFileStore(tempDirectory),
        resourceWriter: resourceWriter,
      );

      final track = await repository.downloadTrack(
        '1',
        preferHighQuality: true,
      );

      expect(track?.id, '1');
      expect(resourceWriter.savedLocalPaths.single, endsWith('/audio/1.mp3'));
      expect(File(resourceWriter.savedLocalPaths.single).existsSync(), isTrue);
      expect(await taskDataSource.getTask('1'), isNull);
      expect(taskDataSource.removedTrackIds, contains('1'));
    });

    test('promotes existing playback cache instead of downloading again', () async {
      final cachedAudio = File('${tempDirectory.path}/cached.mp3');
      await cachedAudio.writeAsBytes([1, 2, 3]);
      final taskDataSource = _FakeDownloadTaskDataSource();
      final resourceWriter = _FakeDownloadResourceWriter(saveManagedResult: true);
      final musicDataRepository = _FakeMusicDataRepository(
        resources: TrackResourceBundle(
          audio: _resource(
            trackId: '1',
            path: cachedAudio.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
        ),
      );
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: _FailingDownloadFileStore(tempDirectory),
        resourceWriter: resourceWriter,
        musicDataRepository: musicDataRepository,
      );

      final track = await repository.performDownloadTrack(
        '1',
        preferHighQuality: true,
      );

      expect(track?.id, '1');
      expect(await taskDataSource.getTask('1'), isNull);
      expect(resourceWriter.promotedTrackIds, ['1']);
      expect(resourceWriter.savedLocalPaths, isEmpty);
      expect(musicDataRepository.playbackUrlCallCount, 0);
    });

    test('promotes existing legacy file uri playback cache instead of downloading again', () async {
      final cachedAudio = File('${tempDirectory.path}/cached legacy.mp3');
      await cachedAudio.writeAsBytes([1, 2, 3]);
      final taskDataSource = _FakeDownloadTaskDataSource();
      final resourceWriter = _FakeDownloadResourceWriter(saveManagedResult: true);
      final musicDataRepository = _FakeMusicDataRepository(
        resources: TrackResourceBundle(
          audio: _resource(
            trackId: '1',
            path: cachedAudio.uri.replace(queryParameters: {'token': 'local'}).toString(),
            origin: TrackResourceOrigin.playbackCache,
          ),
        ),
      );
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: _FailingDownloadFileStore(tempDirectory),
        resourceWriter: resourceWriter,
        musicDataRepository: musicDataRepository,
      );

      final track = await repository.performDownloadTrack(
        '1',
        preferHighQuality: true,
      );

      expect(track?.id, '1');
      expect(await taskDataSource.getTask('1'), isNull);
      expect(resourceWriter.promotedTrackIds, ['1']);
      expect(resourceWriter.savedLocalPaths, isEmpty);
      expect(musicDataRepository.playbackUrlCallCount, 0);
    });

    test('skips playback cache when legacy file uri audio resource exists', () async {
      final cachedAudio = File('${tempDirectory.path}/playback cache.mp3');
      await cachedAudio.writeAsBytes([1, 2, 3]);
      final taskDataSource = _FakeDownloadTaskDataSource();
      final resourceWriter = _FakeDownloadResourceWriter(saveManagedResult: true);
      final musicDataRepository = _FakeMusicDataRepository(
        resources: TrackResourceBundle(
          audio: _resource(
            trackId: '1',
            path: cachedAudio.uri.replace(queryParameters: {'token': 'local'}).toString(),
            origin: TrackResourceOrigin.playbackCache,
          ),
        ),
      );
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: _FailingDownloadFileStore(tempDirectory),
        resourceWriter: resourceWriter,
        musicDataRepository: musicDataRepository,
      );

      final track = await repository.performCacheTrackForPlayback(
        '1',
        preferHighQuality: true,
      );

      expect(track?.id, '1');
      expect(resourceWriter.savedPlaybackCacheAudioPaths, isEmpty);
      expect(musicDataRepository.playbackUrlCallCount, 0);
    });

    test('cancelled download does not save resource facts after file write completes', () async {
      final taskDataSource = _FakeDownloadTaskDataSource();
      final resourceWriter = _FakeDownloadResourceWriter(saveManagedResult: true);
      final fileStore = _BlockingDownloadFileStore(tempDirectory);
      final repository = _buildRepository(
        taskDataSource: taskDataSource,
        fileStore: fileStore,
        resourceWriter: resourceWriter,
      );

      final downloadFuture = repository.downloadTrack('1');
      await fileStore.downloadStarted.future;

      await repository.cancelTask('1');
      fileStore.finishDownload.complete();
      final track = await downloadFuture;

      expect(track, isNull);
      expect(await taskDataSource.getTask('1'), isNull);
      expect(resourceWriter.savedLocalPaths, isEmpty);
      expect(fileStore.completedOutputPath, isNotNull);
      expect(File(fileStore.completedOutputPath!).existsSync(), isFalse);
    });
  });
}

DownloadRepository _buildRepository({
  required _FakeDownloadTaskDataSource taskDataSource,
  required DownloadFileStore fileStore,
  required DownloadResourceWriter resourceWriter,
  _FakeMusicDataRepository? musicDataRepository,
}) {
  return DownloadRepository(
    musicDataRepository: musicDataRepository ?? _FakeMusicDataRepository(),
    taskDataSource: taskDataSource,
    resourceIndexRepository: _UnusedLocalResourceIndexRepository(),
    fileStore: fileStore,
    resourceWriter: resourceWriter,
  );
}

DownloadTask _task(String trackId, DownloadTaskStatus status) {
  return DownloadTask(
    trackId: trackId,
    status: status,
    updatedAt: DateTime(2026),
  );
}

class _FakeMusicDataRepository implements MusicDataRepository {
  _FakeMusicDataRepository({
    this.resources = const TrackResourceBundle(),
  });

  final TrackResourceBundle resources;
  int playbackUrlCallCount = 0;
  final Track _track = const Track(
    id: '1',
    sourceType: SourceType.netease,
    sourceId: '1',
    title: 'Track 1',
  );

  @override
  Future<Track?> getTrack(String trackId) async {
    return trackId == _track.id ? _track : null;
  }

  @override
  Future<TrackWithResources?> getTrackWithResources(String trackId) async {
    if (trackId != _track.id) {
      return null;
    }
    return TrackWithResources(
      track: _track,
      resources: resources,
    );
  }

  @override
  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
    bool forceRefresh = false,
  }) async {
    playbackUrlCallCount++;
    return 'https://audio.test/$trackId.mp3';
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadFileStore extends DownloadFileStore {
  _FakeDownloadFileStore(this.rootDirectory) : super(dio: Dio());

  final Directory rootDirectory;

  @override
  Future<DownloadDirectories> ensureDownloadDirectories() async {
    final audio = await _ensureChildDirectory('audio');
    final artwork = await _ensureChildDirectory('artwork');
    final lyrics = await _ensureChildDirectory('lyrics');
    return DownloadDirectories(audio: audio, artwork: artwork, lyrics: lyrics);
  }

  @override
  Future<DownloadDirectories> ensureCacheDirectories() async {
    final audio = await _ensureChildDirectory('cache-audio');
    final artwork = await _ensureChildDirectory('cache-artwork');
    final lyrics = await _ensureChildDirectory('cache-lyrics');
    return DownloadDirectories(audio: audio, artwork: artwork, lyrics: lyrics);
  }

  @override
  String buildAudioPath(
    Track track,
    String playbackUrl,
    Directory audioDirectory,
  ) {
    return '${audioDirectory.path}/${track.id}.mp3';
  }

  @override
  Future<void> downloadBinaryFile(
    String url,
    String outputPath, {
    required Future<void> Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    await onProgress(0.5);
    await File(outputPath).writeAsBytes([1, 2, 3]);
  }

  @override
  Future<String?> downloadArtworkFile(
    Track track,
    Directory artworkDirectory,
  ) async {
    return null;
  }

  @override
  Future<String?> writeLyricsFile(
    String trackId,
    Directory lyricsDirectory,
    TrackLyrics? lyrics,
  ) async {
    return null;
  }

  Future<Directory> _ensureChildDirectory(String name) async {
    final directory = Directory('${rootDirectory.path}/$name');
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}

class _FailingDownloadFileStore extends _FakeDownloadFileStore {
  _FailingDownloadFileStore(super.rootDirectory);

  @override
  Future<void> downloadBinaryFile(
    String url,
    String outputPath, {
    required Future<void> Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) {
    throw StateError('download should not be called');
  }
}

class _BlockingDownloadFileStore extends _FakeDownloadFileStore {
  _BlockingDownloadFileStore(super.rootDirectory);

  final Completer<void> downloadStarted = Completer<void>();
  final Completer<void> finishDownload = Completer<void>();
  String? completedOutputPath;

  @override
  Future<void> downloadBinaryFile(
    String url,
    String outputPath, {
    required Future<void> Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    await onProgress(0.5);
    if (!downloadStarted.isCompleted) {
      downloadStarted.complete();
    }
    await finishDownload.future;
    final temporaryPath = '$outputPath.download';
    await File(temporaryPath).writeAsBytes([1, 2, 3]);
    if (File(outputPath).existsSync()) {
      await File(outputPath).delete();
    }
    completedOutputPath = (await File(temporaryPath).rename(outputPath)).path;
  }
}

class _FakeDownloadResourceWriter extends DownloadResourceWriter {
  _FakeDownloadResourceWriter({
    required this.saveManagedResult,
    this.savePlaybackCacheResult = true,
  }) : super(resourceIndexRepository: _UnusedLocalResourceIndexRepository());

  final bool saveManagedResult;
  final bool savePlaybackCacheResult;
  final List<String> savedLocalPaths = [];
  final List<String> savedPlaybackCacheAudioPaths = [];
  final List<String> promotedTrackIds = [];

  @override
  Future<bool> saveManagedDownloadResources(
    String trackId, {
    required String localPath,
    String? artworkPath,
    String? lyricsPath,
  }) async {
    savedLocalPaths.add(localPath);
    return saveManagedResult;
  }

  @override
  Future<bool> savePlaybackCacheResources(
    String trackId, {
    required String audioPath,
    String? artworkPath,
    String? lyricsPath,
  }) async {
    savedPlaybackCacheAudioPaths.add(audioPath);
    return savePlaybackCacheResult;
  }

  @override
  Future<bool> promoteResourcesToManagedDownload(
    String trackId,
    TrackResourceBundle bundle,
  ) async {
    promotedTrackIds.add(trackId);
    return saveManagedResult;
  }
}

class _FakeDownloadTaskDataSource implements DownloadTaskDataSource {
  _FakeDownloadTaskDataSource({
    List<DownloadTask> tasks = const [],
  }) {
    for (final task in tasks) {
      _tasks[task.trackId] = task;
    }
  }

  final Map<String, DownloadTask> _tasks = {};
  final List<String> removedTrackIds = [];

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
  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return Stream.fromFuture(getTasks(statuses: statuses));
  }

  @override
  Future<void> saveTask(DownloadTask task) async {
    _tasks[task.trackId] = task;
  }

  @override
  Future<void> removeTask(String trackId) async {
    removedTrackIds.add(trackId);
    _tasks.remove(trackId);
  }
}

class _UnusedLocalResourceIndexRepository implements LocalResourceIndexRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalResourceEntry _resource({
  required String trackId,
  required String path,
  required TrackResourceOrigin origin,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: LocalResourceKind.audio,
    path: path,
    origin: origin,
    sizeBytes: 3,
    createdAt: now,
    lastAccessedAt: now,
  );
}
