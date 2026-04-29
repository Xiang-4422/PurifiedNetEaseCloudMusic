import 'package:flutter/material.dart';

/// 抽屉样式 1，主页面保持原位，菜单从侧边平移进入。
class Style1Widget extends StatelessWidget {
  /// 创建样式 1 的抽屉布局。
  const Style1Widget({
    Key? key,
    required this.animationValue,
    required this.mainScreenWidget,
    required this.menuScreenWidget,
    required this.slideDirection,
    required this.slideWidth,
    required this.mainScreenScale,
    required this.isRtl,
    this.menuBackgroundColor,
  }) : super(key: key);

  /// 抽屉动画进度，取值通常为 0 到 1。
  final double animationValue;

  /// 菜单滑动方向，LTR 为正向，RTL 为反向。
  final int slideDirection;

  /// 菜单滑出的目标宽度。
  final double slideWidth;

  /// 主页面缩放比例配置，本样式保留该入参以兼容统一构造。
  final double mainScreenScale;

  /// 是否按从右到左布局展示。
  final bool isRtl;

  /// 抽屉关闭时显示的主内容。
  final Widget mainScreenWidget;

  /// 抽屉打开时显示的菜单内容。
  final Widget menuScreenWidget;

  /// 菜单区域背景色。
  final Color? menuBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final xOffset = (1 - animationValue) * slideWidth * slideDirection;

    return Stack(
      children: [
        mainScreenWidget,
        Transform.translate(
          offset: Offset(-xOffset, 0),
          child: Container(
            width: slideWidth,
            color: menuBackgroundColor,
            child: menuScreenWidget,
          ),
        ),
      ],
    );
  }
}
