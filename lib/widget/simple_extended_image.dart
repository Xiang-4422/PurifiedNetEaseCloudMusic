import 'dart:io';

import 'package:bujuan/common/constants/images.dart';
import 'package:bujuan/core/storage/local_image_cache_repository.dart';
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
      this.cacheWidth})
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
      this.cacheWidth = 300})
      : super(key: key);

  @override
  SimpleExtendedImageState createState() {
    return SimpleExtendedImageState();
  }
}

/// SimpleExtendedImageState。
class SimpleExtendedImageState extends State<SimpleExtendedImage> {
  static final LocalImageCacheRepository _imageCacheRepository =
      LocalImageCacheRepository();

  String _resolvedPath = '';
  int _resolveVersion = 0;

  @override
  void initState() {
    super.initState();
    _resolveImagePath();
  }

  @override
  void didUpdateWidget(covariant SimpleExtendedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _resolveImagePath();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedPath.isEmpty) {
      return _clip(_buildPlaceholder(context));
    }

    final image = ExtendedImage.file(
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheWidth,
      borderRadius: widget.borderRadius,
      File(_resolvedPath),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadStateChanged: (state) {
        Widget image;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            image = _buildPlaceholder(context);
            break;
          case LoadState.completed:
            image = ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            );
            break;
          case LoadState.failed:
            image = _buildPlaceholder(context);
            break;
        }
        return image;
      },
    );
    return _clip(image);
  }

  Future<void> _resolveImagePath() async {
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

    final resolvedPath = await _imageCacheRepository.resolveImagePath(rawPath);
    if (!mounted || resolveVersion != _resolveVersion) {
      return;
    }
    setState(() {
      _resolvedPath = resolvedPath;
    });
  }

  Widget _clip(Widget child) {
    return widget.shape == BoxShape.circle
        ? ClipOval(child: child)
        : ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
            child: child,
          );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (widget.replacement != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.replacement,
      );
    }

    if (widget.placeholder != placeholderImage) {
      return Image.asset(
        widget.placeholder,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Icon(
            Icons.music_note_rounded,
            size: _placeholderIconSize,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  double get _placeholderIconSize {
    final shortestSide = [
      if (widget.width != null) widget.width!,
      if (widget.height != null) widget.height!,
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
}
