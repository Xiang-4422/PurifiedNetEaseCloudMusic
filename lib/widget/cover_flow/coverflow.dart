library coverflow;

import 'dart:math';

import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:bujuan/pages/home/bottom_panel/bottom_panel_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:get/get.dart';

class CoverFlow extends StatefulWidget {
  final List<Widget> images;
  final double cardSize;
  final bool enableListViewScrolling; // 是否启用ListView式滑动

  const CoverFlow({
    super.key,
    required this.images,
    required this.cardSize,
    this.enableListViewScrolling = false,  // 默认使用PageView式滑动
  });

  @override
  State<CoverFlow> createState() => _CoverFlowState();
}
class _CoverFlowState extends State<CoverFlow> {
  PageController? _pageController;
  ScrollController? _scrollController;
  double _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.enableListViewScrolling) {
      _scrollController = ScrollController()
        ..addListener(() {
          setState(() {
            _currentPageIndex = min(_scrollController!.offset / widget.cardSize, widget.images.length - 1) ;
          });
        });
    } else {
      _pageController = PageController(initialPage: _currentPageIndex.toInt())
        ..addListener(() {
          setState(() {
            _currentPageIndex = _pageController!.page ?? 0;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: <Widget>[
            CoverFlowCardItems(
              images: widget.images,
              pagePositon: _currentPageIndex,
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,

              // 卡片尺寸
              cardSize: widget.cardSize,
              nearByCardGapWidth: widget.cardSize / 2,
              farCardGapWidth: widget.cardSize * 2 / 5,
              // 卡片偏转角度
              nearByCardAngle: pi / 2 * 1 / 3,
              farCardAngle: pi / 2 * 2 / 3,

              enableListViewScrolling: widget.enableListViewScrolling,
            ),
            // 根据模式选择不同的滚动实现
            Positioned.fill(
              child: widget.enableListViewScrolling
                  ? _buildListViewScrolling(constraints)
                  : _buildPageViewScrolling(),
            ),
          ],
        );
      },
    );
  }
  // PageView滚动实现
  Widget _buildPageViewScrolling() {
    return PageView.builder(
      itemCount: widget.images.length,
      controller: _pageController,
      onPageChanged: (index) {
        print('PageView onPageChanged: $index');
      },
      itemBuilder: (context, index) {
        return GestureDetector(
          onPanStart: (details) {
            print('PageView 手势开始: ${details.localPosition}');
          },
          onPanUpdate: (details) {
            print('PageView 手势更新: ${details.delta}');
          },
          onPanEnd: (details) {
            print(
                'PageView 手势结束: velocity=${details.velocity.pixelsPerSecond}');
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent, // 设为透明，只用于手势检测
          ),
        );
      },
    );
  }
  // ListView式滚动实现
  Widget _buildListViewScrolling(BoxConstraints constraints) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: SnappingScrollPhysics(itemExtent: widget.cardSize),
        child: SizedBox(
          width: widget.images.length * widget.cardSize + (constraints.maxWidth - widget.cardSize),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _scrollController?.dispose();
    super.dispose();
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
  final bool enableListViewScrolling;

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
    this.enableListViewScrolling = false,
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
          ...images
              .sublist(max(0, currentCenterIndex - 6), currentCenterIndex)
              .map((item) {
            return _buildCard(item);
          }).toList(),
          // 中心卡片及其右边卡片
          ...images
              .sublist(currentCenterIndex,
                  min(images.length, currentCenterIndex + 7))
              .reversed
              .map((item) {
            return _buildCard(item);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCard(Widget item) {
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
    bool isLeftCard =
        cardIndex == pageIndex ? !rightScroll : cardIndex < pageIndex;

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
      basePostion =
          centerCardLeftPostion + (isLeftCard ? -1 : 1) * nearByCardGapWidth;
      deltaPosition = isLeftCard
          ? rightScroll
              ? nearByCardGapWidth
              : -farCardGapWidth
          : rightScroll
              ? farCardGapWidth
              : -nearByCardGapWidth;
      // 其余卡片
    } else {
      basePostion = centerCardLeftPostion +
          (isLeftCard ? -1 : 1) *
              (nearByCardGapWidth +
                  farCardGapWidth * ((cardIndex - pageIndex).abs() - 1));
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
    bool isLeftCard =
        cardIndex == pageIndex ? !rightScroll : cardIndex < pageIndex;

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
          ? rightScroll
              ? nearByCardAngle
              : (nearByCardAngle - farCardAngle)
          : rightScroll
              ? -(nearByCardAngle - farCardAngle)
              : -nearByCardAngle;
      // 中心左右卡片2
    } else if ((cardIndex - pageIndex).abs() == 2) {
      baseAngle = isLeftCard ? -farCardAngle : farCardAngle;
      deltaAngle = isLeftCard
          ? rightScroll
              ? -(nearByCardAngle - farCardAngle)
              : 0
          : rightScroll
              ? 0
              : (nearByCardAngle - farCardAngle);
      // 其余卡片
    } else {
      baseAngle = isLeftCard ? -farCardAngle : farCardAngle;
      deltaAngle = 0;
    }

    double angle = baseAngle + deltaAngle * pageScrollPercentage;
    double centerOffset = isLeftCard ? cardSize / 2 : -cardSize / 2;

    return Matrix4.identity()
      ..translate(-centerOffset)
      ..setEntry(3, 2, 0.001)
      ..rotateY(angle)
      ..translate(centerOffset);
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