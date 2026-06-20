import 'dart:async';

import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
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
