import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/bootstrap/app_bootstrap.dart';
import 'package:bujuan/app/routing/app_router_observer.dart';
import 'package:bujuan/app/routing/router.dart';
import 'package:bujuan/app/routing/router.gr.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:bujuan/ui/theme/app_theme.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 应用根组件，承接全局路由、主题、滚动行为和依赖装配入口。
class App extends StatelessWidget {
  /// 创建应用根组件。
  const App({super.key});

  static final RootRouter _rootRouter = RootRouter();
  static const AuthStateStore _authStateStore = AuthStateStore();

  static List<PageRouteInfo> _buildInitialRoutes() {
    if (_authStateStore.hasCachedSession) {
      return const [AppHomeRouteView()];
    }
    return const [LoginRouteView()];
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      scrollBehavior: const NoStretchBouncingScrollBehavior(),
      title: 'Bujuan',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routeInformationParser: _rootRouter.defaultRouteParser(),
      routerDelegate: _rootRouter.delegate(
        initialRoutes: _buildInitialRoutes(),
        navigatorObservers: () => [AppRouterObserver()],
      ),
      builder: (context, child) => _AuthUiEffectListener(
        onLoginExpired: () => _rootRouter.replaceNamed(Routes.login),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

class _AuthUiEffectListener extends StatefulWidget {
  const _AuthUiEffectListener({
    required this.child,
    required this.onLoginExpired,
  });

  final Widget child;
  final FutureOr<void> Function() onLoginExpired;

  @override
  State<_AuthUiEffectListener> createState() => _AuthUiEffectListenerState();
}

class _AuthUiEffectListenerState extends State<_AuthUiEffectListener> {
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
