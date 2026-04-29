import 'dart:math';

import 'package:flutter/material.dart';

/// Style3Widget。
class Style3Widget extends StatelessWidget {
  /// 创建 Style3Widget。
  const Style3Widget({
    Key? key,
    required this.animationValue,
    required this.slideDirection,
    required this.menuScreenWidget,
    required this.mainScreenWidget,
    required this.slideWidth,
    required this.mainScreenScale,
    required this.isRtl,
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

  /// menuScreenWidget。
  final Widget menuScreenWidget;

  /// mainScreenWidget。
  final Widget mainScreenWidget;

  @override
  Widget build(BuildContext context) {
    final xPosition = (slideWidth / 2) * animationValue * slideDirection;
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
            ..rotateY(yAngle),
          alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
          child: mainScreenWidget,
        ),
      ],
    );
  }
}
