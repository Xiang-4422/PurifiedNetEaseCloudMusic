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
      keyValueStore.values[userSessionKey] = '{"userId":"1"}';

      expect(store.hasCachedSession, isTrue);
      expect(keyValueStore.values[loginFlagKey], isTrue);
    });

    test('requires both login flag and non-empty session payload', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final store = AuthStateStore(keyValueStore: keyValueStore);

      keyValueStore.values[userSessionKey] = '{"userId":"1"}';
      expect(store.hasCachedSession, isFalse);

      await store.saveLoginFlag(true);
      keyValueStore.values[userSessionKey] = '';
      expect(store.hasCachedSession, isFalse);
    });

    test('rejects corrupt or anonymous cached session payloads', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final store = AuthStateStore(keyValueStore: keyValueStore);
      await store.saveLoginFlag(true);

      keyValueStore.values[userSessionKey] = 'not-json';
      expect(store.hasCachedSession, isFalse);

      keyValueStore.values[userSessionKey] = '[]';
      expect(store.hasCachedSession, isFalse);

      keyValueStore.values[userSessionKey] = '{"nickname":"User"}';
      expect(store.hasCachedSession, isFalse);

      keyValueStore.values[userSessionKey] = 1;
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
