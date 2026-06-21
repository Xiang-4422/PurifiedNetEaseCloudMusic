import 'dart:io';

import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
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

    test('removes temporary remote image file when download fails', () async {
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'local-image-cache-test-',
      );
      final failingDownloader = _FakeImageDownloader(failAfterWrite: true);
      final repository = LocalImageCacheRepository(
        downloader: failingDownloader.download,
        cacheDirectoryProvider: () async => cacheDirectory,
      );
      addTearDown(() async {
        if (cacheDirectory.existsSync()) {
          await cacheDirectory.delete(recursive: true);
        }
      });

      await expectLater(
        repository.resolveImagePath('https://example.com/failing.jpg'),
        throwsA(isA<StateError>()),
      );

      final failedTemporaryPath = failingDownloader.lastSavePath;
      expect(failedTemporaryPath, isNotNull);
      expect(File(failedTemporaryPath!).existsSync(), isFalse);
      expect(
        _temporaryDownloadFiles(cacheDirectory),
        isEmpty,
        reason: '失败的远程图片下载不能留下 .download 临时文件。',
      );

      final retryDownloader = _FakeImageDownloader();
      final retryRepository = LocalImageCacheRepository(
        downloader: retryDownloader.download,
        cacheDirectoryProvider: () async => cacheDirectory,
      );

      final retryPath = await retryRepository.resolveImagePath(
        'https://example.com/failing.jpg',
      );

      expect(File(retryPath).existsSync(), isTrue);
      expect(retryDownloader.downloadCount, 1);
    });
  });
}

class _FakeImageDownloader {
  _FakeImageDownloader({
    this.delay = const Duration(milliseconds: 20),
    this.failAfterWrite = false,
  });

  final Duration delay;
  final bool failAfterWrite;
  int downloadCount = 0;
  int activeDownloads = 0;
  int maxActiveDownloads = 0;
  String? lastSavePath;

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
      lastSavePath = savePath;
      final file = File(savePath);
      if (!file.parent.existsSync()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsBytes(<int>[1, 2, 3]);
      if (failAfterWrite) {
        throw StateError('image download interrupted');
      }
    } finally {
      activeDownloads--;
    }
  }
}

List<File> _temporaryDownloadFiles(Directory directory) {
  if (!directory.existsSync()) {
    return const [];
  }
  return directory.listSync(recursive: true).whereType<File>().where((file) => file.path.contains('.download')).toList();
}
