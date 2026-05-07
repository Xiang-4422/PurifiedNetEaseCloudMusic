import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/bootstrap/app_bootstrap.dart';
import 'package:bujuan/app/presentation_adapters/auth_ui_effect_listener.dart';
import 'package:bujuan/app/routing/app_router_observer.dart';
import 'package:bujuan/app/routing/router.dart';
import 'package:bujuan/app/routing/router.gr.dart';
import 'package:bujuan/app/theme/app_colors.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
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
      builder: (context, child) => AuthUiEffectListener(
        onLoginExpired: () => _rootRouter.replaceNamed(Routes.login),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
