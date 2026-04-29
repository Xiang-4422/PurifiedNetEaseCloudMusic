import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/bootstrap/app_binding.dart';
import 'package:bujuan/common/constants/colors.dart';
import 'package:bujuan/features/auth/application/startup_session_resolver.dart';
import 'package:bujuan/routes/router.gr.dart';
import 'package:bujuan/widget/scroll_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_router_observer.dart';

/// 统一应用级路由壳层，避免主题、滚动行为和导航观察者继续分散到页面侧。
class AppRootRouter extends StatelessWidget {
  /// 创建应用根路由组件。
  AppRootRouter({Key? key}) : super(key: key);

  // 根路由在应用生命周期内保持单例语义更稳，避免 rebuild 时重新生成
  // delegate 把历史导航状态打散。
  final _rootRouter = RootRouter();
  final _startupSessionResolver = const StartupSessionResolver();

  List<PageRouteInfo> _buildInitialRoutes() {
    if (_startupSessionResolver.shouldOpenHome) {
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
      scrollBehavior: NoStretchBouncingScrollBehavior(),
      title: "Bujuan",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routeInformationParser: _rootRouter.defaultRouteParser(),
      routerDelegate: _rootRouter.delegate(
        initialRoutes: _buildInitialRoutes(),
        navigatorObservers: () => [AppRouterObserver()],
      ),
    );
  }
}
