import 'dart:async';
import 'dart:developer' as developer;

import 'package:bujuan/features/auth/auth_controller_bundle.dart';
import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:bujuan/features/auth/auth_ui_effect_dispatcher.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 监听登录态展示副作用，并把根路由跳转和 Toast 展示留在 UI 边界。
class AuthUiEffectListener extends StatefulWidget {
  /// 创建登录态展示副作用监听器。
  const AuthUiEffectListener({
    required this.child,
    required this.onLoginExpired,
    super.key,
  });

  /// 子树内容。
  final Widget child;

  /// 登录失效时的根路由跳转动作。
  final FutureOr<void> Function() onLoginExpired;

  @override
  State<AuthUiEffectListener> createState() => _AuthUiEffectListenerState();
}

class _AuthUiEffectListenerState extends State<AuthUiEffectListener> {
  late final _controller = Get.find<AuthControllerBundle>().authController;
  Worker? _effectWorker;

  @override
  void initState() {
    super.initState();
    _effectWorker = ever<AuthUiEffect?>(_controller.uiEffect, _handleEffect);
    _handleEffect(_controller.uiEffect.value);
  }

  @override
  void dispose() {
    _effectWorker?.dispose();
    super.dispose();
  }

  void _handleEffect(AuthUiEffect? effect) {
    AuthUiEffectDispatcher(
      showMessage: ToastService.show,
      onLoginExpired: widget.onLoginExpired,
      consumeEffect: _controller.consumeUiEffect,
      onError: _reportAuthUiEffectError,
    ).dispatch(effect);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void _reportAuthUiEffectError(
  AuthUiEffect effect,
  Object error,
  StackTrace stackTrace,
) {
  developer.log(
    'auth.uiEffect.failed type=${effect.type.name}',
    name: 'Auth',
    error: error,
    stackTrace: stackTrace,
  );
}
