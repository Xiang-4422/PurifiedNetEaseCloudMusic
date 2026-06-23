import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:flutter/material.dart';

/// 首页壳层控制器的局部上下文边界。
class HomeShellScope extends InheritedWidget {
  /// 创建首页壳层控制器的局部上下文边界。
  const HomeShellScope({
    required this.homeShellController,
    required super.child,
    super.key,
  });

  /// 首页壳层控制器。
  final HomeShellController homeShellController;

  /// 从当前上下文读取首页壳层控制器。
  static HomeShellController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HomeShellScope>();
    if (scope == null) {
      throw FlutterError('HomeShellScope.of() called without a HomeShellScope ancestor.');
    }
    return scope.homeShellController;
  }

  @override
  bool updateShouldNotify(HomeShellScope oldWidget) {
    return homeShellController != oldWidget.homeShellController;
  }
}
