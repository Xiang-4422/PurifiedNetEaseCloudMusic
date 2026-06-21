import 'dart:io';

import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageColorService', () {
    test('treats uppercase http image url as remote fallback color', () async {
      expect(
        await ImageColorService.dominantColor('HTTPS://img.test/cover.jpg'),
        Colors.black,
      );
      expect(
        await ImageColorService.dominantColor(
          'HTTPS://img.test/cover.jpg',
          getLightColor: true,
        ),
        Colors.white,
      );
      expect(
        ImageColorService.peekCachedColor('HTTPS://img.test/cover.jpg'),
        isNull,
      );
    });

    test('falls back when local image is unavailable', () async {
      final cacheDirectory = await Directory.systemTemp.createTemp(
        'image-color-service-test-',
      );
      addTearDown(() async {
        if (cacheDirectory.existsSync()) {
          await cacheDirectory.delete(recursive: true);
        }
      });
      final missingImagePath = '${cacheDirectory.path}/missing.jpg';

      expect(ImageColorService.peekCachedColor(missingImagePath), isNull);
      expect(
        await ImageColorService.dominantColor(missingImagePath),
        Colors.black,
      );
      expect(
        await ImageColorService.dominantColor(
          missingImagePath,
          getLightColor: true,
        ),
        Colors.white,
      );
    });
  });

  group('ImageColorMemoryCache', () {
    test('limits entries and evicts least recently used colors', () {
      final cache = ImageColorMemoryCache(maxEntries: 3);

      cache.remember('a', const Color(0xff000001));
      cache.remember('b', const Color(0xff000002));
      cache.remember('c', const Color(0xff000003));
      expect(cache.read('a'), const Color(0xff000001));
      cache.remember('d', const Color(0xff000004));

      expect(cache.length, 3);
      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('b'), isFalse);
      expect(cache.containsKey('c'), isTrue);
      expect(cache.containsKey('d'), isTrue);
    });

    test('updates existing color without growing cache', () {
      final cache = ImageColorMemoryCache(maxEntries: 2);

      cache.remember('a', const Color(0xff000001));
      cache.remember('b', const Color(0xff000002));
      cache.remember('a', const Color(0xff000003));
      cache.remember('c', const Color(0xff000004));

      expect(cache.length, 2);
      expect(cache.read('a'), const Color(0xff000003));
      expect(cache.containsKey('b'), isFalse);
      expect(cache.containsKey('c'), isTrue);
    });
  });
}
