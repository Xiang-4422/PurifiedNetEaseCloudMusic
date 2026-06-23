import 'dart:async';

import 'package:bujuan/features/auth/auth_ui_effect.dart';

/// 登录展示副作用失败时的诊断回调。
typedef AuthUiEffectErrorHandler = void Function(
  AuthUiEffect effect,
  Object error,
  StackTrace stackTrace,
);

/// 展示登录流程产生的一次性 UI 副作用。
class AuthUiEffectDispatcher {
  /// 创建登录展示副作用分发器。
  const AuthUiEffectDispatcher({
    required void Function(String message) showMessage,
    required FutureOr<void> Function() onLoginExpired,
    required void Function(AuthUiEffect effect) consumeEffect,
    AuthUiEffectErrorHandler? onError,
  })  : _showMessage = showMessage,
        _onLoginExpired = onLoginExpired,
        _consumeEffect = consumeEffect,
        _onError = onError;

  final void Function(String message) _showMessage;
  final FutureOr<void> Function() _onLoginExpired;
  final void Function(AuthUiEffect effect) _consumeEffect;
  final AuthUiEffectErrorHandler? _onError;

  /// 分发一个待展示副作用。
  void dispatch(AuthUiEffect? effect) {
    if (effect == null) {
      return;
    }
    _showMessage(effect.message);
    if (effect.type == AuthUiEffectType.loginExpired) {
      unawaited(_handleLoginExpired(effect));
      return;
    }
    _consumeEffect(effect);
  }

  Future<void> _handleLoginExpired(AuthUiEffect effect) async {
    try {
      await _onLoginExpired();
    } catch (error, stackTrace) {
      try {
        _onError?.call(effect, error, stackTrace);
      } catch (_) {}
    } finally {
      _consumeEffect(effect);
    }
  }
}
