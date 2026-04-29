import 'package:flutter/material.dart';

import 'enum/drawer_state.dart';

/// 抽屉组件的命令控制器，用于从父级触发开合和监听展开进度。
class ZoomDrawerController {
  /// 打开抽屉并返回当前动画任务。
  TickerFuture? Function()? open;

  /// 关闭抽屉并返回当前动画任务。
  TickerFuture? Function()? close;

  /// 根据当前状态切换抽屉开合。
  TickerFuture? Function({bool forceToggle})? toggle;

  /// 判断抽屉是否已经完全展开。
  bool Function()? isOpen;

  /// 注册抽屉展开进度监听器。
  void Function(ZooDrawerUpdateListener listener)? addListener;

  /// 抽屉状态通知器，状态值覆盖 opening、closing、open 和 closed。
  ValueNotifier<DrawerState>? stateNotifier;
}

/// 抽屉展开进度监听器，参数为动画展开比例。
typedef ZooDrawerUpdateListener = void Function(double openedDegree);
