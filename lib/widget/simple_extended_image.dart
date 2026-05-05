import 'dart:io';

import 'package:bujuan/common/constants/images.dart';
import 'package:bujuan/core/storage/local_image_cache_repository.dart';
import 'package:bujuan/core/diagnostics/playback_performance_logger.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

/// 本地缓存图片展示组件。
///
/// 这个组件最终只使用本地文件渲染图片，并提供统一的裁剪、占位和解码尺寸控制。
/// 调用方应优先传入本地封面路径或其他已落盘路径；如果传入远程 URL，
/// 组件会先通过应用本地图片缓存落盘，再用缓存文件显示，不会直接使用网络图片 Provider 渲染。
///
/// 空字符串或缓存失败时会显示占位。
class SimpleExtendedImage extends StatefulWidget {
  /// 本地文件路径、`file://` URI 或需要写入应用本地图片缓存的远程 URL。
  ///
  /// 远程 URL 不会被直接交给图片组件渲染。
  final String url;

  /// 组件期望宽度。
  final double? width;

  /// 组件期望高度。
  final double? height;

  /// 自定义 asset 占位图。
  ///
  /// 默认封面占位会渲染主题色背景和音符图标；只有传入非默认 asset 时才显示图片。
  final String placeholder;

  /// 裁剪形状，支持矩形和圆形。
  final BoxShape shape;

  /// 矩形图片的圆角；圆形图片会忽略该值。
  final BorderRadius? borderRadius;

  /// 自定义占位内容，优先级高于 [placeholder]。
  final Widget? replacement;

  /// 图片填充方式。
  final BoxFit? fit;

  /// 图片解码缓存尺寸，用于控制大图内存占用。
  final int? cacheWidth;

  /// 图片解码缓存高度，用于控制大图内存占用。
  final int? cacheHeight;

  /// 用于封面、歌单、专辑等普通本地图片。
  const SimpleExtendedImage(this.url,
      {Key? key,
      this.width,
      this.height,
      this.placeholder = placeholderImage,
      this.replacement,
      this.fit,
      this.shape = BoxShape.rectangle,
      this.borderRadius,
      this.cacheWidth,
      this.cacheHeight})
      : super(key: key);

  /// 用于头像展示。
  ///
  /// 头像默认使用圆形裁剪，并保留独立头像占位图。
  const SimpleExtendedImage.avatar(this.url,
      {Key? key,
      this.width,
      this.height,
      this.placeholder = avatarPlaceholderImage,
      this.replacement,
      this.fit,
      this.shape = BoxShape.circle,
      this.borderRadius,
      this.cacheWidth = 300,
      this.cacheHeight})
      : super(key: key);

  @override
  SimpleExtendedImageState createState() {
    return SimpleExtendedImageState();
  }
}

/// SimpleExtendedImage 的状态对象，负责解析本地图片缓存路径。
class SimpleExtendedImageState extends State<SimpleExtendedImage> {
  static final LocalImageCacheRepository _imageCacheRepository =
      LocalImageCacheRepository();

  String _resolvedPath = '';
  int _resolveVersion = 0;

  @override
  void initState() {
    super.initState();
    _resolvedPath =
        _imageCacheRepository.peekResolvedImagePath(widget.url.trim()) ?? '';
    _resolveImagePath();
  }

  @override
  void didUpdateWidget(covariant SimpleExtendedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _resolvedPath =
          _imageCacheRepository.peekResolvedImagePath(widget.url.trim()) ?? '';
      _resolveImagePath();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = widget.width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        final height = widget.height ??
            (constraints.hasBoundedHeight ? constraints.maxHeight : null);
        final fit = widget.fit ?? BoxFit.cover;
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        final cacheWidth = _resolveCacheDimension(
          logicalSize: width,
          override: widget.cacheWidth,
          devicePixelRatio: devicePixelRatio,
        );
        final cacheHeight = _resolveCacheDimension(
          logicalSize: height,
          override: widget.cacheHeight,
          devicePixelRatio: devicePixelRatio,
        );

        if (_resolvedPath.isEmpty) {
          return _clip(
              _buildPlaceholder(context, width: width, height: height));
        }

        final image = ExtendedImage.file(
          File(_resolvedPath),
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          borderRadius: widget.borderRadius,
          width: width,
          height: height,
          fit: fit,
          loadStateChanged: (state) {
            Widget image;
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                image =
                    _buildPlaceholder(context, width: width, height: height);
                break;
              case LoadState.completed:
                image = ExtendedRawImage(
                  image: state.extendedImageInfo?.image,
                  width: width,
                  height: height,
                  fit: fit,
                );
                break;
              case LoadState.failed:
                image =
                    _buildPlaceholder(context, width: width, height: height);
                break;
            }
            return image;
          },
        );
        return _clip(image);
      },
    );
  }

  Future<void> _resolveImagePath() async {
    final stopwatch = PlaybackPerformanceLogger.start();
    final resolveVersion = ++_resolveVersion;
    final rawPath = widget.url.trim();
    if (rawPath.isEmpty) {
      if (mounted) {
        setState(() {
          _resolvedPath = '';
        });
      }
      return;
    }

    final resolvedPath = await _imageCacheRepository
        .resolveImagePath(rawPath)
        .catchError((_) => '');
    if (!mounted || resolveVersion != _resolveVersion) {
      return;
    }
    if (_resolvedPath != resolvedPath) {
      setState(() {
        _resolvedPath = resolvedPath;
      });
    }
    PlaybackPerformanceLogger.elapsed(
      'image.resolvePath',
      stopwatch,
      details:
          'remote=${rawPath.startsWith('http://') || rawPath.startsWith('https://')} resolved=${resolvedPath.isNotEmpty}',
      warnAfterMs: 8,
    );
  }

  Widget _clip(Widget child) {
    return widget.shape == BoxShape.circle
        ? ClipOval(child: child)
        : ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
            child: child,
          );
  }

  Widget _buildPlaceholder(
    BuildContext context, {
    required double? width,
    required double? height,
  }) {
    if (widget.replacement != null) {
      return SizedBox(
        width: width,
        height: height,
        child: widget.replacement,
      );
    }

    if (widget.placeholder != placeholderImage) {
      return Image.asset(
        widget.placeholder,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Icon(
            Icons.music_note_rounded,
            size: _placeholderIconSize(width: width, height: height),
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  double _placeholderIconSize({
    required double? width,
    required double? height,
  }) {
    final shortestSide = [
      if (width != null) width,
      if (height != null) height,
    ].fold<double?>(null, (value, element) {
      if (value == null || element < value) {
        return element;
      }
      return value;
    });
    if (shortestSide == null) {
      return 24;
    }
    return (shortestSide * 0.36).clamp(18, 48).toDouble();
  }

  int? _resolveCacheDimension({
    required double? logicalSize,
    required int? override,
    required double devicePixelRatio,
  }) {
    if (override != null) {
      return override.clamp(1, 1080).toInt();
    }
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    return (logicalSize * devicePixelRatio).round().clamp(1, 1080).toInt();
  }
}
