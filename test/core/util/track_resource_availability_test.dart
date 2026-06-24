import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/util/track_resource_availability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrackResourceAvailability', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('track-resource-availability-');
    });

    tearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('normalizes safe local file uri resources', () async {
      final audioFile = await _writeFile(tempDirectory, 'song with space.mp3');
      final resource = _audioResource(
        Uri(
          scheme: 'file',
          host: 'localhost',
          path: audioFile.path,
          queryParameters: const {'token': 'local'},
        ).toString(),
      );

      expect(TrackResourceAvailability.localPath(resource), audioFile.path);
      expect(TrackResourceAvailability.existingLocalPath(resource), audioFile.path);
    });

    test('rejects remote and unsafe file uri resource paths', () async {
      final remoteResource = _audioResource('https://audio.test/song.mp3');
      final unsafeResource = _audioResource(
        Uri(
          scheme: 'file',
          host: 'media-server',
          path: '/shared/song.mp3',
        ).toString(),
      );

      expect(TrackResourceAvailability.localPath(remoteResource), isNull);
      expect(TrackResourceAvailability.localPath(unsafeResource), isNull);
      expect(TrackResourceAvailability.existingLocalPath(remoteResource), isNull);
      expect(TrackResourceAvailability.existingLocalPath(unsafeResource), isNull);
    });

    test('separates playable audio from cached display state', () async {
      final managedAudio = _audioResource(
        await _writeFile(tempDirectory, 'managed.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.managedDownload,
      );
      final playbackCacheAudio = _audioResource(
        await _writeFile(tempDirectory, 'playback-cache.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.playbackCache,
      );
      final localImportAudio = _audioResource(
        await _writeFile(tempDirectory, 'local-import.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.localImport,
      );

      expect(TrackResourceAvailability.isPlayableAudioResource(managedAudio), isTrue);
      expect(TrackResourceAvailability.isPlayableAudioResource(playbackCacheAudio), isTrue);
      expect(TrackResourceAvailability.isPlayableAudioResource(localImportAudio), isTrue);
      expect(TrackResourceAvailability.isCachedAudioResource(managedAudio), isTrue);
      expect(TrackResourceAvailability.isCachedAudioResource(playbackCacheAudio), isTrue);
      expect(TrackResourceAvailability.isCachedAudioResource(localImportAudio), isFalse);
    });

    test('requires existing local files for download satisfaction', () async {
      final existingManagedAudio = _audioResource(
        await _writeFile(tempDirectory, 'downloaded.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.managedDownload,
      );
      final missingManagedAudio = _audioResource(
        '${tempDirectory.path}/missing.mp3',
        origin: TrackResourceOrigin.managedDownload,
      );
      final playbackCacheAudio = _audioResource(
        await _writeFile(tempDirectory, 'playback-cache.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.playbackCache,
      );

      expect(TrackResourceAvailability.isDownloadSatisfiedAudioResource(existingManagedAudio), isTrue);
      expect(TrackResourceAvailability.isDownloadSatisfiedAudioResource(missingManagedAudio), isFalse);
      expect(TrackResourceAvailability.isDownloadSatisfiedAudioResource(playbackCacheAudio), isFalse);
    });

    test('orders resource origins by ownership strength', () {
      expect(
        TrackResourceAvailability.originPriority(TrackResourceOrigin.localImport),
        greaterThan(TrackResourceAvailability.originPriority(TrackResourceOrigin.managedDownload)),
      );
      expect(
        TrackResourceAvailability.originPriority(TrackResourceOrigin.managedDownload),
        greaterThan(TrackResourceAvailability.originPriority(TrackResourceOrigin.playbackCache)),
      );
      expect(
        TrackResourceAvailability.originPriority(TrackResourceOrigin.playbackCache),
        greaterThan(TrackResourceAvailability.originPriority(TrackResourceOrigin.none)),
      );
      expect(
        TrackResourceAvailability.originPriority(TrackResourceOrigin.artworkCache),
        TrackResourceAvailability.originPriority(TrackResourceOrigin.none),
      );
    });

    test('keeps higher priority existing resources only while files exist', () async {
      final localImportAudio = _audioResource(
        await _writeFile(tempDirectory, 'local-import.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.localImport,
      );
      final managedAudio = _audioResource(
        await _writeFile(tempDirectory, 'managed.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.managedDownload,
      );
      final missingManagedAudio = _audioResource(
        '${tempDirectory.path}/missing-managed.mp3',
        origin: TrackResourceOrigin.managedDownload,
      );
      final playbackCacheAudio = _audioResource(
        await _writeFile(tempDirectory, 'playback-cache.mp3').then((file) => file.path),
        origin: TrackResourceOrigin.playbackCache,
      );

      expect(
        TrackResourceAvailability.shouldKeepExistingResource(
          localImportAudio,
          newOrigin: TrackResourceOrigin.managedDownload,
        ),
        isTrue,
      );
      expect(
        TrackResourceAvailability.shouldKeepExistingResource(
          managedAudio,
          newOrigin: TrackResourceOrigin.playbackCache,
        ),
        isTrue,
      );
      expect(
        TrackResourceAvailability.shouldKeepExistingResource(
          playbackCacheAudio,
          newOrigin: TrackResourceOrigin.managedDownload,
        ),
        isFalse,
      );
      expect(
        TrackResourceAvailability.shouldKeepExistingResource(
          missingManagedAudio,
          newOrigin: TrackResourceOrigin.playbackCache,
        ),
        isFalse,
      );
    });

    test('builds queue playback url and media type from indexed audio first', () async {
      final audioFile = await _writeFile(tempDirectory, 'song.mp3.uc!');
      final track = _track(remoteUrl: 'https://audio.test/song.mp3?auth=temp');
      final resources = TrackResourceBundle(
        audio: _audioResource(
          audioFile.path,
          origin: TrackResourceOrigin.playbackCache,
        ),
      );

      expect(TrackResourceAvailability.queuePlaybackUrl(track, resources), audioFile.path);
      expect(TrackResourceAvailability.queueMediaType(track, resources), MediaType.neteaseCache);
    });

    test('keeps remote playback urls out of queue items', () {
      final track = _track(remoteUrl: 'https://audio.test/song.mp3?auth=temp');
      const resources = TrackResourceBundle();

      expect(TrackResourceAvailability.queuePlaybackUrl(track, resources), isNull);
      expect(TrackResourceAvailability.queueMediaType(track, resources), MediaType.playlist);
    });

    test('keeps local source tracks local even without indexed audio', () {
      final track = _track(
        id: 'local:/Music/song.mp3',
        sourceType: SourceType.local,
        sourceId: '/Music/song.mp3',
      );
      const resources = TrackResourceBundle();

      expect(TrackResourceAvailability.queuePlaybackUrl(track, resources), isNull);
      expect(TrackResourceAvailability.queueMediaType(track, resources), MediaType.local);
    });
  });
}

Future<File> _writeFile(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes([1, 2, 3]);
  return file;
}

Track _track({
  String id = 'netease:1',
  SourceType sourceType = SourceType.netease,
  String sourceId = '1',
  String? remoteUrl,
}) {
  return Track(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    title: 'Track',
    remoteUrl: remoteUrl,
  );
}

LocalResourceEntry _audioResource(
  String path, {
  TrackResourceOrigin origin = TrackResourceOrigin.managedDownload,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: 'netease:1',
    kind: LocalResourceKind.audio,
    path: path,
    origin: origin,
    sizeBytes: 10,
    createdAt: now,
    lastAccessedAt: now,
  );
}
