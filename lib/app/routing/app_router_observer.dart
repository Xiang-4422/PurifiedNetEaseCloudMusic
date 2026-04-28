import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

/// 当前只承担最小路由观测职责，页面切换日志集中在这里，避免页面内散落埋点。
class AppRouterObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    log('New route pushed: ${route.settings.name}');
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {}

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {}
}
