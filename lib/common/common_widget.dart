import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants/other.dart';

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