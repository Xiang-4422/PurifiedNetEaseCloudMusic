import 'package:bujuan/data/app_storage/app_cache_keys.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/data/app_storage/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPreferences', () {
    test('reads default values through the key-value boundary', () {
      final keyValueStore = _MemoryKeyValueStore();
      final preferences = AppPreferences(keyValueStore: keyValueStore);

      expect(preferences.isGradientBackgroundEnabled, isTrue);
      expect(preferences.isRoundAlbumEnabled, isFalse);
      expect(preferences.isHighSoundQualityEnabled, isFalse);
    });

    test('writes preference values through the injected store', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final preferences = AppPreferences(keyValueStore: keyValueStore);

      await preferences.saveGradientBackgroundEnabled(false);
      await preferences.saveRoundAlbumEnabled(true);
      await preferences.saveHighSoundQualityEnabled(true);

      expect(keyValueStore.values[gradientBackgroundKey], isFalse);
      expect(keyValueStore.values[roundAlbumKey], isTrue);
      expect(keyValueStore.values[highSoundQualityKey], isTrue);
      expect(preferences.isGradientBackgroundEnabled, isFalse);
      expect(preferences.isRoundAlbumEnabled, isTrue);
      expect(preferences.isHighSoundQualityEnabled, isTrue);
    });
  });
}

class _MemoryKeyValueStore implements AppKeyValueStore {
  final Map<String, Object?> values = <String, Object?>{};

  @override
  Object? get(String key, {Object? defaultValue}) {
    return values.containsKey(key) ? values[key] : defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}
