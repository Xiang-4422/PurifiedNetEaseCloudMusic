import 'package:flutter/material.dart';

/// Style2Widget。
class Style2Widget extends StatelessWidget {
  /// 创建 Style2Widget。
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

  /// slideDirection。
  final int slideDirection;

  /// slideWidth。
  final double slideWidth;

  /// mainScreenScale。
  final double mainScreenScale;

  /// isRtl。
  final bool isRtl;

  /// animationValue。
  final double animationValue;

  /// menuScreenWidget。
  final Widget menuScreenWidget;

  /// mainScreenWidget。
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
