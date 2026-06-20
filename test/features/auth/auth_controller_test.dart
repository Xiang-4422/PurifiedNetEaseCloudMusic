import 'dart:async';

import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('AuthController', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(Get.reset);

    test('ignores stale background validation after current user changes', () async {
      final authRepository = _FakeAuthRepository(hasCachedLogin: true);
      final sessionController = _putSessionController();
      final controller = AuthController(repository: authRepository);

      sessionController.userInfo.value = const UserSessionData(
        userId: 'old-user',
        nickname: 'Old',
        avatarUrl: '',
      );
      final validation = controller.validateLoginStateInBackgroundIfNeeded();

      sessionController.userInfo.value = const UserSessionData(
        userId: 'new-user',
        nickname: 'New',
        avatarUrl: '',
      );
      authRepository.completeNextFetch(
        const UserSessionData(
          userId: 'old-user',
          nickname: 'Old Refreshed',
          avatarUrl: 'old-avatar',
        ),
      );
      await validation;

      expect(sessionController.userInfo.value.userId, 'new-user');
      expect(sessionController.userInfo.value.nickname, 'New');
      expect(authRepository.savedLoginFlags, isEmpty);
    });

    test('does not expire a newer current user when stale validation fails', () async {
      final authRepository = _FakeAuthRepository(hasCachedLogin: true);
      final sessionController = _putSessionController();
      final controller = AuthController(repository: authRepository);

      sessionController.userInfo.value = const UserSessionData(
        userId: 'old-user',
        nickname: 'Old',
        avatarUrl: '',
      );
      final validation = controller.validateLoginStateInBackgroundIfNeeded();

      sessionController.userInfo.value = const UserSessionData(
        userId: 'new-user',
        nickname: 'New',
        avatarUrl: '',
      );
      authRepository.completeNextFetch(const UserSessionData.empty());
      await validation;

      expect(sessionController.userInfo.value.userId, 'new-user');
      expect(sessionController.userInfo.value.nickname, 'New');
      expect(authRepository.savedLoginFlags, isEmpty);
    });

    test('keeps cached session when background validation request fails', () async {
      final authRepository = _FakeAuthRepository(hasCachedLogin: true);
      final sessionController = _putSessionController();
      final controller = AuthController(repository: authRepository);

      sessionController.userInfo.value = const UserSessionData(
        userId: 'cached-user',
        nickname: 'Cached',
        avatarUrl: '',
      );
      final validation = controller.validateLoginStateInBackgroundIfNeeded();

      authRepository.failNextFetch(StateError('network failed'));
      await validation;

      expect(sessionController.userInfo.value.userId, 'cached-user');
      expect(sessionController.userInfo.value.nickname, 'Cached');
      expect(authRepository.savedLoginFlags, isEmpty);
      expect(controller.uiEffect.value, isNull);
    });

    test('cached session bootstrap ignores failed background validation', () async {
      final authRepository = _FakeAuthRepository(hasCachedLogin: true);
      final sessionController = _putSessionController();
      final controller = AuthController(repository: authRepository);

      sessionController.userInfo.value = const UserSessionData(
        userId: 'cached-user',
        nickname: 'Cached',
        avatarUrl: '',
      );
      await controller.bootstrap();

      authRepository.failNextFetch(StateError('network failed'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.loginCompleted.value, isTrue);
      expect(sessionController.userInfo.value.userId, 'cached-user');
      expect(authRepository.savedLoginFlags, isEmpty);
      expect(controller.uiEffect.value, isNull);
    });

    test('expires cached session when background validation returns logged out user', () async {
      final authRepository = _FakeAuthRepository(hasCachedLogin: true);
      final sessionController = _putSessionController();
      final controller = AuthController(repository: authRepository);

      sessionController.userInfo.value = const UserSessionData(
        userId: 'cached-user',
        nickname: 'Cached',
        avatarUrl: '',
      );
      final validation = controller.validateLoginStateInBackgroundIfNeeded();

      authRepository.completeNextFetch(const UserSessionData.empty());
      await validation;

      expect(sessionController.userInfo.value.isLoggedIn, isFalse);
      expect(authRepository.savedLoginFlags, [false]);
      expect(controller.uiEffect.value?.type, AuthUiEffectType.loginExpired);
    });

    test('cached login bootstrap stores fetched session and clears loading', () async {
      final authRepository = _FakeAuthRepository(hasCachedLogin: true);
      final sessionController = _putSessionController();
      final controller = AuthController(repository: authRepository);

      final bootstrap = controller.bootstrap();
      expect(controller.isLoading.value, isTrue);

      authRepository.completeNextFetch(
        const UserSessionData(
          userId: 'user-1',
          nickname: 'User',
          avatarUrl: 'avatar',
        ),
      );
      await bootstrap;

      expect(controller.isLoading.value, isFalse);
      expect(controller.loginCompleted.value, isTrue);
      expect(sessionController.userInfo.value.userId, 'user-1');
      expect(sessionController.userInfo.value.nickname, 'User');
    });
  });
}

UserSessionController _putSessionController() {
  final controller = UserSessionController(
    repository: _FakeUserRepository(),
    sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
    saveLoginFlag: (_) async {},
  );
  return Get.put<UserSessionController>(controller);
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.hasCachedLogin});

  @override
  final bool hasCachedLogin;

  final List<bool> savedLoginFlags = [];
  final List<Completer<UserSessionData>> _fetches = [];

  @override
  Future<UserSessionData> fetchLoginAccountInfo() {
    final completer = Completer<UserSessionData>();
    _fetches.add(completer);
    return completer.future;
  }

  void completeNextFetch(UserSessionData value) {
    _fetches.removeAt(0).complete(value);
  }

  void failNextFetch(Object error) {
    _fetches.removeAt(0).completeError(error);
  }

  @override
  Future<void> setLoginFlag(bool value) async {
    savedLoginFlags.add(value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserRepository implements UserRepository {
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
