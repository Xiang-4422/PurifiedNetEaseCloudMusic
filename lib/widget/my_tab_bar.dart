import 'package:flutter/material.dart';

/// 统一TabBar风格
class MyTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// height。
  final double? height;

  /// controller。
  final TabController? controller;

  /// color。
  final Color? color;

  /// tabs。
  final List<Widget> tabs;

  /// 创建 MyTabBar。
  const MyTabBar(
      {Key? key, required this.tabs, this.controller, this.color, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color widgetColor = color ?? Theme.of(context).colorScheme.onPrimary;
    return SizedBox(
      height: height,
      child: TabBar(
        controller: controller,
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        indicatorWeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: widgetColor.withValues(alpha: 0.1),
          // 去极大值，让左右均为半圆
          borderRadius: BorderRadius.circular((1 << 20).toDouble()),
        ),
        tabs: tabs,
      ),
    );
  }

  @override
  Size get preferredSize {
    // 返回你希望的高度，通常和原生TabBar一致
    return Size.fromHeight(height ?? 48.0); // 标准高度
  }
}

/// MyTabBarItemAnimatedSwitcher。
class MyTabBarItemAnimatedSwitcher extends StatelessWidget {
  /// tabItem。
  final Widget tabItem;

  /// replaceItem。
  final Widget replaceItem;

  /// isTabBarVisible。
  final bool isTabBarVisible;

  /// 创建 MyTabBarItemAnimatedSwitcher。
  const MyTabBarItemAnimatedSwitcher(
      {super.key,
      required this.isTabBarVisible,
      required this.tabItem,
      required this.replaceItem});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        //执行缩放动画
        return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child));
      },
      child: Visibility(
          key: ValueKey(isTabBarVisible),
          visible: isTabBarVisible,
          replacement: tabItem,
          child: replaceItem),
    );
  }
}
