import 'dart:async';

import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/core/state/operation_result.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:bujuan/features/auth/qr_login_data.dart';
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
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
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
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
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
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
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
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
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
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
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

    test('cached session bootstrap stores fetched session and clears loading', () async {
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
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

    test('cached session bootstrap falls back to qr when account fetch fails', () async {
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
      final controller = AuthController(repository: authRepository);

      final bootstrap = controller.bootstrap();
      expect(controller.isLoading.value, isTrue);

      authRepository.failNextFetch(StateError('network failed'));
      await bootstrap;

      expect(controller.isLoading.value, isFalse);
      expect(controller.loginCompleted.value, isFalse);
      expect(sessionController.userInfo.value.isLoggedIn, isFalse);
      expect(controller.qrCodeUrl.value, 'qr://qr-key-1');
      expect(controller.qrCodeNeedRefresh.value, isFalse);
      expect(controller.uiEffect.value?.type, AuthUiEffectType.message);
      expect(authRepository.createdQrKeys, ['qr-key-1']);
      expect(authRepository.savedLoginFlags, [false]);
    });

    test('bootstrap ignores orphaned login flag without cached session', () async {
      final authRepository = _FakeAuthRepository(hasCachedSession: false);
      _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
      final controller = AuthController(repository: authRepository);

      await controller.bootstrap();

      expect(controller.loginCompleted.value, isFalse);
      expect(controller.qrCodeUrl.value, 'qr://qr-key-1');
      expect(authRepository.fetchRequestCount, 0);
      expect(authRepository.createdQrKeys, ['qr-key-1']);
    });

    test('logout clears local account and emits login page effect', () async {
      final authRepository = _FakeAuthRepository(hasCachedSession: true);
      final sessionController = _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
      final controller = AuthController(repository: authRepository);
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );

      await controller.logoutCurrentUser();

      expect(sessionController.userInfo.value.isLoggedIn, isFalse);
      expect(authRepository.savedLoginFlags, [false]);
      expect(controller.uiEffect.value?.type, AuthUiEffectType.loginExpired);
      expect(controller.uiEffect.value?.message, '已退出登录');
    });

    test('qr refresh failure exposes retry state without throwing', () async {
      final authRepository = _FakeAuthRepository(hasCachedSession: false)..failNextQrCreation(StateError('network failed'));
      _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
      final controller = AuthController(repository: authRepository);

      await controller.refreshQrCode();

      expect(controller.isLoading.value, isFalse);
      expect(controller.qrCodeUrl.value, isEmpty);
      expect(controller.qrCodeNeedRefresh.value, isTrue);
      expect(controller.hintText.value, '二维码获取失败，点击重试');
      expect(controller.uiEffect.value?.type, AuthUiEffectType.message);
      expect(controller.uiEffect.value?.message, '二维码获取失败，请稍后重试');
      expect(authRepository.createdQrKeys, isEmpty);
    });

    test('qr polling failure keeps current code retrying', () async {
      final authRepository = _FakeAuthRepository(hasCachedSession: false)..nextQrStatusError = StateError('network failed');
      _putSessionController(
        saveLoginFlag: authRepository.setLoginFlag,
      );
      final controller = AuthController(
        repository: authRepository,
        qrPollingInterval: const Duration(milliseconds: 100),
      );

      await controller.refreshQrCode();

      expect(controller.qrCodeUrl.value, 'qr://qr-key-1');
      expect(controller.qrCodeNeedRefresh.value, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 130));

      final checksAfterFailure = authRepository.checkedQrKeys.length;
      expect(checksAfterFailure, greaterThanOrEqualTo(1));
      expect(controller.hintText.value, '网络异常，等待重试');
      expect(controller.qrCodeNeedRefresh.value, isFalse);

      authRepository.nextQrStatus = const QrCodeStatusResult(code: 800);
      await Future<void>.delayed(const Duration(milliseconds: 130));

      expect(authRepository.checkedQrKeys.length, greaterThan(checksAfterFailure));
      expect(controller.hintText.value, '二维码过期');
      expect(controller.qrCodeNeedRefresh.value, isTrue);
      controller.onClose();
    });
  });
}

UserSessionController _putSessionController({
  Future<void> Function(bool value)? saveLoginFlag,
}) {
  final controller = UserSessionController(
    repository: _FakeUserRepository(),
    sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
    saveLoginFlag: saveLoginFlag ?? (_) async {},
  );
  return Get.put<UserSessionController>(controller);
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.hasCachedSession});

  @override
  final bool hasCachedSession;

  final List<bool> savedLoginFlags = [];
  final List<Completer<UserSessionData>> _fetches = [];
  final List<String> createdQrKeys = [];
  final List<String> checkedQrKeys = [];
  Object? _nextQrCreationError;
  QrCodeCreationResult? _nextQrCreationResult;
  Object? nextQrStatusError;
  QrCodeStatusResult nextQrStatus = const QrCodeStatusResult(code: 801);

  int get fetchRequestCount => _fetches.length;

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

  void failNextQrCreation(Object error) {
    _nextQrCreationError = error;
  }

  void completeNextQrCreation(QrCodeCreationResult result) {
    _nextQrCreationResult = result;
  }

  @override
  Future<void> setLoginFlag(bool value) async {
    savedLoginFlags.add(value);
  }

  @override
  Future<QrCodeCreationResult> createQrCodeKey() async {
    final creationError = _nextQrCreationError;
    if (creationError != null) {
      _nextQrCreationError = null;
      throw creationError;
    }
    final creationResult = _nextQrCreationResult;
    if (creationResult != null) {
      _nextQrCreationResult = null;
      if (creationResult.success) {
        createdQrKeys.add(creationResult.unikey);
      }
      return creationResult;
    }
    final key = 'qr-key-${createdQrKeys.length + 1}';
    createdQrKeys.add(key);
    return QrCodeCreationResult(success: true, unikey: key);
  }

  @override
  String buildQrCodeUrl(String unikey) {
    return 'qr://$unikey';
  }

  @override
  Future<QrCodeStatusResult> checkQrCodeStatus(String unikey) async {
    checkedQrKeys.add(unikey);
    final statusError = nextQrStatusError;
    if (statusError != null) {
      nextQrStatusError = null;
      throw statusError;
    }
    return nextQrStatus;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<OperationResult> logout() async {
    return const OperationResult(success: true);
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
