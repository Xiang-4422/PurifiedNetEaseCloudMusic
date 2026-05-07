import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:flutter/material.dart';

/// 这里保留“图片异步取色 + 包裹 child”的组合，是为了让页面只关心结果，不重复维护取色生命周期。
class AsyncImageColor extends StatefulWidget {
  /// 用于取色的图片地址。
  final String imageUrl;

  /// 是否获取偏亮的主色。
  final bool getLightColor;

  /// 包裹在取色背景上的子组件。
  final Widget? child;

  /// 无法取色时使用的背景色。
  final Color fallbackColor;

  /// 是否延迟到首帧后再取色。
  final bool deferLoadUntilPostFrame;

  /// 创建异步图片取色背景组件。
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
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.getLightColor != widget.getLightColor || oldWidget.fallbackColor != widget.fallbackColor || oldWidget.deferLoadUntilPostFrame != widget.deferLoadUntilPostFrame) {
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
