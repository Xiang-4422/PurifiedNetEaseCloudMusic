
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/cloud/cloud_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'common/constants/colors.dart';
import 'pages/album/controller.dart';
import 'controllers/app_controller.dart';
import 'pages/play_list/playlist_controller.dart';
import 'routes/router.gr.dart';

/// 应用配置
class AppRootWidget extends StatelessWidget {
  AppRootWidget({Key? key}) : super(key: key);

  final _rootRouter = RootRouter();


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      // showPerformanceOverlay: true,
      // checkerboardOffscreenLayers: true,
      // checkerboardRasterCacheImages: true,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,

      title: "Bujuan",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // auto_route路由代理
      routeInformationParser: _rootRouter.defaultRouteParser(),
      routerDelegate: _rootRouter.delegate(navigatorObservers: () => [MyObserver()]),
    );
  }
}

// 路由监听，管理页面的Controller
class MyObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _clearOrPutController(route.settings.name ?? '');
    print('New route pushed: ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // TODO: implement didRemove
    super.didRemove(route, previousRoute);
    _clearOrPutController(route.settings.name ?? '', del: true);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // TODO: implement didPop
    super.didPop(route, previousRoute);
    AppController.to.rollBackAppBarTitle();
    _clearOrPutController(route.settings.name ?? '', del: true);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  // only override to observer tab routes
  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {}

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {}

  _clearOrPutController(String name, {bool del = false}) {
    log("clearOrPutController: $name + $del");
    // return;
    if (name.isEmpty) return;
    switch (name) {
      case 'CloudDriveView':
        del ? Get.delete<CloudController>() : Get.lazyPut<CloudController>(() => CloudController());
        break;
      case 'PlayListRouteView':
        del ? Get.delete<PlayListController>() : Get.lazyPut<PlayListController>(() => PlayListController());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppController.to.isInPlayListPage.value = del ? false : true;
        });
        break;
      case 'AlbumRouteView':
        del ? Get.delete<AlbumController>() : Get.lazyPut<AlbumController>(() => AlbumController());
        break;
    }
  }
}

