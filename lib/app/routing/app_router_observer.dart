import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

/// 当前只承担最小路由观测职责，先保证迁移期能稳定追踪页面切换，
/// 后续需要扩展埋点时再集中收口，不在页面里零散加日志。
class AppRouterObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    log('New route pushed: ${route.settings.name}');
  }

  // 迁移期先只保留最稳定的 push 轨迹，避免 tab 事件日志继续放大噪音。
  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {}

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {}
}
