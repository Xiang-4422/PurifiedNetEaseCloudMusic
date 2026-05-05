import 'dart:io';

import 'package:bujuan/core/storage/local_image_cache_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalImageCacheRepository', () {
    test('returns local paths synchronously', () async {
      final repository = LocalImageCacheRepository();

      expect(
        repository.peekResolvedImagePath('/tmp/cover.jpg?param=1'),
        '/tmp/cover.jpg',
      );
      expect(
        await repository.resolveImagePath('/tmp/cover.jpg?param=1'),
        '/tmp/cover.jpg',
      );
    });

    test('coalesces same url downloads across repository instances', () async {
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'local-image-cache-test-',
      );
      final downloader = _FakeImageDownloader();
      final firstRepository = LocalImageCacheRepository(
        downloader: downloader.download,
        cacheDirectoryProvider: () async => cacheDirectory,
      );
      final secondRepository = LocalImageCacheRepository(
        downloader: downloader.download,
        cacheDirectoryProvider: () async => cacheDirectory,
      );
      addTearDown(() async {
        if (cacheDirectory.existsSync()) {
          await cacheDirectory.delete(recursive: true);
        }
      });

      final results = await Future.wait([
        firstRepository.resolveImagePath('https://example.com/a.jpg'),
        secondRepository.resolveImagePath('https://example.com/a.jpg'),
      ]);

      expect(results[0], results[1]);
      expect(File(results[0]).existsSync(), isTrue);
      expect(downloader.downloadCount, 1);
    });

    test('reuses resolved remote path after download completes', () async {
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'local-image-cache-test-',
      );
      final downloader = _FakeImageDownloader();
      final firstRepository = LocalImageCacheRepository(
        downloader: downloader.download,
        cacheDirectoryProvider: () async => cacheDirectory,
      );
      final secondRepository = LocalImageCacheRepository(
        downloader: downloader.download,
        cacheDirectoryProvider: () async => cacheDirectory,
      );
      addTearDown(() async {
        if (cacheDirectory.existsSync()) {
          await cacheDirectory.delete(recursive: true);
        }
      });

      final firstPath = await firstRepository.resolveImagePath(
        'https://example.com/reuse.jpg',
      );
      final peekedPath = secondRepository.peekResolvedImagePath(
        'https://example.com/reuse.jpg',
      );
      final secondPath = await secondRepository.resolveImagePath(
        'https://example.com/reuse.jpg',
      );

      expect(peekedPath, firstPath);
      expect(secondPath, firstPath);
      expect(downloader.downloadCount, 1);
    });

    test('limits concurrent remote downloads', () async {
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'local-image-cache-test-',
      );
      final downloader = _FakeImageDownloader(
        delay: const Duration(milliseconds: 30),
      );
      final repository = LocalImageCacheRepository(
        downloader: downloader.download,
        cacheDirectoryProvider: () async => cacheDirectory,
      );
      addTearDown(() async {
        if (cacheDirectory.existsSync()) {
          await cacheDirectory.delete(recursive: true);
        }
      });

      await Future.wait(
        List.generate(
          9,
          (index) => repository.resolveImagePath(
            'https://example.com/concurrent-$index.jpg',
          ),
        ),
      );

      expect(downloader.downloadCount, 9);
      expect(downloader.maxActiveDownloads, lessThanOrEqualTo(4));
    });
  });
}

class _FakeImageDownloader {
  _FakeImageDownloader({
    this.delay = const Duration(milliseconds: 20),
  });

  final Duration delay;
  int downloadCount = 0;
  int activeDownloads = 0;
  int maxActiveDownloads = 0;

  Future<void> download(
    String urlPath,
    String savePath,
    Options options,
  ) async {
    downloadCount++;
    activeDownloads++;
    if (activeDownloads > maxActiveDownloads) {
      maxActiveDownloads = activeDownloads;
    }
    try {
      await Future<void>.delayed(delay);
      final file = File(savePath);
      if (!file.parent.existsSync()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsBytes(<int>[1, 2, 3]);
    } finally {
      activeDownloads--;
    }
  }
}
