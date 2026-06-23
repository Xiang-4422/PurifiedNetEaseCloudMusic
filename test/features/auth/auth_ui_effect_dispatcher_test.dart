import 'dart:async';

import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:bujuan/features/auth/auth_ui_effect_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUiEffectDispatcher', () {
    test('shows and consumes message effects synchronously', () {
      final messages = <String>[];
      final consumed = <AuthUiEffect>[];
      var loginExpiredCalls = 0;
      final dispatcher = AuthUiEffectDispatcher(
        showMessage: messages.add,
        onLoginExpired: () async => loginExpiredCalls++,
        consumeEffect: consumed.add,
      );
      const effect = AuthUiEffect.message('二维码获取失败');

      dispatcher.dispatch(effect);

      expect(messages, ['二维码获取失败']);
      expect(consumed, hasLength(1));
      expect(consumed.single, same(effect));
      expect(loginExpiredCalls, 0);
    });

    test('runs login-expired navigation and consumes the effect', () async {
      final messages = <String>[];
      final consumed = <AuthUiEffect>[];
      final dispatcher = AuthUiEffectDispatcher(
        showMessage: messages.add,
        onLoginExpired: () async {},
        consumeEffect: consumed.add,
      );
      const effect = AuthUiEffect.loginExpired('登录失效');

      dispatcher.dispatch(effect);
      await Future<void>.delayed(Duration.zero);

      expect(messages, ['登录失效']);
      expect(consumed, hasLength(1));
      expect(consumed.single, same(effect));
    });

    test('reports login-expired navigation failure without leaking it', () async {
      final routeError = StateError('route failed');
      final reported = Completer<void>();
      final reportedEffects = <AuthUiEffect>[];
      final reportedErrors = <Object>[];
      final consumed = <AuthUiEffect>[];
      final unhandledErrors = <Object>[];
      final dispatcher = AuthUiEffectDispatcher(
        showMessage: (_) {},
        onLoginExpired: () => Future<void>.error(routeError),
        consumeEffect: consumed.add,
        onError: (effect, error, stackTrace) {
          reportedEffects.add(effect);
          reportedErrors.add(error);
          reported.complete();
          throw StateError('diagnostic failed');
        },
      );
      const effect = AuthUiEffect.loginExpired('登录失效');

      await runZonedGuarded(
        () async {
          dispatcher.dispatch(effect);
          await reported.future;
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(reportedEffects, hasLength(1));
      expect(reportedEffects.single, same(effect));
      expect(reportedErrors.single, same(routeError));
      expect(consumed, hasLength(1));
      expect(consumed.single, same(effect));
      expect(unhandledErrors, isEmpty);
    });
  });
}
