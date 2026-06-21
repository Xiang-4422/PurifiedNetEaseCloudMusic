import 'package:bujuan/data/app_storage/app_cache_keys.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthStateStore', () {
    test('reads login flag and session marker through key-value boundary', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final store = AuthStateStore(keyValueStore: keyValueStore);

      expect(store.hasCachedSession, isFalse);

      await store.saveLoginFlag(true);
      keyValueStore.values[userInfoSp] = '{"userId":"1"}';

      expect(store.hasCachedSession, isTrue);
      expect(keyValueStore.values[isLoginSP], isTrue);
    });

    test('requires both login flag and non-empty session payload', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final store = AuthStateStore(keyValueStore: keyValueStore);

      keyValueStore.values[userInfoSp] = '{"userId":"1"}';
      expect(store.hasCachedSession, isFalse);

      await store.saveLoginFlag(true);
      keyValueStore.values[userInfoSp] = '';
      expect(store.hasCachedSession, isFalse);
    });

    test('rejects corrupt or anonymous cached session payloads', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final store = AuthStateStore(keyValueStore: keyValueStore);
      await store.saveLoginFlag(true);

      keyValueStore.values[userInfoSp] = 'not-json';
      expect(store.hasCachedSession, isFalse);

      keyValueStore.values[userInfoSp] = '[]';
      expect(store.hasCachedSession, isFalse);

      keyValueStore.values[userInfoSp] = '{"nickname":"User"}';
      expect(store.hasCachedSession, isFalse);

      keyValueStore.values[userInfoSp] = 1;
      expect(store.hasCachedSession, isFalse);
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
