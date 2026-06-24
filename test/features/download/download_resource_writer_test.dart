import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/download/application/download_resource_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadResourceWriter', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('download-resource-writer-');
    });

    tearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('saves supplemental resources only after audio becomes available', () async {
      final audioPath = await _writeFile(tempDirectory, 'audio.mp3');
      final artworkPath = await _writeFile(tempDirectory, 'artwork.jpg');
      final lyricsPath = await _writeFile(tempDirectory, 'lyrics.lrc');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        indexedAudioOrigin: TrackResourceOrigin.managedDownload,
      );
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final saved = await writer.saveManagedDownloadResources(
        '1',
        localPath: audioPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      );

      expect(saved, isTrue);
      expect(resourceIndexRepository.savedAudioTrackIds, ['1']);
      expect(resourceIndexRepository.savedAudioPaths, [audioPath]);
      expect(resourceIndexRepository.savedArtworkTrackIds, ['1']);
      expect(resourceIndexRepository.savedArtworkPaths, [artworkPath]);
      expect(resourceIndexRepository.savedLyricsTrackIds, ['1']);
      expect(resourceIndexRepository.savedLyricsPaths, [lyricsPath]);
    });

    test('does not save any resource index when audio is unavailable', () async {
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final saved = await writer.saveManagedDownloadResources(
        '1',
        localPath: '/tmp/missing.mp3',
        artworkPath: '/tmp/artwork.jpg',
        lyricsPath: '/tmp/lyrics.lrc',
      );

      expect(saved, isFalse);
      expect(resourceIndexRepository.savedAudioPaths, isEmpty);
      expect(resourceIndexRepository.savedArtworkPaths, isEmpty);
      expect(resourceIndexRepository.savedLyricsPaths, isEmpty);
    });

    test('does not write a missing indexed audio path before availability check', () async {
      final missingAudioPath = '${tempDirectory.path}/missing-indexed.mp3';
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        indexedAudioOrigin: TrackResourceOrigin.managedDownload,
        indexedAudioPath: missingAudioPath,
      );
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final saved = await writer.saveManagedDownloadResources(
        '1',
        localPath: missingAudioPath,
        artworkPath: '${tempDirectory.path}/artwork.jpg',
        lyricsPath: '${tempDirectory.path}/lyrics.lrc',
      );

      expect(saved, isFalse);
      expect(resourceIndexRepository.savedAudioPaths, isEmpty);
      expect(resourceIndexRepository.savedArtworkPaths, isEmpty);
      expect(resourceIndexRepository.savedLyricsPaths, isEmpty);
    });

    test('normalizes track ids and local file uris before saving resources', () async {
      final audioPath = await _writeFile(tempDirectory, 'uri-audio.mp3');
      final artworkPath = await _writeFile(tempDirectory, 'uri-artwork.jpg');
      final lyricsPath = await _writeFile(tempDirectory, 'uri-lyrics.lrc');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        savedAudioAvailable: true,
      );
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final saved = await writer.savePlaybackCacheResources(
        ' 1 ',
        audioPath: ' ${Uri.file(audioPath)} ',
        artworkPath: ' ${Uri.file(artworkPath)} ',
        lyricsPath: ' ${Uri.file(lyricsPath)} ',
      );

      expect(saved, isTrue);
      expect(resourceIndexRepository.savedAudioTrackIds, ['1']);
      expect(resourceIndexRepository.savedAudioPaths, [audioPath]);
      expect(resourceIndexRepository.savedArtworkTrackIds, ['1']);
      expect(resourceIndexRepository.savedArtworkPaths, [artworkPath]);
      expect(resourceIndexRepository.savedLyricsTrackIds, ['1']);
      expect(resourceIndexRepository.savedLyricsPaths, [lyricsPath]);
    });

    test('rejects blank track ids before saving resource indexes', () async {
      final audioPath = await _writeFile(tempDirectory, 'blank-track.mp3');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        savedAudioAvailable: true,
      );
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final saved = await writer.saveManagedDownloadResources(
        '   ',
        localPath: audioPath,
      );

      expect(saved, isFalse);
      expect(resourceIndexRepository.savedAudioPaths, isEmpty);
    });

    test('does not promote local import resources to managed download', () async {
      final localImportPath = await _writeFile(tempDirectory, 'local-import.mp3');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        indexedAudioOrigin: TrackResourceOrigin.localImport,
        indexedAudioPath: localImportPath,
      );
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final promoted = await writer.promoteResourcesToManagedDownload(
        '1',
        TrackResourceBundle(
          audio: LocalResourceEntry(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: localImportPath,
            origin: TrackResourceOrigin.localImport,
            sizeBytes: 1,
            createdAt: DateTime(2026),
            lastAccessedAt: DateTime(2026),
          ),
        ),
      );

      expect(promoted, isTrue);
      expect(resourceIndexRepository.savedAudioPaths, isEmpty);
      expect(resourceIndexRepository.savedAudioOrigins, isEmpty);
    });

    test('promotes playback cache resources to managed download facts', () async {
      final audioPath = await _writeFile(tempDirectory, 'cache-audio.mp3');
      final artworkPath = await _writeFile(tempDirectory, 'cache-artwork.jpg');
      final lyricsPath = await _writeFile(tempDirectory, 'cache-lyrics.lrc');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        savedAudioAvailable: true,
      );
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final promoted = await writer.promoteResourcesToManagedDownload(
        '1',
        TrackResourceBundle(
          audio: _resource(
            kind: LocalResourceKind.audio,
            path: audioPath,
            origin: TrackResourceOrigin.playbackCache,
          ),
          artwork: _resource(
            kind: LocalResourceKind.artwork,
            path: artworkPath,
            origin: TrackResourceOrigin.playbackCache,
          ),
          lyrics: _resource(
            kind: LocalResourceKind.lyrics,
            path: lyricsPath,
            origin: TrackResourceOrigin.playbackCache,
          ),
        ),
      );

      expect(promoted, isTrue);
      expect(resourceIndexRepository.savedAudioPaths, [audioPath]);
      expect(resourceIndexRepository.savedAudioOrigins, [
        TrackResourceOrigin.managedDownload,
      ]);
      expect(resourceIndexRepository.savedArtworkPaths, [artworkPath]);
      expect(resourceIndexRepository.savedArtworkOrigins, [
        TrackResourceOrigin.managedDownload,
      ]);
      expect(resourceIndexRepository.savedLyricsPaths, [lyricsPath]);
      expect(resourceIndexRepository.savedLyricsOrigins, [
        TrackResourceOrigin.managedDownload,
      ]);
    });

    test('does not promote supplemental resources when audio is unavailable', () async {
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final promoted = await writer.promoteResourcesToManagedDownload(
        '1',
        TrackResourceBundle(
          artwork: _resource(
            kind: LocalResourceKind.artwork,
            path: '/tmp/cache-artwork.jpg',
            origin: TrackResourceOrigin.playbackCache,
          ),
          lyrics: _resource(
            kind: LocalResourceKind.lyrics,
            path: '/tmp/cache-lyrics.lrc',
            origin: TrackResourceOrigin.playbackCache,
          ),
        ),
      );

      expect(promoted, isFalse);
      expect(resourceIndexRepository.savedAudioPaths, isEmpty);
      expect(resourceIndexRepository.savedArtworkPaths, isEmpty);
      expect(resourceIndexRepository.savedLyricsPaths, isEmpty);
    });
  });
}

Future<String> _writeFile(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes([1, 2, 3]);
  return file.path;
}

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  _FakeLocalResourceIndexRepository({
    this.indexedAudioOrigin,
    this.indexedAudioPath,
    this.savedAudioAvailable = false,
  });

  final TrackResourceOrigin? indexedAudioOrigin;
  final String? indexedAudioPath;
  final bool savedAudioAvailable;
  final List<String> savedAudioTrackIds = [];
  final List<String> savedAudioPaths = [];
  final List<TrackResourceOrigin> savedAudioOrigins = [];
  final List<String> savedArtworkTrackIds = [];
  final List<String> savedArtworkPaths = [];
  final List<TrackResourceOrigin> savedArtworkOrigins = [];
  final List<String> savedLyricsTrackIds = [];
  final List<String> savedLyricsPaths = [];
  final List<TrackResourceOrigin> savedLyricsOrigins = [];

  @override
  Future<void> saveAudioResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    savedAudioTrackIds.add(trackId);
    savedAudioPaths.add(path);
    savedAudioOrigins.add(origin);
  }

  @override
  Future<LocalResourceEntry?> getPrimaryAudioResource(String trackId) async {
    final origin = indexedAudioOrigin ?? (savedAudioAvailable && savedAudioOrigins.isNotEmpty ? savedAudioOrigins.last : null);
    if (origin == null) {
      return null;
    }
    final path = indexedAudioPath ?? (savedAudioPaths.isEmpty ? null : savedAudioPaths.last);
    if (path == null) {
      return null;
    }
    return LocalResourceEntry(
      trackId: trackId,
      kind: LocalResourceKind.audio,
      path: path,
      origin: origin,
      sizeBytes: 1,
      createdAt: DateTime(2026),
      lastAccessedAt: DateTime(2026),
    );
  }

  @override
  Future<void> saveArtworkResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    savedArtworkTrackIds.add(trackId);
    savedArtworkPaths.add(path);
    savedArtworkOrigins.add(origin);
  }

  @override
  Future<void> saveLyricsResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    savedLyricsTrackIds.add(trackId);
    savedLyricsPaths.add(path);
    savedLyricsOrigins.add(origin);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalResourceEntry _resource({
  required LocalResourceKind kind,
  required String path,
  required TrackResourceOrigin origin,
}) {
  return LocalResourceEntry(
    trackId: '1',
    kind: kind,
    path: path,
    origin: origin,
    sizeBytes: 1,
    createdAt: DateTime(2026),
    lastAccessedAt: DateTime(2026),
  );
}
