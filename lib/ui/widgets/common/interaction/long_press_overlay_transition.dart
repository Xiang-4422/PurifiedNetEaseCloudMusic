import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

/// 长按时从原位置展开覆盖层，避免每个需要预览的入口各自维护一套 overlay 动画。
class LongPressOverlayTransition extends StatefulWidget {
  /// 触发长按的原始子组件。
  final Widget child;

  /// 构建展开后的覆盖层内容。
  final Widget Function(BuildContext context) builder;

  /// 覆盖层目标宽度。
  final double targetWidth;

  /// 覆盖层目标高度。
  final double targetHeight;

  /// 展开和收起动画时长。
  final Duration duration;

  /// 覆盖层关闭后的回调。
  final VoidCallback? onDismiss;

  /// 创建长按展开覆盖层组件。
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
  State<LongPressOverlayTransition> createState() => _LongPressOverlayTransitionState();
}

class _LongPressOverlayTransitionState extends State<LongPressOverlayTransition> with SingleTickerProviderStateMixin {
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
    _opacityAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay() {
    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final startRect = offset & size;
    final endRect = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: widget.targetWidth,
      height: widget.targetHeight,
    );

    _rectAnimation = RectTween(begin: startRect, end: endRect).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            FadeTransition(
              opacity: _opacityAnimation,
              child: GestureDetector(
                onTap: _hideOverlay,
                child: BlurryContainer(
                  padding: EdgeInsets.zero,
                  color: Colors.white60,
                  child: Container(),
                ),
              ),
            ),
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

  Future<void> _hideOverlay() async {
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
