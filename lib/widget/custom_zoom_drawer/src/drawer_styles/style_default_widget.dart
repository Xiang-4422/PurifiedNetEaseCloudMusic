import 'package:flutter/material.dart';

/// 默认抽屉样式，负责主页面变换和可选双层阴影。
class StyleDefaultWidget extends StatelessWidget {
  /// 创建默认样式的抽屉布局。
  const StyleDefaultWidget({
    super.key,
    required this.animationController,
    required this.showShadow,
    required this.angle,
    required this.menuScreenWidget,
    required this.mainScreenWidget,
    this.shadowLayer1Color,
    this.shadowLayer2Color,
    required this.drawerShadowsBackgroundColor,
    required this.applyDefaultStyle,
  });

  /// 驱动抽屉开合的动画控制器。
  final AnimationController animationController;

  /// 是否在主页面背后显示双层阴影。
  final bool showShadow;

  /// 主页面旋转角度，单位为度。
  final double angle;

  /// 抽屉打开后露出的菜单内容。
  final Widget menuScreenWidget;

  /// 随默认样式变换的主内容。
  final Widget mainScreenWidget;

  /// 第一层阴影颜色；为空时使用默认阴影背景色派生。
  final Color? shadowLayer1Color;

  /// 第二层阴影颜色；为空时使用默认阴影背景色派生。
  final Color? shadowLayer2Color;

  /// 阴影层默认背景色。
  final Color drawerShadowsBackgroundColor;

  /// 默认样式变换函数，用于套用旋转、缩放和位移。
  final Widget Function(
    Widget?, {
    double? angle,
    double scale,
    double slide,
  }) applyDefaultStyle;

  @override
  Widget build(BuildContext context) {
    const slidePercent = 15.0;

    return Stack(
      children: [
        menuScreenWidget,
        if (showShadow) ...[
          /// Displaying the first shadow
          applyDefaultStyle(
            Container(
              color: shadowLayer1Color ??
                  drawerShadowsBackgroundColor.withAlpha(60),
            ),
            angle: (angle == 0.0) ? 0.0 : angle - 8,
            scale: .9,
            slide: slidePercent * 2,
          ),

          /// Displaying the second shadow
          applyDefaultStyle(
            Container(
              color: shadowLayer2Color ??
                  drawerShadowsBackgroundColor.withAlpha(180),
            ),
            angle: (angle == 0.0) ? 0.0 : angle - 4.0,
            scale: .95,
            slide: slidePercent,
          )
        ],

        /// Displaying the Main screen
        applyDefaultStyle(
          mainScreenWidget,
        ),
      ],
    );
  }
}
