import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math; // 导入数学库，用于计算π

import '../pages/home/body/body_pages/personal_page.dart';
import '../routes/router.gr.dart' as gr;
import '../widget/keep_alive_wrapper.dart';
import '../widget/simple_extended_image.dart';
import 'constants/appConstants.dart';
import 'constants/other.dart';
import 'netease_api/src/api/play/bean.dart';

/// 通用的长按缩放组件
class PressScaleWidget extends StatefulWidget {
  final Widget child;
  final double scaleFactor; // 缩放系数，默认 0.95
  final Duration duration; // 动画时长
  final VoidCallback? onTap; // 点击回调
  final VoidCallback? onLongPress; // 长按回调

  const PressScaleWidget({
    Key? key,
    required this.child,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<PressScaleWidget> createState() => _PressScaleWidgetState();
}
class _PressScaleWidgetState extends State<PressScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: widget.scaleFactor,
      upperBound: 1.0,
    );
    _controller.value = 1.0; // 初始为正常大小
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _controller.reverse(); // 缩小
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _controller.forward(); // 恢复
    widget.onLongPress?.call();
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}

/// 通用组件：长按 child 时，获取其位置和尺寸，在 Overlay 上渲染一个动画过渡到目标 widget
class LongPressOverlayTransition extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context) builder;
  final double targetWidth;
  final double targetHeight;
  final Duration duration;
  final VoidCallback? onDismiss;

  const LongPressOverlayTransition({
    Key? key,
    required this.child,
    required this.builder,
    this.targetWidth = 300,
    this.targetHeight = 400,
    this.duration = const Duration(milliseconds: 400),
    this.onDismiss,
  }) : super(key: key);

  @override
  State<LongPressOverlayTransition> createState() =>
      _LongPressOverlayTransitionState();
}
class _LongPressOverlayTransitionState
    extends State<LongPressOverlayTransition>
    with SingleTickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<Rect?> _rectAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay() {
    RenderBox renderBox =
    _childKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    Rect startRect = offset & size; // 初始位置
    Rect endRect = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: widget.targetWidth,
      height: widget.targetHeight,
    );

    _rectAnimation =
        RectTween(begin: startRect, end: endRect).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // 背景淡入淡出
            FadeTransition(
              opacity: _opacityAnimation,
              child: GestureDetector(
                onTap: _hideOverlay,
                child: Container(color: Colors.black54),
              ),
            ),
            // 过渡中的 widget
            AnimatedBuilder(
              animation: _rectAnimation,
              builder: (context, child) {
                final rect = _rectAnimation.value!;
                return Positioned.fromRect(
                  rect: rect,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Material(
                      color: Colors.white,
                      elevation: 12,
                      borderRadius: BorderRadius.circular(16),
                      child: widget.builder(context),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward(from: 0);
  }

  void _hideOverlay() async {
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _childKey,
      onLongPress: _showOverlay,
      child: widget.child,
    );
  }
}

class AsyncImageColor extends StatefulWidget {
  final String imageUrl;
  final bool getLightColor;
  final Widget? child;

  const AsyncImageColor({
    Key? key,
    required this.imageUrl,
    this.getLightColor = false,
    this.child,
  }) : super(key: key);

  @override
  State<AsyncImageColor> createState() => _AsyncImageColorState();
}
class _AsyncImageColorState extends State<AsyncImageColor> {
  Color _bgColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _loadColor();
  }

  @override
  void didUpdateWidget(covariant AsyncImageColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 imageUrl 或 getLightColor 改变时，重新获取颜色
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.getLightColor != widget.getLightColor) {
      _loadColor();
    }
  }

  Future<void> _loadColor() async {
    final color = await OtherUtils.getImageColor(widget.imageUrl, getLightColor: widget.getLightColor);
    if (mounted) {
      setState(() {
        _bgColor = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      child: widget.child,
    );
  }
}

/// 环形播放进度条组件
class CircularPlaybackProgress extends StatelessWidget {
  /// 当前播放进度，范围从 0.0 到 1.0
  final double progress;

  /// 进度条的线条宽度
  final double strokeWidth;

  /// 进度条背景（未填充部分）的颜色
  final Color backgroundColor;

  /// 进度条填充部分的颜色
  final Color progressColor;

  /// 整个组件的宽度和高度（因为是圆形，所以宽高相等）
  final double size;

  /// 进度百分比文本的样式
  final TextStyle? percentageTextStyle;

  const CircularPlaybackProgress({
    Key? key,
    required this.progress,
    this.strokeWidth = 8.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.size = 100.0, // 默认大小
    this.percentageTextStyle,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用SizedBox来固定组件的尺寸
    return SizedBox(
      width: size,
      height: size,
      // 使用Stack来叠加CustomPaint（绘制环形）和Text（显示百分比）
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
        ),
      ),
    );
  }
}
/// 实际绘制环形进度条的CustomPainter
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算圆心和半径
    final center = Offset(size.width / 2, size.height / 2);
    // 半径需要减去一半的线条宽度，以确保线条完全在组件边界内
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // 定义绘制背景圆弧的画笔
    final backgroundPaint = Paint()
      ..color = backgroundColor // 背景颜色
      ..strokeWidth = strokeWidth // 线条宽度
      ..style = PaintingStyle.stroke // 绘制样式为描边
      ..strokeCap = StrokeCap.round; // 线条末端为圆形（可选，使外观更平滑）

    // 定义绘制进度圆弧的画笔
    final progressPaint = Paint()
      ..color = progressColor // 进度颜色
      ..strokeWidth = strokeWidth // 线条宽度
      ..style = PaintingStyle.stroke // 绘制样式为描边
      ..strokeCap = StrokeCap.round; // 线条末端为圆形

    // 绘制背景圆（完整的圆）
    canvas.drawCircle(center, radius, backgroundPaint);

    // 定义用于绘制圆弧的矩形边界
    // Rect.fromCircle(center: center, radius: radius) 创建一个以center为中心，radius为半径的圆形边界
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 绘制进度圆弧
    // startAngle: 圆弧的起始角度，-math.pi / 2 表示从顶部（12点钟方向）开始
    // sweepAngle: 圆弧的扫描角度，progress * 2 * math.pi 表示根据进度填充的弧度
    // useCenter: false 表示不连接圆心，只绘制弧线
    canvas.drawArc(
      rect,
      -math.pi / 2, // 从顶部开始
      2 * math.pi * progress, // 扫描角度 = 完整圆周 * 进度
      false, // 不连接圆心
      progressPaint,
    );
  }

  @override
  // 决定是否需要重新绘制。只有当相关属性发生变化时才重新绘制，以优化性能。
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

/// 专辑列表
/// 根据父容器宽度，自适应组件
class PlayListWidget extends StatelessWidget {
  final double albumCountInWidget;
  final double albumMargin;
  final List<PlayList> playLists;
  final bool showSongCount;
  final bool snappAllAlbum;

  const PlayListWidget({
    Key? key,
    required this.playLists,
    required this.albumCountInWidget,
    required this.albumMargin,
    this.showSongCount = true,
    this.snappAllAlbum = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {

        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;

        final double albumWidth = (maxWidth - albumMargin * albumCountInWidget.ceil()) / albumCountInWidget;

        return SizedBox(
          height: albumWidth * 1.3,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            physics: SnappingScrollPhysics(itemExtent: (albumWidth + albumMargin) * (snappAllAlbum ? albumCountInWidget.floor() : 1)),
            slivers: [
              SliverPadding(
                padding: EdgeInsetsGeometry.only(left: albumMargin),
                sliver: SliverList.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: playLists.length,
                  itemBuilder: (context, index) {
                    return KeepAliveWrapper(
                      child: Container(
                        width: albumWidth,
                        margin: EdgeInsets.only(right: albumMargin,),
                        child: GestureDetector(
                          onTap: () {
                            context.router.push(gr.PlayListRouteView(playList: playLists[index]));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SimpleExtendedImage.avatar(
                                  width: albumWidth,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(albumMargin),
                                  '${playLists[index].coverImgUrl ?? playLists[index].picUrl}?param=200y200'
                              ),
                              SizedBox(height: albumWidth * 0.04),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${playLists[index].name}",
                                    maxLines: showSongCount ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: albumWidth * 0.13 - 1,
                                      height: 1,
                                    ),
                                  ),
                                  showSongCount
                                      ? Text(
                                        "${playLists[index].trackCount == null || playLists[index].trackCount == 0 ? null : "${playLists[index].trackCount}首"}",
                                        maxLines: 1,
                                        style: context.textTheme.bodySmall,
                                      )
                                      : Container(),
                                ],
                              ))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
