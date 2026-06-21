import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_artwork_cache_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalArtworkCacheRepository', () {
    test('removes temporary artwork file when download fails', () async {
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'local-artwork-cache-test-',
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final failingDownloader = _FakeArtworkDownloader(failAfterWrite: true);
      final repository = LocalArtworkCacheRepository(
        resourceIndexRepository: resourceIndexRepository,
        artworkDirectoryProvider: () async => cacheDirectory,
        downloader: failingDownloader.download,
      );
      addTearDown(() async {
        if (cacheDirectory.existsSync()) {
          await cacheDirectory.delete(recursive: true);
        }
      });

      final track = _track(
        id: 'netease:failed/artwork',
        artworkUrl: 'https://example.com/cover.jpg',
      );

      final result = await repository.cacheSingleTrackArtwork(track);

      expect(result, same(track));
      expect(failingDownloader.downloadCount, 1);
      expect(resourceIndexRepository.saveCount, 0);
      expect(
        _temporaryDownloadFiles(cacheDirectory),
        isEmpty,
        reason: '失败的封面下载不能留下 .download 临时文件。',
      );

      final retryDownloader = _FakeArtworkDownloader();
      final retryRepository = LocalArtworkCacheRepository(
        resourceIndexRepository: resourceIndexRepository,
        artworkDirectoryProvider: () async => cacheDirectory,
        downloader: retryDownloader.download,
      );

      await retryRepository.cacheSingleTrackArtwork(track);

      final savedResource = resourceIndexRepository.savedArtworkResource;
      expect(retryDownloader.downloadCount, 1);
      expect(savedResource, isNotNull);
      expect(savedResource!.trackId, track.id);
      expect(savedResource.origin, TrackResourceOrigin.artworkCache);
      expect(File(savedResource.path).existsSync(), isTrue);
    });

    test('caches artwork with uppercase http scheme', () async {
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'local-artwork-cache-test-',
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final downloader = _FakeArtworkDownloader();
      final repository = LocalArtworkCacheRepository(
        resourceIndexRepository: resourceIndexRepository,
        artworkDirectoryProvider: () async => cacheDirectory,
        downloader: downloader.download,
      );
      addTearDown(() async {
        if (cacheDirectory.existsSync()) {
          await cacheDirectory.delete(recursive: true);
        }
      });

      final track = _track(
        id: 'netease:uppercase/artwork',
        artworkUrl: 'HTTPS://example.com/cover.jpg',
      );

      await repository.cacheSingleTrackArtwork(track);

      final savedResource = resourceIndexRepository.savedArtworkResource;
      expect(downloader.downloadCount, 1);
      expect(savedResource, isNotNull);
      expect(savedResource!.trackId, track.id);
      expect(File(savedResource.path).existsSync(), isTrue);
    });
  });
}

Track _track({
  required String id,
  required String artworkUrl,
}) {
  return Track(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id,
    title: 'Test Track',
    artworkUrl: artworkUrl,
  );
}

List<File> _temporaryDownloadFiles(Directory directory) {
  if (!directory.existsSync()) {
    return const [];
  }
  return directory.listSync(recursive: true).whereType<File>().where((file) => file.path.contains('.download')).toList();
}

class _FakeArtworkDownloader {
  _FakeArtworkDownloader({this.failAfterWrite = false});

  final bool failAfterWrite;
  int downloadCount = 0;

  Future<void> download(
    String artworkUrl,
    String savePath,
    Options options,
  ) async {
    downloadCount++;
    final file = File(savePath);
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(<int>[1, 2, 3]);
    if (failAfterWrite) {
      throw StateError('artwork download interrupted');
    }
  }
}

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  LocalResourceEntry? savedArtworkResource;
  int saveCount = 0;

  @override
  Future<LocalResourceEntry?> getArtworkResource(String trackId) async {
    final resource = savedArtworkResource;
    if (resource == null || resource.trackId != trackId) {
      return null;
    }
    return resource;
  }

  @override
  Future<void> saveArtworkResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    saveCount++;
    final now = DateTime(2026);
    savedArtworkResource = LocalResourceEntry(
      trackId: trackId,
      kind: LocalResourceKind.artwork,
      path: path,
      origin: origin,
      sizeBytes: await File(path).length(),
      createdAt: now,
      lastAccessedAt: now,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
