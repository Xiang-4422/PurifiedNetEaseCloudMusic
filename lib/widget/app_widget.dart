
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import '../common/constants/colors.dart';
import '../main.dart';
import '../pages/album/controller.dart';
import '../pages/home/home_binding.dart';
import '../pages/index/cound_controller.dart';
import '../pages/index/index_controller.dart';
import '../pages/play_list/playlist_controller.dart';
import '../pages/playlist_manager/playlist_manager_controller.dart';
import '../pages/user/user_controller.dart';
import '../routes/router.gr.dart';

class AppWidget extends StatelessWidget {
  final bool isLandscape;
  final _rootRouter = RootRouter();

  AppWidget({Key? key, required this.isLandscape}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
      designSize: isLandscape ? const Size(2339, 1080) : const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        // GetX初始化依赖
        HomeBinding().dependencies();
        return GetMaterialApp.router(
          title: "Bujuan",
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // showPerformanceOverlay: true,
          // checkerboardOffscreenLayers: true,
          // checkerboardRasterCacheImages: true,
          themeMode: ThemeMode.system,
          // auto_route路由代理
          routerDelegate: _rootRouter.delegate(navigatorObservers: () => [MyObserver()]),
          routeInformationParser: _rootRouter.defaultRouteParser(),
          debugShowCheckedModeBanner: false,
          // 禁止字体缩放
          builder: (_, router) => MediaQuery(
              data: MediaQuery.of(_).copyWith(textScaleFactor: 1.0),
              child: router!),
        );
      },
    );
  }

}

class MyObserver extends AutoRouterObserver {
  _clearOrPutController(String name, {bool del = false}) {
    if (name.isEmpty) return;
    switch (name) {
      case 'AlbumView':
        del ? Get.delete<CloudController>() : Get.lazyPut<CloudController>(() => CloudController());
        break;
      case 'MainView':
        del ? Get.delete<IndexController>() : Get.lazyPut<IndexController>(() => IndexController());
        break;
      case 'UserView':
        del ? Get.delete<UserController>() : Get.lazyPut<UserController>(() => UserController());
        break;
      case 'PlayListView':
        del ? Get.delete<PlayListController>() : Get.lazyPut<PlayListController>(() => PlayListController());
        break;
      case 'AlbumDetails':
        del ? Get.delete<AlbumController>() : Get.lazyPut<AlbumController>(() => AlbumController());
        break;
      case 'PlaylistManagerView':
        del ? Get.delete<PlaylistManager>() : Get.lazyPut<PlaylistManager>(() => PlaylistManager());
        break;
    }
  }

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
}

