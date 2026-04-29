import 'dart:math';

import 'package:flutter/material.dart';

/// Style4Widget。
class Style4Widget extends StatelessWidget {
  /// 创建 Style4Widget。
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

  /// animationValue。
  final double animationValue;

  /// slideWidth。
  final double slideWidth;

  /// mainScreenScale。
  final double mainScreenScale;

  /// isRtl。
  final bool isRtl;

  /// slideDirection。
  final int slideDirection;

  /// menuScreenWidget。
  final Widget menuScreenWidget;

  /// mainScreenWidget。
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
