import 'package:bujuan/app/bootstrap/app_bootstrap.dart';
import 'package:bujuan/app/bootstrap/route_bootstrap.dart';
import 'package:bujuan/ui/theme/app_theme.dart';
import 'package:bujuan/ui/widgets/auth/auth_ui_effect_listener.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 应用根组件，承接全局路由、主题、滚动行为和依赖装配入口。
class App extends StatelessWidget {
  /// 创建应用根组件。
  const App({super.key});

  static final AppRouteBootstrapResult _routes = initializeRouteInfrastructure();

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
      routeInformationParser: _routes.router.defaultRouteParser(),
      routerDelegate: _routes.router.delegate(
        initialRoutes: _routes.buildInitialRoutes(),
        navigatorObservers: _routes.buildNavigatorObservers,
      ),
      builder: (context, child) => AuthUiEffectListener(
        onLoginExpired: _routes.replaceWithLogin,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
