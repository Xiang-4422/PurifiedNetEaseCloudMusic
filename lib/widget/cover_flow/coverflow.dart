library coverflow;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bujuan/widget/scroll_helpers.dart';

/// 这是预留的封面流组件，当前主流程未接入，但后续如果恢复封面流交互，
/// 直接复用这里会比从页面里再拼一套 3D 列表更稳。
class CoverFlow extends StatefulWidget {
  final List<Widget> images;
  final double cardSize;
  final bool enableListViewScrolling;

  const CoverFlow({
    super.key,
    required this.images,
    required this.cardSize,
    this.enableListViewScrolling = false,
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
            _currentPageIndex = min(
              _scrollController!.offset / widget.cardSize,
              widget.images.length - 1,
            );
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
              cardSize: widget.cardSize,
              nearByCardGapWidth: widget.cardSize / 2,
              farCardGapWidth: widget.cardSize * 2 / 5,
              nearByCardAngle: pi / 2 * 1 / 3,
              farCardAngle: pi / 2 * 2 / 3,
              enableListViewScrolling: widget.enableListViewScrolling,
            ),
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

  Widget _buildPageViewScrolling() {
    return PageView.builder(
      itemCount: widget.images.length,
      controller: _pageController,
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
        );
      },
    );
  }

  Widget _buildListViewScrolling(BoxConstraints constraints) {
    return ScrollConfiguration(
      behavior: const NoGlowScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: SnappingScrollPhysics(itemExtent: widget.cardSize),
        child: SizedBox(
          width: widget.images.length * widget.cardSize +
              (constraints.maxWidth - widget.cardSize),
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
          ...images
              .sublist(max(0, currentCenterIndex - 6), currentCenterIndex)
              .map((item) {
            return _buildCard(item);
          }).toList(),
          ...images
              .sublist(
                currentCenterIndex,
                min(images.length, currentCenterIndex + 7),
              )
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

    final int cardIndex = images.indexOf(item);
    int pageIndex = (pagePositon + 0.5).toInt();

    bool rightScroll = pageIndex - pagePositon > 0;
    bool isLeftCard =
        cardIndex == pageIndex ? !rightScroll : cardIndex < pageIndex;

    double pageScrollPercentage = (pageIndex - pagePositon).abs();
    double basePostion;
    double deltaPosition;

    if (cardIndex == pageIndex) {
      basePostion = centerCardLeftPostion;
      deltaPosition = rightScroll ? nearByCardGapWidth : -nearByCardGapWidth;
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
    final int cardIndex = images.indexOf(item);
    int pageIndex = (pagePositon + 0.5).toInt();

    bool rightScroll = pageIndex - pagePositon > 0;
    bool isLeftCard =
        cardIndex == pageIndex ? !rightScroll : cardIndex < pageIndex;

    double pageScrollPercentage = (pageIndex - pagePositon).abs();
    double baseAngle;
    double deltaAngle;

    if (cardIndex == pageIndex) {
      baseAngle = 0;
      deltaAngle = rightScroll ? nearByCardAngle : -nearByCardAngle;
    } else if ((cardIndex - pageIndex).abs() == 1.0) {
      baseAngle = isLeftCard ? -nearByCardAngle : nearByCardAngle;
      deltaAngle = isLeftCard
          ? rightScroll
              ? nearByCardAngle
              : (nearByCardAngle - farCardAngle)
          : rightScroll
              ? -(nearByCardAngle - farCardAngle)
              : -nearByCardAngle;
    } else if ((cardIndex - pageIndex).abs() == 2) {
      baseAngle = isLeftCard ? -farCardAngle : farCardAngle;
      deltaAngle = isLeftCard
          ? rightScroll
              ? -(nearByCardAngle - farCardAngle)
              : 0
          : rightScroll
              ? 0
              : (nearByCardAngle - farCardAngle);
    } else {
      baseAngle = isLeftCard ? -farCardAngle : farCardAngle;
      deltaAngle = 0;
    }

    double angle = baseAngle + deltaAngle * pageScrollPercentage;
    double centerOffset = isLeftCard ? cardSize / 2 : -cardSize / 2;

    return Matrix4.identity()
      ..translateByDouble(-centerOffset, 0, 0, 1)
      ..setEntry(3, 2, 0.001)
      ..rotateY(angle)
      ..translateByDouble(centerOffset, 0, 0, 1);
  }
}
