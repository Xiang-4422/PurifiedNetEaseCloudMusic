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
  });
}

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  _FakeLocalResourceIndexRepository({
    this.indexedAudioOrigin,
    this.indexedAudioPath,
  });

  final TrackResourceOrigin? indexedAudioOrigin;
  final String? indexedAudioPath;
  final List<String> savedAudioPaths = [];
  final List<TrackResourceOrigin> savedAudioOrigins = [];
  final List<String> savedArtworkPaths = [];
  final List<String> savedLyricsPaths = [];

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
    final origin = indexedAudioOrigin;
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
  }

  @override
  Future<void> saveLyricsResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    savedLyricsPaths.add(path);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
