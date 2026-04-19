import 'package:bujuan/common/constants/colors.dart';
import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:bujuan/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_router_observer.dart';

/// 统一应用级路由壳层，避免主题、滚动行为和导航观察者继续分散到页面侧。
class AppRootRouter extends StatelessWidget {
  AppRootRouter({Key? key}) : super(key: key);

  // 根路由在应用生命周期内保持单例语义更稳，避免 rebuild 时重新生成
  // delegate 把历史导航状态打散。
  final _rootRouter = RootRouter();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      scrollBehavior: NoStretchBouncingScrollBehavior(),
      title: "Bujuan",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routeInformationParser: _rootRouter.defaultRouteParser(),
      routerDelegate: _rootRouter.delegate(
        navigatorObservers: () => [AppRouterObserver()],
      ),
    );
  }
}
