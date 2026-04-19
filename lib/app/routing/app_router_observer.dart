import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

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
