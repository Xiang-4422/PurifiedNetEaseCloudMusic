import 'package:flutter/material.dart';

/// Style1Widget。
class Style1Widget extends StatelessWidget {
  /// 创建 Style1Widget。
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

  /// animationValue。
  final double animationValue;

  /// slideDirection。
  final int slideDirection;

  /// slideWidth。
  final double slideWidth;

  /// mainScreenScale。
  final double mainScreenScale;

  /// isRtl。
  final bool isRtl;

  /// mainScreenWidget。
  final Widget mainScreenWidget;

  /// menuScreenWidget。
  final Widget menuScreenWidget;

  /// menuBackgroundColor。
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
