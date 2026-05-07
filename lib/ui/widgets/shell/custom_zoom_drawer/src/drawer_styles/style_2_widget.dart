import 'package:flutter/material.dart';

/// 抽屉样式 2，主页面缩放并沿对角方向让出菜单。
class Style2Widget extends StatelessWidget {
  /// 创建样式 2 的抽屉布局。
  const Style2Widget({
    Key? key,
    required this.animationValue,
    required this.menuScreenWidget,
    required this.mainScreenWidget,
    required this.slideDirection,
    required this.slideWidth,
    required this.mainScreenScale,
    required this.isRtl,
  }) : super(key: key);

  /// 主页面水平位移方向，LTR 为正向，RTL 为反向。
  final int slideDirection;

  /// 主页面滑出的目标宽度。
  final double slideWidth;

  /// 抽屉打开时主页面缩小的比例。
  final double mainScreenScale;

  /// 是否按从右到左布局展示。
  final bool isRtl;

  /// 抽屉动画进度，取值通常为 0 到 1。
  final double animationValue;

  /// 抽屉打开后露出的菜单内容。
  final Widget menuScreenWidget;

  /// 随动画平移和缩放的主内容。
  final Widget mainScreenWidget;

  @override
  Widget build(BuildContext context) {
    final xPosition = slideWidth * slideDirection * animationValue;
    final yPosition = animationValue * slideWidth;
    final scalePercentage = 1 - (animationValue * mainScreenScale);

    return Stack(
      children: [
        menuScreenWidget,
        Transform(
          transform: Matrix4.identity()
            ..translateByDouble(xPosition, yPosition, 0, 1)
            ..scaleByDouble(scalePercentage, scalePercentage, 1, 1),
          alignment: Alignment.center,
          child: mainScreenWidget,
        ),
      ],
    );
  }
}
