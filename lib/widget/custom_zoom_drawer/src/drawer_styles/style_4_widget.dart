import 'dart:math';

import 'package:flutter/material.dart';

/// 抽屉样式 4，主页面以反向透视旋转方式让出菜单。
class Style4Widget extends StatelessWidget {
  /// 创建样式 4 的抽屉布局。
  const Style4Widget({
    Key? key,
    required this.animationValue,
    required this.slideDirection,
    required this.menuScreenWidget,
    required this.mainScreenWidget,
    required this.mainScreenScale,
    required this.slideWidth,
    required this.isRtl,
  }) : super(key: key);

  /// 抽屉动画进度，取值通常为 0 到 1。
  final double animationValue;

  /// 主页面滑出的参考宽度。
  final double slideWidth;

  /// 抽屉打开时主页面缩小的比例。
  final double mainScreenScale;

  /// 是否按从右到左布局展示。
  final bool isRtl;

  /// 主页面水平旋转和位移方向。
  final int slideDirection;

  /// 抽屉打开后露出的菜单内容。
  final Widget menuScreenWidget;

  /// 随动画平移、缩放和反向旋转的主内容。
  final Widget mainScreenWidget;

  @override
  Widget build(BuildContext context) {
    final xPosition = (slideWidth * 1.2) * animationValue * slideDirection;
    final scalePercentage = 1 - (animationValue * mainScreenScale);
    final yAngle = animationValue * (pi / 4) * slideDirection;

    return Stack(
      children: [
        menuScreenWidget,
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0009)
            ..translateByDouble(xPosition, 0, 0, 1)
            ..scaleByDouble(scalePercentage, scalePercentage, 1, 1)
            ..rotateY(-yAngle),
          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          child: mainScreenWidget,
        ),
      ],
    );
  }
}
