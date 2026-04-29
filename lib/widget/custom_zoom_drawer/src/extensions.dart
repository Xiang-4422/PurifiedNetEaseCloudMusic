import 'package:flutter/material.dart';

import 'enum/drawer_last_action.dart';
import 'enum/drawer_state.dart';
import 'flutter_zoom_drawer.dart';

/// 提供从 [BuildContext] 读取最近抽屉状态的便捷扩展。
extension ZoomDrawerContext on BuildContext {
  /// 当前上下文最近的抽屉状态对象。
  ZoomDrawerState? get drawer => ZoomDrawer.of(this);

  /// 当前抽屉最近一次完成的开合动作。
  DrawerLastAction? get drawerLastAction =>
      ZoomDrawer.of(this)?.drawerLastAction;

  /// 当前抽屉的动画状态。
  DrawerState? get drawerState => ZoomDrawer.of(this)?.stateNotifier.value;

  /// 当前抽屉状态通知器。
  ValueNotifier<DrawerState>? get drawerStateNotifier =>
      ZoomDrawer.of(this)?.stateNotifier;

  /// 当前媒体查询中的屏幕宽度。
  double get screenWidth => MediaQuery.of(this).size.width;

  /// 当前媒体查询中的屏幕高度。
  double get screenHeight => MediaQuery.of(this).size.height;
}
