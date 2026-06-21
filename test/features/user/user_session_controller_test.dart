import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/core/state/operation_result.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSessionController', () {
    test('clears local session when remote logout reports failure', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final sessionStore = UserSessionStore(keyValueStore: keyValueStore);
      final savedLoginFlags = <bool>[];
      final controller = UserSessionController(
        repository: _FakeUserRepository(
          logoutResult: const OperationResult(
            success: false,
            message: 'remote failed',
          ),
        ),
        sessionStore: sessionStore,
        saveLoginFlag: (value) async => savedLoginFlags.add(value),
        canRestoreCachedSession: () => true,
      );
      await _seedSession(controller, sessionStore);

      await controller.clearUser();

      expect(controller.userInfo.value.isLoggedIn, isFalse);
      expect(sessionStore.loadSession(), isNull);
      expect(savedLoginFlags, [false]);
    });

    test('clears local session when remote logout throws', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final sessionStore = UserSessionStore(keyValueStore: keyValueStore);
      final savedLoginFlags = <bool>[];
      final controller = UserSessionController(
        repository: _FakeUserRepository(logoutError: StateError('network failed')),
        sessionStore: sessionStore,
        saveLoginFlag: (value) async => savedLoginFlags.add(value),
        canRestoreCachedSession: () => true,
      );
      await _seedSession(controller, sessionStore);

      await expectLater(controller.clearUser(), completes);

      expect(controller.userInfo.value.isLoggedIn, isFalse);
      expect(sessionStore.loadSession(), isNull);
      expect(savedLoginFlags, [false]);
    });

    test('does not restore cached session when app login state is not recoverable', () async {
      final keyValueStore = _MemoryKeyValueStore();
      final sessionStore = UserSessionStore(keyValueStore: keyValueStore);
      final savedLoginFlags = <bool>[];
      await sessionStore.saveSession(
        const UserSessionData(
          userId: 'user-1',
          nickname: 'User',
          avatarUrl: '',
        ),
      );
      final controller = UserSessionController(
        repository: _FakeUserRepository(),
        sessionStore: sessionStore,
        saveLoginFlag: (value) async => savedLoginFlags.add(value),
        canRestoreCachedSession: () => false,
      );

      controller.onInit();
      await controller.ensureCacheLoaded();

      expect(controller.userInfo.value.isLoggedIn, isFalse);
      expect(sessionStore.loadSession(), isNull);
      expect(savedLoginFlags, [false]);
    });
  });
}

Future<void> _seedSession(
  UserSessionController controller,
  UserSessionStore sessionStore,
) async {
  const session = UserSessionData(
    userId: 'user-1',
    nickname: 'User',
    avatarUrl: '',
  );
  controller.userInfo.value = session;
  await sessionStore.saveSession(session);
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({
    this.logoutResult = const OperationResult(success: true),
    this.logoutError,
  });

  final OperationResult logoutResult;
  final Object? logoutError;

  @override
  Future<OperationResult> logout() async {
    final error = logoutError;
    if (error != null) {
      throw error;
    }
    return logoutResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
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
