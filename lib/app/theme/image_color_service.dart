import 'dart:io';

import 'package:bujuan/common/constants/images.dart';
import 'package:bujuan/core/storage/image_color_cache_store.dart';
import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// 图片取色服务，提供主色解析、缓存读取和批量预热能力。
class ImageColorService {
  ImageColorService._();

  static const ImageColorCacheStore _cacheStore = ImageColorCacheStore();
  static final Map<String, Color> _memoryCache = {};
  static final Map<String, Future<Color>> _pendingLoads = {};

  /// 从本地图片生成调色板；远程或空地址会退回占位图。
  static Future<PaletteGenerator> palette(String? url) async {
    ImageProvider imageProvider;
    if (url == null || url.isEmpty || _isRemoteImageUrl(url)) {
      imageProvider = const ExtendedAssetImageProvider(placeholderImage);
    } else {
      final normalizedUrl = ImageUrlNormalizer.normalize(url);
      imageProvider =
          ExtendedFileImageProvider(File(normalizedUrl.split('?').first));
    }
    return PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(100, 100),
    );
  }

  /// 获取图片主色，可按需要优先返回亮色或暗色。
  static Future<Color> dominantColor(
    String? url, {
    bool getLightColor = false,
  }) async {
    final normalizedUrl = ImageUrlNormalizer.normalize(url);
    if (_isRemoteImageUrl(normalizedUrl)) {
      return getLightColor ? Colors.white : Colors.black;
    }
    final cacheKey = '$normalizedUrl|${getLightColor ? 'light' : 'dark'}';

    final memoryCached = _memoryCache[cacheKey];
    if (memoryCached != null) {
      return memoryCached;
    }

    final diskCached = _cacheStore.load(
      imageUrl: normalizedUrl,
      getLightColor: getLightColor,
    );
    if (diskCached != null) {
      _remember(cacheKey, diskCached);
      return diskCached;
    }

    final pending = _pendingLoads[cacheKey];
    if (pending != null) {
      return pending;
    }

    final future = palette(normalizedUrl).then((paletteGenerator) async {
      final color = getLightColor
          ? paletteGenerator.lightMutedColor?.color ??
              paletteGenerator.lightVibrantColor?.color ??
              paletteGenerator.dominantColor?.color ??
              Colors.white
          : paletteGenerator.darkMutedColor?.color ??
              paletteGenerator.darkVibrantColor?.color ??
              paletteGenerator.dominantColor?.color ??
              Colors.black;
      _remember(cacheKey, color);
      if (normalizedUrl.isNotEmpty) {
        await _cacheStore.save(
          imageUrl: normalizedUrl,
          getLightColor: getLightColor,
          color: color,
        );
      }
      return color;
    }).whenComplete(() {
      _pendingLoads.remove(cacheKey);
    });
    _pendingLoads[cacheKey] = future;
    return future;
  }

  /// 仅读取已缓存的主色，不触发新的取色计算。
  static Color? peekCachedColor(
    String? url, {
    bool getLightColor = false,
  }) {
    final normalizedUrl = ImageUrlNormalizer.normalize(url);
    final cacheKey = '$normalizedUrl|${getLightColor ? 'light' : 'dark'}';

    final memoryCached = _memoryCache[cacheKey];
    if (memoryCached != null) {
      return memoryCached;
    }

    final diskCached = _cacheStore.load(
      imageUrl: normalizedUrl,
      getLightColor: getLightColor,
    );
    if (diskCached != null) {
      _remember(cacheKey, diskCached);
      return diskCached;
    }
    return null;
  }

  /// 批量预热图片主色缓存。
  static Future<void> prewarm(
    Iterable<String?> urls, {
    bool getLightColor = false,
  }) async {
    final normalizedUrls = urls
        .map(ImageUrlNormalizer.normalize)
        .where((url) => url.isNotEmpty && !_isRemoteImageUrl(url))
        .toSet()
        .toList();
    if (normalizedUrls.isEmpty) {
      return;
    }
    await Future.wait(
      normalizedUrls.map(
        (url) => dominantColor(
          url,
          getLightColor: getLightColor,
        ),
      ),
    );
  }

  static void _remember(String cacheKey, Color color) {
    if (_memoryCache.length > 120) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[cacheKey] = color;
  }

  static bool _isRemoteImageUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}
