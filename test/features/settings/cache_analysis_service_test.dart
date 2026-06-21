import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/settings/cache_analysis_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheAnalysisService', () {
    late Directory tempDirectory;
    late Directory supportDirectory;
    late Directory temporaryDirectory;
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('cache-analysis-service-');
      supportDirectory = Directory('${tempDirectory.path}/support')..createSync(recursive: true);
      temporaryDirectory = Directory('${tempDirectory.path}/temporary')..createSync(recursive: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProviderChannel,
        (call) async {
          switch (call.method) {
            case 'getApplicationSupportDirectory':
              return supportDirectory.path;
            case 'getTemporaryDirectory':
              return temporaryDirectory.path;
          }
          return null;
        },
      );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProviderChannel,
        null,
      );
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('counts playback cache from resource indexes only', () async {
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: 'netease:1',
            kind: LocalResourceKind.audio,
            sizeBytes: 10,
            origin: TrackResourceOrigin.playbackCache,
          ),
          _resource(
            trackId: 'netease:1',
            kind: LocalResourceKind.lyrics,
            sizeBytes: 5,
            origin: TrackResourceOrigin.playbackCache,
          ),
          _resource(
            trackId: 'netease:1',
            kind: LocalResourceKind.artwork,
            sizeBytes: 100,
            origin: TrackResourceOrigin.managedDownload,
          ),
          _resource(
            trackId: 'netease:2',
            kind: LocalResourceKind.artwork,
            sizeBytes: 200,
            origin: TrackResourceOrigin.artworkCache,
          ),
        ],
      );
      final service = CacheAnalysisService(
        musicDataRepository: _ThrowingMusicDataRepository(),
        resourceIndexRepository: resourceIndexRepository,
      );

      final result = await service.analyze();
      final playback = result.categories.singleWhere(
        (category) => category.category == CacheCategory.playback,
      );

      expect(playback.sizeBytes, 15);
      expect(playback.fileCount, 2);
      expect(
        resourceIndexRepository.originRequests.where(
          (origins) => origins.length == 1 && origins.single == TrackResourceOrigin.playbackCache,
        ),
        isNotEmpty,
      );
    });

    test('counts only clearable artwork cache files', () async {
      final artworkDirectory = Directory('${supportDirectory.path}/zmusic/artwork-cache')..createSync(recursive: true);
      final clearableArtwork = await _writeFile(
        artworkDirectory,
        'clearable.jpg',
        size: 10,
      );
      final sharedArtwork = await _writeFile(
        artworkDirectory,
        'shared.jpg',
        size: 20,
      );
      await _writeFile(
        artworkDirectory,
        'retained.jpg',
        size: 30,
      );
      final orphanArtwork = await _writeFile(
        artworkDirectory,
        'orphan.jpg',
        size: 40,
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: 'netease:1',
            kind: LocalResourceKind.artwork,
            path: clearableArtwork.path,
            sizeBytes: 10,
            origin: TrackResourceOrigin.artworkCache,
          ),
          _resource(
            trackId: 'netease:2',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.path,
            sizeBytes: 20,
            origin: TrackResourceOrigin.artworkCache,
          ),
          _resource(
            trackId: 'netease:3',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.path,
            sizeBytes: 20,
            origin: TrackResourceOrigin.managedDownload,
          ),
          _resource(
            trackId: 'netease:4',
            kind: LocalResourceKind.artwork,
            path: '${artworkDirectory.path}/retained.jpg',
            sizeBytes: 30,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final service = CacheAnalysisService(
        musicDataRepository: _ThrowingMusicDataRepository(),
        resourceIndexRepository: resourceIndexRepository,
      );

      final result = await service.analyze();
      final artwork = result.categories.singleWhere(
        (category) => category.category == CacheCategory.artwork,
      );

      expect(artwork.sizeBytes, 50);
      expect(artwork.fileCount, 2);
      expect(orphanArtwork.existsSync(), isTrue);
    });

    test('normalizes retained legacy file uri paths while counting artwork cache', () async {
      final artworkDirectory = Directory('${supportDirectory.path}/zmusic/artwork-cache')..createSync(recursive: true);
      final sharedArtwork = await _writeFile(
        artworkDirectory,
        'shared with uri.jpg',
        size: 20,
      );
      final orphanArtwork = await _writeFile(
        artworkDirectory,
        'orphan.jpg',
        size: 40,
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: 'netease:1',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.path,
            sizeBytes: 20,
            origin: TrackResourceOrigin.artworkCache,
          ),
          _resource(
            trackId: 'netease:2',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
            sizeBytes: 20,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final service = CacheAnalysisService(
        musicDataRepository: _ThrowingMusicDataRepository(),
        resourceIndexRepository: resourceIndexRepository,
      );

      final result = await service.analyze();
      final artwork = result.categories.singleWhere(
        (category) => category.category == CacheCategory.artwork,
      );

      expect(artwork.sizeBytes, 40);
      expect(artwork.fileCount, 1);
      expect(orphanArtwork.existsSync(), isTrue);
    });

    test('clears artwork cache without deleting retained resource files', () async {
      final artworkDirectory = Directory('${supportDirectory.path}/zmusic/artwork-cache')..createSync(recursive: true);
      final clearableArtwork = await _writeFile(
        artworkDirectory,
        'clearable.jpg',
        size: 10,
      );
      final sharedArtwork = await _writeFile(
        artworkDirectory,
        'shared.jpg',
        size: 20,
      );
      final retainedArtwork = await _writeFile(
        artworkDirectory,
        'retained.jpg',
        size: 30,
      );
      final orphanArtwork = await _writeFile(
        artworkDirectory,
        'orphan.jpg',
        size: 40,
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: 'netease:1',
            kind: LocalResourceKind.artwork,
            path: clearableArtwork.path,
            sizeBytes: 10,
            origin: TrackResourceOrigin.artworkCache,
          ),
          _resource(
            trackId: 'netease:2',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.path,
            sizeBytes: 20,
            origin: TrackResourceOrigin.artworkCache,
          ),
          _resource(
            trackId: 'netease:3',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.path,
            sizeBytes: 20,
            origin: TrackResourceOrigin.managedDownload,
          ),
          _resource(
            trackId: 'netease:4',
            kind: LocalResourceKind.artwork,
            path: retainedArtwork.path,
            sizeBytes: 30,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final service = CacheAnalysisService(
        musicDataRepository: _ThrowingMusicDataRepository(),
        resourceIndexRepository: resourceIndexRepository,
      );

      await service.clear(CacheCategory.artwork);

      expect(clearableArtwork.existsSync(), isFalse);
      expect(orphanArtwork.existsSync(), isFalse);
      expect(sharedArtwork.existsSync(), isTrue);
      expect(retainedArtwork.existsSync(), isTrue);
      expect(
        resourceIndexRepository.resources.map((resource) => resource.origin).toSet(),
        {TrackResourceOrigin.managedDownload},
      );
    });

    test('normalizes retained legacy file uri paths while clearing artwork cache', () async {
      final artworkDirectory = Directory('${supportDirectory.path}/zmusic/artwork-cache')..createSync(recursive: true);
      final sharedArtwork = await _writeFile(
        artworkDirectory,
        'shared with uri.jpg',
        size: 20,
      );
      final orphanArtwork = await _writeFile(
        artworkDirectory,
        'orphan.jpg',
        size: 40,
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: 'netease:1',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.path,
            sizeBytes: 20,
            origin: TrackResourceOrigin.artworkCache,
          ),
          _resource(
            trackId: 'netease:2',
            kind: LocalResourceKind.artwork,
            path: sharedArtwork.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
            sizeBytes: 20,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final service = CacheAnalysisService(
        musicDataRepository: _ThrowingMusicDataRepository(),
        resourceIndexRepository: resourceIndexRepository,
      );

      await service.clear(CacheCategory.artwork);

      expect(sharedArtwork.existsSync(), isTrue);
      expect(orphanArtwork.existsSync(), isFalse);
      expect(
        resourceIndexRepository.resources.map((resource) => resource.origin).toSet(),
        {TrackResourceOrigin.managedDownload},
      );
    });
  });
}

Future<File> _writeFile(
  Directory directory,
  String name, {
  required int size,
}) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes(List<int>.filled(size, 1));
  return file;
}

LocalResourceEntry _resource({
  required String trackId,
  required LocalResourceKind kind,
  String? path,
  required int sizeBytes,
  required TrackResourceOrigin origin,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: kind,
    path: path ?? '/cache/$trackId-${kind.name}',
    origin: origin,
    sizeBytes: sizeBytes,
    createdAt: now,
    lastAccessedAt: now,
  );
}

class _ThrowingMusicDataRepository implements MusicDataRepository {
  @override
  Future<List<LocalSongEntry>> getLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) {
    throw StateError('Cache analysis should count playback resources directly.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  _FakeLocalResourceIndexRepository({required List<LocalResourceEntry> resources}) : resources = [...resources];

  final List<LocalResourceEntry> resources;
  final List<Set<TrackResourceOrigin>> originRequests = [];

  @override
  Future<List<LocalResourceEntry>> listResources({
    Set<TrackResourceOrigin>? origins,
    Set<LocalResourceKind>? kinds,
  }) async {
    if (origins != null) {
      originRequests.add(origins);
    }
    return resources
        .where(
          (resource) => (origins == null || origins.isEmpty || origins.contains(resource.origin)) && (kinds == null || kinds.isEmpty || kinds.contains(resource.kind)),
        )
        .toList();
  }

  @override
  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin) async {
    resources.removeWhere((resource) => resource.origin == origin);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
