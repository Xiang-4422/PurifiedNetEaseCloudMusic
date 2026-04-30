import 'dart:io';

import 'package:bujuan/core/storage/local_image_cache_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalImageCacheRepository', () {
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
  });
}

class _FakeImageDownloader {
  int downloadCount = 0;

  Future<void> download(
    String urlPath,
    String savePath,
    Options options,
  ) async {
    downloadCount++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final file = File(savePath);
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(<int>[1, 2, 3]);
  }
}
