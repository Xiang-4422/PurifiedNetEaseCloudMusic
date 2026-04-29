import 'dart:math' as math;

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:flutter/material.dart';

/// 长按时从原位置展开覆盖层，避免每个需要预览的入口各自维护一套 overlay 动画。
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

class _LongPressOverlayTransitionState extends State<LongPressOverlayTransition>
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
    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final startRect = offset & size;
    final endRect = Rect.fromCenter(
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

/// 这里保留“图片异步取色 + 包裹 child”的组合，是为了让页面只关心结果，不重复维护取色生命周期。
class AsyncImageColor extends StatefulWidget {
  final String imageUrl;
  final bool getLightColor;
  final Widget? child;
  final Color fallbackColor;
  final bool deferLoadUntilPostFrame;

  const AsyncImageColor({
    Key? key,
    required this.imageUrl,
    this.getLightColor = false,
    this.child,
    this.fallbackColor = Colors.transparent,
    this.deferLoadUntilPostFrame = true,
  }) : super(key: key);

  @override
  State<AsyncImageColor> createState() => _AsyncImageColorState();
}

class _AsyncImageColorState extends State<AsyncImageColor> {
  late Color _bgColor;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _bgColor = ImageColorService.peekCachedColor(
          widget.imageUrl,
          getLightColor: widget.getLightColor,
        ) ??
        widget.fallbackColor;
    _scheduleLoadColorIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AsyncImageColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.getLightColor != widget.getLightColor ||
        oldWidget.fallbackColor != widget.fallbackColor ||
        oldWidget.deferLoadUntilPostFrame != widget.deferLoadUntilPostFrame) {
      _bgColor = ImageColorService.peekCachedColor(
            widget.imageUrl,
            getLightColor: widget.getLightColor,
          ) ??
          widget.fallbackColor;
      _scheduleLoadColorIfNeeded();
    }
  }

  void _scheduleLoadColorIfNeeded() {
    final cachedColor = ImageColorService.peekCachedColor(
      widget.imageUrl,
      getLightColor: widget.getLightColor,
    );
    if (cachedColor != null) {
      if (_bgColor != cachedColor && mounted) {
        setState(() {
          _bgColor = cachedColor;
        });
      }
      return;
    }
    if (widget.deferLoadUntilPostFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _loadColor();
      });
      return;
    }
    _loadColor();
  }

  Future<void> _loadColor() async {
    final loadVersion = ++_loadVersion;
    final color = await ImageColorService.dominantColor(
      widget.imageUrl,
      getLightColor: widget.getLightColor,
    );
    if (mounted && loadVersion == _loadVersion) {
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

/// 下载页和播放面板都只需要消费“0 到 1 的进度结果”，绘制细节集中在这里更稳定。
class CircularPlaybackProgress extends StatelessWidget {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final double size;
  final TextStyle? percentageTextStyle;

  const CircularPlaybackProgress({
    Key? key,
    required this.progress,
    this.strokeWidth = 8.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.size = 100.0,
    this.percentageTextStyle,
  })  : assert(progress >= 0.0 && progress <= 1.0,
            'Progress must be between 0.0 and 1.0'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
