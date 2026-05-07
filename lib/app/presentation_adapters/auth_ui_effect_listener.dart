import 'dart:async';

import 'package:bujuan/app/services/toast_service.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 在展示边界消费登录流程副作用，避免控制器直接触碰 Toast 或路由。
class AuthUiEffectListener extends StatefulWidget {
  /// 创建登录副作用监听器。
  const AuthUiEffectListener({
    super.key,
    required this.child,
    required this.onLoginExpired,
  });

  /// 被监听器包裹的应用内容。
  final Widget child;

  /// 登录失效时由应用路由层执行的跳转。
  final FutureOr<void> Function() onLoginExpired;

  @override
  State<AuthUiEffectListener> createState() => _AuthUiEffectListenerState();
}

class _AuthUiEffectListenerState extends State<AuthUiEffectListener> {
  late final AuthController _controller;
  Worker? _effectWorker;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _effectWorker = ever<AuthUiEffect?>(_controller.uiEffect, _handleEffect);
    _handleEffect(_controller.uiEffect.value);
  }

  @override
  void dispose() {
    _effectWorker?.dispose();
    super.dispose();
  }

  void _handleEffect(AuthUiEffect? effect) {
    if (effect == null) {
      return;
    }
    ToastService.show(effect.message);
    if (effect.type == AuthUiEffectType.loginExpired) {
      unawaited(Future<void>.sync(widget.onLoginExpired));
    }
    _controller.consumeUiEffect(effect);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
