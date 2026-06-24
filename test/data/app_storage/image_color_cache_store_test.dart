import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/data/app_storage/image_color_cache_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageColorCacheStore', () {
    test('stores and loads colors through injected key-value store', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final cacheStore = ImageColorCacheStore(keyValueStore: keyValueStore);

      await cacheStore.save(
        imageUrl: '/cache/art.jpg',
        getLightColor: false,
        argb32: 0xff112233,
      );

      expect(
        cacheStore.load(
          imageUrl: '/cache/art.jpg',
          getLightColor: false,
        ),
        0xff112233,
      );
      expect(keyValueStore.keys.any((key) => key.startsWith('IMAGE_COLOR_DARK_')), isTrue);
    });

    test('clears both light and dark color entries for an image', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final cacheStore = ImageColorCacheStore(keyValueStore: keyValueStore);

      await cacheStore.save(
        imageUrl: '/cache/art.jpg',
        getLightColor: false,
        argb32: 0xff112233,
      );
      await cacheStore.save(
        imageUrl: '/cache/art.jpg',
        getLightColor: true,
        argb32: 0xffffffff,
      );

      await cacheStore.clear('/cache/art.jpg');

      expect(
        cacheStore.load(
          imageUrl: '/cache/art.jpg',
          getLightColor: false,
        ),
        isNull,
      );
      expect(
        cacheStore.load(
          imageUrl: '/cache/art.jpg',
          getLightColor: true,
        ),
        isNull,
      );
      expect(
        keyValueStore.get('IMAGE_COLOR_CACHE_LAST_ACCESS'),
        isNull,
      );
    });

    test('prunes old color entries through the key-value boundary', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final cacheStore = ImageColorCacheStore(keyValueStore: keyValueStore);

      for (var index = 0; index < 305; index += 1) {
        await cacheStore.save(
          imageUrl: '/cache/art_$index.jpg',
          getLightColor: false,
          argb32: 0xff000000 + index,
        );
      }

      final colorKeyCount = keyValueStore.keys.where((key) => key.startsWith('IMAGE_COLOR_DARK_')).length;
      final accessMap = Map<String, Object?>.from(keyValueStore.get('IMAGE_COLOR_CACHE_LAST_ACCESS')! as Map);

      expect(colorKeyCount, lessThanOrEqualTo(300));
      expect(accessMap.length, lessThanOrEqualTo(300));
      expect(accessMap.containsKey('/cache/art_0.jpg'), isFalse);
    });

    test('refreshes access index when a cached color is loaded', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final cacheStore = ImageColorCacheStore(keyValueStore: keyValueStore);

      await cacheStore.save(
        imageUrl: '/cache/freshly-read.jpg',
        getLightColor: false,
        argb32: 0xff111111,
      );
      await cacheStore.save(
        imageUrl: '/cache/stale.jpg',
        getLightColor: false,
        argb32: 0xff222222,
      );
      await keyValueStore.put('IMAGE_COLOR_CACHE_LAST_ACCESS', {
        '/cache/freshly-read.jpg': 1,
        '/cache/stale.jpg': 2,
      });

      expect(
        cacheStore.load(
          imageUrl: '/cache/freshly-read.jpg',
          getLightColor: false,
        ),
        0xff111111,
      );
      await Future<void>.delayed(Duration.zero);

      for (var index = 0; index < 299; index += 1) {
        await cacheStore.save(
          imageUrl: '/cache/new_$index.jpg',
          getLightColor: false,
          argb32: 0xff000000 + index,
        );
      }

      final accessMap = Map<String, Object?>.from(
        keyValueStore.get('IMAGE_COLOR_CACHE_LAST_ACCESS')! as Map,
      );

      expect(accessMap.containsKey('/cache/freshly-read.jpg'), isTrue);
      expect(accessMap.containsKey('/cache/stale.jpg'), isFalse);
      expect(
        cacheStore.load(
          imageUrl: '/cache/freshly-read.jpg',
          getLightColor: false,
        ),
        0xff111111,
      );
      expect(
        cacheStore.load(
          imageUrl: '/cache/stale.jpg',
          getLightColor: false,
        ),
        isNull,
      );
    });
  });
}

class _MemoryKeyValueStore implements AppKeyValueStore {
  final Map<String, Object?> _values = <String, Object?>{};

  Iterable<String> get keys => _values.keys;

  @override
  Object? get(String key, {Object? defaultValue}) {
    return _values.containsKey(key) ? _values[key] : defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
