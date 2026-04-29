import 'package:flutter/material.dart';

/// 统一TabBar风格
class MyTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// TabBar 高度。
  final double? height;

  /// TabBar 控制器。
  final TabController? controller;

  /// 选中背景颜色。
  final Color? color;

  /// tab 组件列表。
  final List<Widget> tabs;

  /// 创建统一风格 TabBar。
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

/// 在普通 tab 和替代组件之间做缩放淡入切换。
class MyTabBarItemAnimatedSwitcher extends StatelessWidget {
  /// 普通 tab 组件。
  final Widget tabItem;

  /// 替代展示组件。
  final Widget replaceItem;

  /// 当前是否展示替代组件。
  final bool isTabBarVisible;

  /// 创建 tab 组件切换器。
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
