import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/app_router_observer.dart';
import 'package:bujuan/app/routing/router.dart';
import 'package:bujuan/app/routing/router.gr.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
import 'package:flutter/widgets.dart';

/// 应用根路由启动配置。
class AppRouteBootstrapResult {
  /// 创建应用根路由启动配置。
  AppRouteBootstrapResult({
    RootRouter? router,
    AuthStateStore authStateStore = const AuthStateStore(),
  })  : router = router ?? RootRouter(),
        _authStateStore = authStateStore;

  /// 应用根路由实例。
  final RootRouter router;

  final AuthStateStore _authStateStore;

  /// 根据本地 session 状态构建冷启动首屏。
  List<PageRouteInfo> buildInitialRoutes() {
    if (_authStateStore.hasCachedSession) {
      return const [AppHomeRouteView()];
    }
    return const [LoginRouteView()];
  }

  /// 构建根路由 observer。
  List<NavigatorObserver> buildNavigatorObservers() {
    return [AppRouterObserver()];
  }

  /// 登录失效时回到登录页。
  Future<void> replaceWithLogin() async {
    await router.replaceNamed(Routes.login);
  }
}

/// 创建应用路由启动配置。
AppRouteBootstrapResult initializeRouteInfrastructure() {
  return AppRouteBootstrapResult();
}
