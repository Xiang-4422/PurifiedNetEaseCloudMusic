// 路由监听，管理页面的Controller
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/album/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MyObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _clearOrPutController(route.settings.name ?? '');
    log('New route pushed: ${route.settings.name}');
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
      case 'AlbumRouteView':
        del
            ? Get.delete<AlbumController>()
            : Get.lazyPut<AlbumController>(() => AlbumController());
        break;
    }
  }
}
