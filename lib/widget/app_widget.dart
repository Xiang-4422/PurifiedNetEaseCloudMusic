
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../common/constants/colors.dart';
import '../pages/album/controller.dart';
import '../pages/home/home_page_controller.dart';
import '../pages/index/cloud_controller.dart';
import '../pages/index/explore_page_controller.dart';
import '../pages/play_list/playlist_controller.dart';
import '../pages/user/personal_page_controller.dart';
import '../routes/router.gr.dart';

/// 应用配置
class AppWidget extends StatelessWidget {
  final _rootRouter = RootRouter();

  AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
      // designSize: const Size(360, 640),
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return GetMaterialApp.router(
          // showPerformanceOverlay: true,
          // checkerboardOffscreenLayers: true,
          // checkerboardRasterCacheImages: true,
          debugShowCheckedModeBanner: false,
          // 渲染时间显示
          showPerformanceOverlay: false,

          title: "Bujuan",
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          // auto_route路由代理
          routeInformationParser: _rootRouter.defaultRouteParser(),
          routerDelegate: _rootRouter.delegate(navigatorObservers: () => [MyObserver()]),
        );
      },
    );
  }
}

// 路由监听，管理页面的Controller
class MyObserver extends AutoRouterObserver {

  _clearOrPutController(String name, {bool del = false}) {
    if (name.isEmpty) return;
    print("XY4422" + name);
    switch (name) {
      case 'CloudDriveView':
        del ? Get.delete<CloudController>() : Get.lazyPut<CloudController>(() => CloudController());
        break;
      case 'MainView':
        del ? Get.delete<ExplorePageController>() : Get.lazyPut<ExplorePageController>(() => ExplorePageController());
        break;
      case 'UserView':
        del ? Get.delete<PersonalPageController>() : Get.lazyPut<PersonalPageController>(() => PersonalPageController());
        break;
      case 'PlayListView':
        del ? Get.delete<PlayListController>() : Get.lazyPut<PlayListController>(() => PlayListController());
        break;
      case 'AlbumDetails':
        del ? Get.delete<AlbumController>() : Get.lazyPut<AlbumController>(() => AlbumController());
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

