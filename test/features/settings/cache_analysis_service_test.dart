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
      expect(resourceIndexRepository.requestedOrigins, {
        TrackResourceOrigin.playbackCache,
      });
    });
  });
}

LocalResourceEntry _resource({
  required String trackId,
  required LocalResourceKind kind,
  required int sizeBytes,
  required TrackResourceOrigin origin,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: kind,
    path: '/cache/$trackId-${kind.name}',
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
  _FakeLocalResourceIndexRepository({required this.resources});

  final List<LocalResourceEntry> resources;
  Set<TrackResourceOrigin>? requestedOrigins;

  @override
  Future<List<LocalResourceEntry>> listResources({
    Set<TrackResourceOrigin>? origins,
    Set<LocalResourceKind>? kinds,
  }) async {
    requestedOrigins = origins;
    return resources
        .where(
          (resource) => (origins == null || origins.isEmpty || origins.contains(resource.origin)) && (kinds == null || kinds.isEmpty || kinds.contains(resource.kind)),
        )
        .toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
