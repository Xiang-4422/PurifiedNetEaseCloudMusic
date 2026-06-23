import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_cache_keys.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSessionStore', () {
    test('saves and loads session through key-value boundary', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final store = UserSessionStore(keyValueStore: keyValueStore);

      await store.saveSession(
        const UserSessionData(
          userId: '1',
          nickname: 'User',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      );

      final loaded = store.loadSession();

      expect(loaded?.userId, '1');
      expect(loaded?.nickname, 'User');
      expect(keyValueStore.values[userSessionSp], isA<String>());
    });

    test('clears session payload through key-value boundary', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final store = UserSessionStore(keyValueStore: keyValueStore);
      await store.saveSession(
        const UserSessionData(
          userId: '1',
          nickname: 'User',
          avatarUrl: '',
        ),
      );

      await store.clearSession();

      expect(store.loadSession(), isNull);
      expect(keyValueStore.values.containsKey(userSessionSp), isFalse);
    });

    test('ignores corrupt or anonymous cached session payloads', () {
      final keyValueStore = _MemoryKeyValueStore();
      final store = UserSessionStore(keyValueStore: keyValueStore);

      keyValueStore.values[userSessionSp] = 'not-json';
      expect(store.loadSession(), isNull);

      keyValueStore.values[userSessionSp] = '[]';
      expect(store.loadSession(), isNull);

      keyValueStore.values[userSessionSp] = '{"nickname":"User"}';
      expect(store.loadSession(), isNull);

      keyValueStore.values[userSessionSp] = 1;
      expect(store.loadSession(), isNull);
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
