import 'dart:collection';
import 'dart:io';

import 'package:bujuan/data/app_storage/image_color_cache_store.dart';
import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/ui/assets/app_assets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// 图片取色服务，提供主色解析、缓存读取和批量预热能力。
class ImageColorService {
  ImageColorService._();

  static const ImageColorCacheStore _cacheStore = ImageColorCacheStore();
  static final ImageColorMemoryCache _memoryCache = ImageColorMemoryCache(maxEntries: 120);
  static final Map<String, Future<Color>> _pendingLoads = {};

  /// 从本地图片生成调色板；远程或空地址会退回占位图。
  static Future<PaletteGenerator> palette(String? url) async {
    ImageProvider imageProvider;
    if (url == null || url.isEmpty || _isRemoteImageUrl(url)) {
      imageProvider = const ExtendedAssetImageProvider(AppAssets.imagesPlaceholder);
    } else {
      final normalizedUrl = LocalFilePathNormalizer.normalize(url);
      if (normalizedUrl.isEmpty || !File(normalizedUrl).existsSync()) {
        imageProvider = const ExtendedAssetImageProvider(AppAssets.imagesPlaceholder);
      } else {
        imageProvider = ExtendedFileImageProvider(File(normalizedUrl));
      }
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
    final normalizedSource = normalizeColorCacheSource(url);
    if (_isRemoteImageUrl(normalizedSource)) {
      return getLightColor ? Colors.white : Colors.black;
    }
    if (_isUnavailableLocalImage(normalizedSource)) {
      return _fallbackColor(getLightColor);
    }
    final cacheKey = '$normalizedSource|${getLightColor ? 'light' : 'dark'}';

    final memoryCached = _memoryCache.read(cacheKey);
    if (memoryCached != null) {
      return memoryCached;
    }

    final diskCached = _loadDiskCachedColor(
      imageUrl: normalizedSource,
      getLightColor: getLightColor,
    );
    if (diskCached != null) {
      final color = Color(diskCached);
      _remember(cacheKey, color);
      return color;
    }

    final pending = _pendingLoads[cacheKey];
    if (pending != null) {
      return pending;
    }

    final future = _loadDominantColor(
      normalizedSource,
      cacheKey: cacheKey,
      getLightColor: getLightColor,
    ).whenComplete(() {
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
    final normalizedSource = normalizeColorCacheSource(url);
    if (normalizedSource.isEmpty) {
      return null;
    }
    if (_isRemoteImageUrl(normalizedSource)) {
      return null;
    }
    if (_isUnavailableLocalImage(normalizedSource)) {
      return null;
    }
    final cacheKey = '$normalizedSource|${getLightColor ? 'light' : 'dark'}';

    final memoryCached = _memoryCache.read(cacheKey);
    if (memoryCached != null) {
      return memoryCached;
    }

    final diskCached = _loadDiskCachedColor(
      imageUrl: normalizedSource,
      getLightColor: getLightColor,
    );
    if (diskCached != null) {
      final color = Color(diskCached);
      _remember(cacheKey, color);
      return color;
    }
    return null;
  }

  /// 批量预热图片主色缓存。
  static Future<void> prewarm(
    Iterable<String?> urls, {
    bool getLightColor = false,
  }) async {
    final normalizedUrls = urls.map(normalizeColorCacheSource).where((url) => url.isNotEmpty && !_isRemoteImageUrl(url)).toSet().toList();
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
    _memoryCache.remember(cacheKey, color);
  }

  /// 归一图片取色缓存来源。
  @visibleForTesting
  static String normalizeColorCacheSource(String? url) {
    final trimmedUrl = url?.trim() ?? '';
    if (trimmedUrl.isEmpty) {
      return '';
    }
    if (_isRemoteImageUrl(trimmedUrl)) {
      return ImageUrlNormalizer.normalize(trimmedUrl);
    }
    return LocalFilePathNormalizer.normalize(trimmedUrl);
  }

  static int? _loadDiskCachedColor({
    required String imageUrl,
    required bool getLightColor,
  }) {
    try {
      return _cacheStore.load(
        imageUrl: imageUrl,
        getLightColor: getLightColor,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Color> _loadDominantColor(
    String normalizedUrl, {
    required String cacheKey,
    required bool getLightColor,
  }) async {
    final PaletteGenerator paletteGenerator;
    try {
      paletteGenerator = await palette(normalizedUrl);
    } catch (_) {
      return _fallbackColor(getLightColor);
    }

    final color = _selectPaletteColor(
      paletteGenerator,
      getLightColor: getLightColor,
    );
    _remember(cacheKey, color);
    if (normalizedUrl.isNotEmpty) {
      try {
        await _cacheStore.save(
          imageUrl: normalizedUrl,
          getLightColor: getLightColor,
          argb32: color.toARGB32(),
        );
      } catch (_) {
        // 写入视觉缓存失败不能影响页面背景取色结果。
      }
    }
    return color;
  }

  static Color _selectPaletteColor(
    PaletteGenerator paletteGenerator, {
    required bool getLightColor,
  }) {
    if (getLightColor) {
      final lightMutedColor = paletteGenerator.lightMutedColor?.color;
      if (lightMutedColor != null) {
        return lightMutedColor;
      }
      final lightVibrantColor = paletteGenerator.lightVibrantColor?.color;
      if (lightVibrantColor != null) {
        return lightVibrantColor;
      }
      final dominantColor = paletteGenerator.dominantColor?.color;
      return dominantColor ?? _fallbackColor(getLightColor);
    }
    final darkMutedColor = paletteGenerator.darkMutedColor?.color;
    if (darkMutedColor != null) {
      return darkMutedColor;
    }
    final darkVibrantColor = paletteGenerator.darkVibrantColor?.color;
    if (darkVibrantColor != null) {
      return darkVibrantColor;
    }
    final dominantColor = paletteGenerator.dominantColor?.color;
    return dominantColor ?? _fallbackColor(getLightColor);
  }

  static Color _fallbackColor(bool getLightColor) {
    return getLightColor ? Colors.white : Colors.black;
  }

  static bool _isRemoteImageUrl(String url) {
    return ImageUrlNormalizer.isRemoteHttpUrl(url);
  }

  static bool _isUnavailableLocalImage(String url) {
    if (url.isEmpty) {
      return true;
    }
    final localPath = LocalFilePathNormalizer.normalize(url);
    return localPath.isEmpty || !File(localPath).existsSync();
  }
}

/// 图片取色内存缓存，按最近使用顺序保留有限条目。
class ImageColorMemoryCache {
  /// 创建图片取色内存缓存。
  ImageColorMemoryCache({required this.maxEntries}) : assert(maxEntries > 0);

  /// 最大缓存条目数。
  final int maxEntries;

  final LinkedHashMap<String, Color> _entries = LinkedHashMap<String, Color>();

  /// 当前缓存条目数。
  int get length => _entries.length;

  /// 是否包含指定缓存键。
  bool containsKey(String cacheKey) => _entries.containsKey(cacheKey);

  /// 读取并刷新最近使用顺序。
  Color? read(String cacheKey) {
    final color = _entries.remove(cacheKey);
    if (color == null) {
      return null;
    }
    _entries[cacheKey] = color;
    return color;
  }

  /// 写入颜色，并按最近使用顺序淘汰旧条目。
  void remember(String cacheKey, Color color) {
    _entries.remove(cacheKey);
    _entries[cacheKey] = color;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }
}
