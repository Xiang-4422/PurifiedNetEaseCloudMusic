import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'common/constants/colors.dart';
import 'routes/router.gr.dart';

/// 应用配置
class AppRootRouter extends StatelessWidget {
  AppRootRouter({Key? key}) : super(key: key);

  final _rootRouter = RootRouter();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      // showPerformanceOverlay: true,
      // checkerboardOffscreenLayers: true,
      // checkerboardRasterCacheImages: true,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,

      scrollBehavior: NoStretchBouncingScrollBehavior(),
      title: "Bujuan",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // auto_route路由代理
      routeInformationParser: _rootRouter.defaultRouteParser(),
      routerDelegate: _rootRouter.delegate(
          navigatorObservers: () => [AutoRouterObserver()]),
    );
  }
}
