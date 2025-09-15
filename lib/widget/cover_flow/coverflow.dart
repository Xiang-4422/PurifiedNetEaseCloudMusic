library coverflow;

import 'dart:math';

import 'package:flutter/material.dart';

class CoverFlow extends StatefulWidget {
  final List<Widget> images;
  final Function? onCenterItemSelected;

  const CoverFlow({
    super.key,
    required this.images,
    this.onCenterItemSelected,
  });

  @override
  State<CoverFlow> createState() => _CoverFlowState();
}

class _CoverFlowState extends State<CoverFlow> {
  PageController? _pageController;
  double _currentPagePosition = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPagePosition.toInt());
    _pageController!.addListener(() {
      setState(() {
      _currentPagePosition = _pageController!.page ?? 0;
    });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        double cardSize = constraints.maxHeight;

        print("cardSize: $cardSize");
        print("nearByCardGapWidth: ${cardSize * (2 * cos(pi/2 * 1/3 / 2) - 1)}");

        return GestureDetector(
          // 左右点击滚动
          onTapUp: (detail) {
            final double centerPosition = constraints.maxWidth / 2;

            final double centerCardLeftEdge = centerPosition - cardSize / 2;
            final double centerCardRightEdge = centerPosition + cardSize / 2;

            if (detail.localPosition.dx <= centerCardLeftEdge) {
              _pageController!.animateToPage(
                  _currentPagePosition.toInt() - 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn
              );
            } else if (detail.localPosition.dx >= centerCardRightEdge) {
              _pageController!.animateToPage(
                  _currentPagePosition.toInt() + 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn
              );
            } else {
              widget.onCenterItemSelected!(_currentPagePosition.toInt());
            }
          },
          child: Stack(
            children: <Widget>[
              CoverFlowCardItems(
                images: widget.images,
                pagePositon: _currentPagePosition,
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
                cardSize: cardSize,
                nearByCardAngle: pi/2 * 2/3,
                nearByCardGapWidth: cardSize * (2 * cos(pi/2 * 2/3 / 2) - 1),
                // nearByCardGapWidth: cardSize * 3 /5,
                farCardAngle: pi/2 * 2/3,
                farCardGapWidth: cardSize * 1/5,
              ),
              // 利用空pageview图层来实现滚动功能
              Positioned.fill(
                child: PageView.builder(
                  itemCount: widget.images.length,
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return Container();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CoverFlowCardItems extends StatelessWidget {
  final List<Widget> images;
  final double pagePositon;
  final double maxHeight;
  final double maxWidth;
  final double cardSize;
  final double nearByCardAngle;
  final double nearByCardGapWidth;
  final double farCardAngle;
  final double farCardGapWidth;


  const CoverFlowCardItems({
    super.key,
    required this.images,
    required this.pagePositon,
    required this.maxHeight,
    required this.maxWidth,
    required this.cardSize,
    required this.nearByCardAngle,
    required this.nearByCardGapWidth,
    required this.farCardAngle,
    required this.farCardGapWidth,
  });

  @override
  Widget build(BuildContext context) {
    int currentCenterIndex = (pagePositon + 0.5).toInt();
    return SizedBox(
      height: maxHeight,
      child: Stack(
        alignment: AlignmentDirectional.center,
        clipBehavior: Clip.none,
        children: [
          // 左边卡片
          ...images.sublist(0, currentCenterIndex).map((item) {
            return _buildCard(item);
          }).toList(),
          // 中心卡片及其右边卡片
          ...images.sublist(currentCenterIndex).reversed.map((item) {
            return _buildCard(item);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCard(Widget item,) {
    final double leftPosition = _getCardPosition(item);
    final Matrix4 transform = _getTransform(item);

    return Positioned(
      key: ValueKey(item),
      left: leftPosition,
      child: Transform(
        transform: transform,
        alignment: FractionalOffset.center,
        child: SizedBox(width: cardSize, height: cardSize, child: item),
      ),
    );
  }

  double _getCardPosition(Widget item) {
    final double centerCardLeftPostion = maxWidth / 2 - cardSize / 2;

    // 获取当前卡片索引
    final int cardIndex = images.indexOf(item);
    // 当前页面索引
    int pageIndex = (pagePositon + 0.5).toInt();

    bool rightScroll = pageIndex - pagePositon > 0 ? true : false;
    bool isLeftCard = cardIndex == pageIndex
        ? !rightScroll
        : cardIndex < pageIndex;

    // 页面滑动百分比，左负，右正
    double pageScrollPercentage = (pageIndex - pagePositon).abs();
    double basePostion;
    double deltaPosition;

    // 中心卡片
    if (cardIndex == pageIndex) {
      basePostion = centerCardLeftPostion;
      deltaPosition = rightScroll ? nearByCardGapWidth : -nearByCardGapWidth;
      // 中心左右卡片
    } else if ((cardIndex - pageIndex).abs() == 1) {
      basePostion = centerCardLeftPostion + (isLeftCard ? -1 : 1) * nearByCardGapWidth;
      deltaPosition = isLeftCard
          ? rightScroll ? nearByCardGapWidth : -farCardGapWidth
          : rightScroll ? farCardGapWidth : -nearByCardGapWidth;
    // 其余卡片
    } else {
      basePostion = centerCardLeftPostion + (isLeftCard ? -1 : 1) * (nearByCardGapWidth + farCardGapWidth * ((cardIndex - pageIndex).abs() - 1));
      deltaPosition = rightScroll ? farCardGapWidth : -farCardGapWidth;
    }

    return basePostion + deltaPosition * pageScrollPercentage;
  }

  Matrix4 _getTransform(Widget item) {
    // 获取当前卡片索引
    final int cardIndex = images.indexOf(item);
    // 当前页面索引
    int pageIndex = (pagePositon + 0.5).toInt();

    bool rightScroll = pageIndex - pagePositon > 0 ? true : false;
    bool isLeftCard = cardIndex == pageIndex
        ? !rightScroll
        : cardIndex < pageIndex;

    // 页面滑动百分比，左负，右正
    double pageScrollPercentage = (pageIndex - pagePositon).abs();
    double baseAngle;
    double deltaAngle;

    // 中心卡片
    if (cardIndex == pageIndex) {
      baseAngle = 0;
      deltaAngle = rightScroll ? nearByCardAngle : -nearByCardAngle;
    // 中心左右卡片
    } else if ((cardIndex - pageIndex).abs() == 1.0) {
      baseAngle = isLeftCard ? -nearByCardAngle : nearByCardAngle;
      deltaAngle = isLeftCard
          ? rightScroll ? nearByCardAngle : (nearByCardAngle - farCardAngle)
          : rightScroll ? -(nearByCardAngle - farCardAngle) : -nearByCardAngle;
    // 中心左右卡片2
    } else if ((cardIndex - pageIndex).abs() == 2) {
      baseAngle = isLeftCard ? -farCardAngle : farCardAngle;
      deltaAngle = isLeftCard
          ? rightScroll ? -(nearByCardAngle - farCardAngle) : 0
          : rightScroll ? 0 : (nearByCardAngle - farCardAngle);
    // 其余卡片
    } else {
      baseAngle = isLeftCard ? -farCardAngle : farCardAngle;
      deltaAngle = 0;
    }

    double angle = baseAngle + deltaAngle * pageScrollPercentage;
    double centerOffset = isLeftCard ? cardSize / 2 : -cardSize/2;

    return Matrix4.identity()
      ..translate(-centerOffset)
      ..setEntry(3, 2, 0.001)
      ..rotateY(angle)
      ..translate(centerOffset)
    ;
  }


// Widget _buildReflectionWidget(
//     double width, double height, int index, Widget child) {
//   return Transform(
//     // Transform widget
//     transform: getTransform(index),
//     alignment: FractionalOffset.center,
//     child: Container(
//       height: currentPagePosition == index ? height + 10 : height,
//       width: width,
//       child: child,
//     ), // <<< set your widget here
//   );
// }
}
