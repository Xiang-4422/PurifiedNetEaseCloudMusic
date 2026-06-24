import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/download/application/download_resource_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadResourceWriter', () {
    test('saves supplemental resources only after audio becomes available', () async {
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        indexedAudioOrigin: TrackResourceOrigin.managedDownload,
      );
      final writer = DownloadResourceWriter(
        resourceIndexRepository: resourceIndexRepository,
      );

      final saved = await writer.saveManagedDownloadResources(
        '1',
        localPath: '/tmp/audio.mp3',
        artworkPath: '/tmp/artwork.jpg',
        lyricsPath: '/tmp/lyrics.lrc',
      );

      expect(saved, isTrue);
      expect(resourceIndexRepository.savedAudioPaths, ['/tmp/audio.mp3']);
      expect(resourceIndexRepository.savedArtworkPaths, ['/tmp/artwork.jpg']);
      expect(resourceIndexRepository.savedLyricsPaths, ['/tmp/lyrics.lrc']);
    });

    test('does not save supplemental resources when audio is unavailable', () async {
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
      expect(resourceIndexRepository.savedAudioPaths, ['/tmp/missing.mp3']);
      expect(resourceIndexRepository.savedArtworkPaths, isEmpty);
      expect(resourceIndexRepository.savedLyricsPaths, isEmpty);
    });

    test('does not promote local import resources to managed download', () async {
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        indexedAudioOrigin: TrackResourceOrigin.localImport,
        indexedAudioPath: '/tmp/local-import.mp3',
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
            path: '/tmp/local-import.mp3',
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
            path: '/tmp/cache-audio.mp3',
            origin: TrackResourceOrigin.playbackCache,
          ),
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

      expect(promoted, isTrue);
      expect(resourceIndexRepository.savedAudioPaths, ['/tmp/cache-audio.mp3']);
      expect(resourceIndexRepository.savedAudioOrigins, [
        TrackResourceOrigin.managedDownload,
      ]);
      expect(resourceIndexRepository.savedArtworkPaths, ['/tmp/cache-artwork.jpg']);
      expect(resourceIndexRepository.savedArtworkOrigins, [
        TrackResourceOrigin.managedDownload,
      ]);
      expect(resourceIndexRepository.savedLyricsPaths, ['/tmp/cache-lyrics.lrc']);
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

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  _FakeLocalResourceIndexRepository({
    this.indexedAudioOrigin,
    this.indexedAudioPath,
    this.savedAudioAvailable = false,
  });

  final TrackResourceOrigin? indexedAudioOrigin;
  final String? indexedAudioPath;
  final bool savedAudioAvailable;
  final List<String> savedAudioPaths = [];
  final List<TrackResourceOrigin> savedAudioOrigins = [];
  final List<String> savedArtworkPaths = [];
  final List<TrackResourceOrigin> savedArtworkOrigins = [];
  final List<String> savedLyricsPaths = [];
  final List<TrackResourceOrigin> savedLyricsOrigins = [];

  @override
  Future<void> saveAudioResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
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
    savedArtworkPaths.add(path);
    savedArtworkOrigins.add(origin);
  }

  @override
  Future<void> saveLyricsResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
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
