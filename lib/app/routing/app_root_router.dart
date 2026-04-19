import 'package:bujuan/common/constants/colors.dart';
import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:bujuan/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_router_observer.dart';

class AppRootRouter extends StatelessWidget {
  AppRootRouter({Key? key}) : super(key: key);

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
