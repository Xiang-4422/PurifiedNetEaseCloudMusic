import 'package:flutter/material.dart';

import 'enum/drawer_state.dart';

class ZoomDrawerController {
  /// Open drawer
  TickerFuture? Function()? open;

  /// Close drawer
  TickerFuture? Function()? close;

  /// Toggle drawer
  TickerFuture? Function({bool forceToggle})? toggle;

  /// Determine if status of drawer equals to Open
  bool Function()? isOpen;

  void Function(ZooDrawerUpdateListener listener)? addListener;

  /// Drawer state notifier
  /// opening, closing, open, closed
  ValueNotifier<DrawerState>? stateNotifier;
}

typedef ZooDrawerUpdateListener = void Function(double openedDegree);
