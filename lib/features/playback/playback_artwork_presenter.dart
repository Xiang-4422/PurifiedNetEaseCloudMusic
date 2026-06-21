import 'dart:io';

import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/features/playback/playback_performance_logger.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter/material.dart';

/// 主色解析函数，用于生产取色和单元测试替身。
typedef PlaybackDominantColorResolver = Future<Color> Function(
  String imagePath,
);

/// 主色缓存读取函数，用于生产缓存和单元测试替身。
typedef PlaybackCachedColorReader = Color? Function(String imagePath);

/// 播放封面相关的展示策略：补全封面、取色和本地图片预取。
class PlaybackArtworkPresenter {
  /// 创建播放封面展示策略实例。
  PlaybackArtworkPresenter({
    required PlaybackRepository repository,
    LocalImageCacheRepository? imageCacheRepository,
    PlaybackDominantColorResolver? dominantColorResolver,
    PlaybackCachedColorReader? cachedColorReader,
  })  : _repository = repository,
        _imageCacheRepository = imageCacheRepository ?? LocalImageCacheRepository(),
        _dominantColorResolver = dominantColorResolver ?? ImageColorService.dominantColor,
        _cachedColorReader = cachedColorReader ?? ImageColorService.peekCachedColor;

  final PlaybackRepository _repository;
  final LocalImageCacheRepository _imageCacheRepository;
  final PlaybackDominantColorResolver _dominantColorResolver;
  final PlaybackCachedColorReader _cachedColorReader;

  final Map<String, Color> _albumColorCache = {};
  final Map<String, String> _resolvedArtworkPathCache = {};
  final Map<String, Future<void>> _pendingDominantColorPrewarms = {};

  /// 解析队列项封面的主色，用于同步播放面板主题色。
  Future<Color?> resolveDominantColor(PlaybackQueueItem item) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    final imagePath = await _resolveArtworkPathForColor(item);
    if (imagePath == null || imagePath.isEmpty) {
      PlaybackPerformanceLogger.elapsed(
        'artwork.resolveDominantColor.noPath',
        stopwatch,
        details: 'id=${item.id}',
      );
      return null;
    }

    final cachedColor = peekCachedDominantColor(item);
    if (cachedColor != null) {
      PlaybackPerformanceLogger.elapsed(
        'artwork.resolveDominantColor.cacheHit',
        stopwatch,
        details: 'id=${item.id}',
        warnAfterMs: 1,
      );
      return cachedColor;
    }

    final color = await _dominantColorResolver(imagePath);
    _rememberAlbumColor(imagePath, color);
    PlaybackPerformanceLogger.elapsed(
      'artwork.resolveDominantColor.computed',
      stopwatch,
      details: 'id=${item.id}',
    );
    return color;
  }

  /// 只读取当前歌曲封面主色缓存，不触发图片下载或调色板计算。
  Color? peekCachedDominantColor(PlaybackQueueItem item) {
    final imageSource = _artworkSource(item);
    if (imageSource == null || imageSource.isEmpty) {
      return null;
    }

    final imagePath = _resolvedArtworkPathCache[imageSource] ?? (_isRemoteArtworkSource(imageSource) ? null : _normalizeLocalArtworkPath(imageSource));
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final cachedColor = _albumColorCache[imagePath];
    if (cachedColor != null) {
      return cachedColor;
    }

    final diskCachedColor = _cachedColorReader(imagePath);
    if (diskCachedColor != null) {
      _rememberAlbumColor(imagePath, diskCachedColor);
    }
    return diskCachedColor;
  }

  /// 预热当前歌曲邻近封面的主色缓存。
  Future<void> prewarmQueueDominantColors({
    required List<PlaybackQueueItem> queue,
    required int currentIndex,
    int radius = 3,
    int remoteResolveRadius = 1,
    bool includeCurrent = true,
    bool computeMissingColors = false,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    if (queue.isEmpty || currentIndex < 0) {
      return;
    }
    final indices = <int, int>{};
    if (includeCurrent) {
      indices[currentIndex] = 0;
    }
    for (var offset = 1; offset <= radius; offset++) {
      indices[(currentIndex + offset) % queue.length] = offset;
      indices[(currentIndex - offset + queue.length) % queue.length] = offset;
    }

    for (final entry in indices.entries) {
      await _prewarmDominantColor(
        queue[entry.key],
        allowRemoteResolve: entry.value <= remoteResolveRadius,
        computeMissingColor: computeMissingColors,
      );
      await Future<void>.delayed(Duration.zero);
    }
    PlaybackPerformanceLogger.elapsed(
      'artwork.prewarmQueueDominantColors',
      stopwatch,
      details: 'index=$currentIndex queue=${queue.length} candidates=${indices.length}',
      warnAfterMs: 8,
    );
  }

  /// 在当前队列项缺少封面时，从本地资源索引补全封面地址。
  Future<PlaybackQueueItem?> resolveMissingArtwork(
    PlaybackQueueItem currentItem,
  ) async {
    if (_hasArtworkSource(currentItem)) {
      return null;
    }

    final trackWithResources = await _repository.getTrackWithResources(currentItem.id);
    if (trackWithResources == null) {
      return null;
    }

    final imageUrl = _resolveArtworkSource(trackWithResources);
    if (imageUrl.isEmpty) {
      return null;
    }

    final localArtworkPath = trackWithResources.resources.artwork?.path ?? '';
    return currentItem.copyWith(
      artworkUrl: imageUrl,
      localArtworkPath: localArtworkPath.isEmpty ? null : localArtworkPath,
    );
  }

  /// 预取当前歌曲前后若干首的本地封面，降低切歌时的图片闪烁。
  void preloadQueueArtwork({
    required List<PlaybackQueueItem> queue,
    required int currentIndex,
    required BuildContext? context,
  }) {
    if (context == null || queue.isEmpty || currentIndex < 0) {
      return;
    }

    final indicesToPreload = <int>[];
    for (var i = 1; i <= 3; i++) {
      indicesToPreload.add((currentIndex + i) % queue.length);
      indicesToPreload.add((currentIndex - i + queue.length) % queue.length);
    }

    for (final index in indicesToPreload) {
      final imagePath = _localArtworkPath(queue[index]);
      if (imagePath.isNotEmpty) {
        try {
          precacheImage(
            FileImage(File(imagePath)),
            context,
          );
        } catch (_) {
          // 图片预取失败只影响切歌观感，不能干扰播放主链路。
        }
      }
    }
  }

  bool _hasArtworkSource(PlaybackQueueItem item) {
    return item.artworkUrl?.isNotEmpty == true || item.localArtworkPath?.isNotEmpty == true;
  }

  Future<void> _prewarmDominantColor(
    PlaybackQueueItem item, {
    bool allowRemoteResolve = false,
    bool computeMissingColor = false,
  }) async {
    final imageSource = _artworkSource(item);
    if (imageSource == null || imageSource.isEmpty) {
      return;
    }
    final pending = _pendingDominantColorPrewarms[imageSource];
    if (pending != null) {
      return pending;
    }
    late final Future<void> prewarm;
    prewarm = _runDominantColorPrewarm(
      item,
      allowRemoteResolve: allowRemoteResolve,
      computeMissingColor: computeMissingColor,
    ).whenComplete(() {
      if (identical(_pendingDominantColorPrewarms[imageSource], prewarm)) {
        _pendingDominantColorPrewarms.remove(imageSource);
      }
    });
    _pendingDominantColorPrewarms[imageSource] = prewarm;
    return prewarm;
  }

  Future<void> _runDominantColorPrewarm(
    PlaybackQueueItem item, {
    required bool allowRemoteResolve,
    required bool computeMissingColor,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    try {
      final imageSource = _artworkSource(item);
      if (imageSource == null || imageSource.isEmpty) {
        return;
      }
      if (_isRemoteArtworkSource(imageSource) && !_resolvedArtworkPathCache.containsKey(imageSource) && !allowRemoteResolve) {
        return;
      }
      final imagePath = await _resolveArtworkPathForColor(item);
      if (imagePath == null || imagePath.isEmpty) {
        return;
      }
      if (_albumColorCache.containsKey(imagePath)) {
        return;
      }
      final cachedColor = _cachedColorReader(imagePath);
      if (cachedColor != null) {
        _rememberAlbumColor(imagePath, cachedColor);
        return;
      }
      if (!computeMissingColor) {
        return;
      }
      final color = await _dominantColorResolver(imagePath);
      _rememberAlbumColor(imagePath, color);
      PlaybackPerformanceLogger.elapsed(
        'artwork.prewarmDominantColor.computed',
        stopwatch,
        details: 'id=${item.id}',
        warnAfterMs: 8,
      );
    } catch (_) {
      // 预热失败只影响下一次切歌取色命中率，不能干扰播放链路。
    }
  }

  Future<String?> _resolveArtworkPathForColor(PlaybackQueueItem item) async {
    final imageSource = _artworkSource(item);
    if (imageSource == null || imageSource.isEmpty) {
      return null;
    }

    final cachedPath = _resolvedArtworkPathCache[imageSource];
    if (cachedPath != null) {
      return cachedPath;
    }

    final imagePath = await _imageCacheRepository.resolveImagePath(imageSource);
    if (imagePath.isNotEmpty) {
      _rememberResolvedArtworkPath(imageSource, imagePath);
    }
    return imagePath;
  }

  String? _artworkSource(PlaybackQueueItem item) {
    final localArtworkPath = _localArtworkPath(item);
    if (localArtworkPath.isNotEmpty) {
      return localArtworkPath;
    }
    final artworkUrl = item.artworkUrl;
    if (artworkUrl?.isNotEmpty == true) {
      return artworkUrl;
    }
    return item.localArtworkPath;
  }

  bool _isRemoteArtworkSource(String value) {
    return ImageUrlNormalizer.isRemoteHttpUrl(value);
  }

  String _normalizeLocalArtworkPath(String value) {
    return LocalFilePathNormalizer.normalize(value);
  }

  String _localArtworkPath(PlaybackQueueItem item) {
    final localArtworkPath = _normalizeLocalArtworkPath(item.localArtworkPath ?? '');
    if (localArtworkPath.isNotEmpty) {
      return localArtworkPath;
    }
    final artworkUrl = item.artworkUrl ?? '';
    if (_isRemoteArtworkSource(artworkUrl)) {
      return '';
    }
    return _normalizeLocalArtworkPath(artworkUrl);
  }

  void _rememberResolvedArtworkPath(String imageSource, String imagePath) {
    if (_resolvedArtworkPathCache.length > 120) {
      _resolvedArtworkPathCache.remove(_resolvedArtworkPathCache.keys.first);
    }
    _resolvedArtworkPathCache[imageSource] = imagePath;
  }

  void _rememberAlbumColor(String imagePath, Color color) {
    if (_albumColorCache.length > 40) {
      _albumColorCache.remove(_albumColorCache.keys.first);
    }
    _albumColorCache[imagePath] = color;
  }

  String _resolveArtworkSource(TrackWithResources trackWithResources) {
    final localArtworkPath = trackWithResources.resources.artwork?.path ?? '';
    if (localArtworkPath.isNotEmpty) {
      return localArtworkPath;
    }
    return trackWithResources.track.artworkUrl ?? '';
  }
}
