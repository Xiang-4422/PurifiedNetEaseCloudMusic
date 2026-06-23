import 'dart:async';

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

    test('clear user waits for stale session save before clearing cache', () async {
      final keyValueStore = _DelayedPutKeyValueStore();
      final sessionStore = UserSessionStore(keyValueStore: keyValueStore);
      final savedLoginFlags = <bool>[];
      final controller = UserSessionController(
        repository: _FakeUserRepository(),
        sessionStore: sessionStore,
        saveLoginFlag: (value) async => savedLoginFlags.add(value),
        canRestoreCachedSession: () => true,
      )..onInit();

      controller.userInfo.value = const UserSessionData(
        userId: 'slow-user',
        nickname: 'Slow',
        avatarUrl: '',
      );
      await Future<void>.delayed(Duration.zero);
      expect(keyValueStore.pendingPutCount, 1);

      var clearCompleted = false;
      final clearFuture = controller.clearUser().then((_) {
        clearCompleted = true;
      });
      await Future<void>.delayed(Duration.zero);

      expect(clearCompleted, isFalse);

      keyValueStore.completeNextPut();
      await clearFuture;

      expect(clearCompleted, isTrue);
      expect(controller.userInfo.value.isLoggedIn, isFalse);
      expect(sessionStore.loadSession(), isNull);
      expect(savedLoginFlags, [false]);
    });

    test('skips stale queued session save when newer account is pending', () async {
      final keyValueStore = _DelayedPutKeyValueStore();
      final sessionStore = UserSessionStore(keyValueStore: keyValueStore);
      final controller = UserSessionController(
        repository: _FakeUserRepository(),
        sessionStore: sessionStore,
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      )..onInit();

      controller.userInfo.value = const UserSessionData(
        userId: 'first-user',
        nickname: 'First',
        avatarUrl: '',
      );
      await _flushAsyncWork();
      expect(keyValueStore.pendingPutCount, 1);

      controller.userInfo.value = const UserSessionData(
        userId: 'stale-user',
        nickname: 'Stale',
        avatarUrl: '',
      );
      controller.userInfo.value = const UserSessionData(
        userId: 'fresh-user',
        nickname: 'Fresh',
        avatarUrl: '',
      );
      await _flushAsyncWork();
      expect(keyValueStore.pendingPutCount, 1);

      keyValueStore.completeNextPut();
      await _flushAsyncWork();

      expect(keyValueStore.pendingPutCount, 1);
      expect(keyValueStore.nextPendingValue, contains('fresh-user'));
      expect(keyValueStore.nextPendingValue, isNot(contains('stale-user')));

      keyValueStore.completeNextPut();
      await _flushAsyncWork();

      expect(sessionStore.loadSession()?.userId, 'fresh-user');
      expect(sessionStore.loadSession()?.nickname, 'Fresh');
    });

    test('background session persistence failure is consumed', () async {
      final keyValueStore = _FailingPutKeyValueStore();
      final sessionStore = UserSessionStore(keyValueStore: keyValueStore);
      final unhandledErrors = <Object>[];
      final controller = UserSessionController(
        repository: _FakeUserRepository(),
        sessionStore: sessionStore,
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      )..onInit();

      await runZonedGuarded(
        () async {
          controller.userInfo.value = const UserSessionData(
            userId: 'user-1',
            nickname: 'User',
            avatarUrl: '',
          );
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(keyValueStore.putCount, 1);
      expect(unhandledErrors, isEmpty);
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

Future<void> _flushAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
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

class _DelayedPutKeyValueStore extends _MemoryKeyValueStore {
  final List<_PendingPut> _pendingPuts = <_PendingPut>[];

  int get pendingPutCount => _pendingPuts.length;

  Object? get nextPendingValue => _pendingPuts.isEmpty ? null : _pendingPuts.first.value;

  @override
  Future<void> put(String key, Object? value) async {
    final pendingPut = _PendingPut(key, value);
    _pendingPuts.add(pendingPut);
    await pendingPut.completer.future;
    values[key] = value;
  }

  void completeNextPut() {
    _pendingPuts.removeAt(0).completer.complete();
  }
}

class _PendingPut {
  _PendingPut(this.key, this.value);

  final String key;
  final Object? value;
  final Completer<void> completer = Completer<void>();
}

class _FailingPutKeyValueStore extends _MemoryKeyValueStore {
  int putCount = 0;

  @override
  Future<void> put(String key, Object? value) async {
    putCount++;
    throw StateError('session save failed');
  }
}
