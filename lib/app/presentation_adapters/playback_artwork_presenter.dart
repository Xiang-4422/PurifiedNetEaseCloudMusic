import 'dart:io';

import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:bujuan/core/storage/local_image_cache_repository.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter/material.dart';

/// 播放封面相关的展示策略：补全封面、取色和本地图片预取。
class PlaybackArtworkPresenter {
  /// 创建播放封面展示策略实例。
  PlaybackArtworkPresenter({
    required PlaybackRepository repository,
    LocalImageCacheRepository? imageCacheRepository,
  })  : _repository = repository,
        _imageCacheRepository =
            imageCacheRepository ?? LocalImageCacheRepository();

  final PlaybackRepository _repository;
  final LocalImageCacheRepository _imageCacheRepository;

  final Map<String, Color> _albumColorCache = {};
  final Map<String, String> _resolvedArtworkPathCache = {};

  /// 解析队列项封面的主色，用于同步播放面板主题色。
  Future<Color?> resolveDominantColor(PlaybackQueueItem item) async {
    final imagePath = await _resolveArtworkPathForColor(item);
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final cachedColor = peekCachedDominantColor(item);
    if (cachedColor != null) {
      return cachedColor;
    }

    final color = await ImageColorService.dominantColor(imagePath);
    _rememberAlbumColor(imagePath, color);
    return color;
  }

  /// 只读取当前歌曲封面主色缓存，不触发图片下载或调色板计算。
  Color? peekCachedDominantColor(PlaybackQueueItem item) {
    final imageSource = _artworkSource(item);
    if (imageSource == null || imageSource.isEmpty) {
      return null;
    }

    final imagePath = _resolvedArtworkPathCache[imageSource] ??
        (_isRemoteArtworkSource(imageSource)
            ? null
            : _normalizeLocalArtworkPath(imageSource));
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final cachedColor = _albumColorCache[imagePath];
    if (cachedColor != null) {
      return cachedColor;
    }

    final diskCachedColor = ImageColorService.peekCachedColor(imagePath);
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
  }) async {
    if (queue.isEmpty || currentIndex < 0) {
      return;
    }
    final indices = <int>{currentIndex};
    for (var offset = 1; offset <= radius; offset++) {
      indices.add((currentIndex + offset) % queue.length);
      indices.add((currentIndex - offset + queue.length) % queue.length);
    }

    await Future.wait(
      indices.map((index) => _prewarmDominantColor(queue[index])),
    );
  }

  /// 在当前队列项缺少封面时，从本地资源索引补全封面地址。
  Future<PlaybackQueueItem?> resolveMissingArtwork(
    PlaybackQueueItem currentItem,
  ) async {
    if (_hasArtworkSource(currentItem)) {
      return null;
    }

    final trackWithResources =
        await _repository.getTrackWithResources(currentItem.id);
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
      final imagePath =
          queue[index].artworkUrl ?? queue[index].localArtworkPath;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http://') &&
          !imagePath.startsWith('https://')) {
        try {
          precacheImage(
            FileImage(File(imagePath.split('?').first)),
            context,
          );
        } catch (_) {
          // 图片预取失败只影响切歌观感，不能干扰播放主链路。
        }
      }
    }
  }

  bool _hasArtworkSource(PlaybackQueueItem item) {
    return item.artworkUrl?.isNotEmpty == true ||
        item.localArtworkPath?.isNotEmpty == true;
  }

  Future<void> _prewarmDominantColor(PlaybackQueueItem item) async {
    try {
      final imagePath = await _resolveArtworkPathForColor(item);
      if (imagePath == null || imagePath.isEmpty) {
        return;
      }
      if (_albumColorCache.containsKey(imagePath)) {
        return;
      }
      final cachedColor = ImageColorService.peekCachedColor(imagePath);
      if (cachedColor != null) {
        _rememberAlbumColor(imagePath, cachedColor);
        return;
      }
      final color = await ImageColorService.dominantColor(imagePath);
      _rememberAlbumColor(imagePath, color);
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
    return item.artworkUrl ?? item.localArtworkPath;
  }

  bool _isRemoteArtworkSource(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _normalizeLocalArtworkPath(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.scheme == 'file') {
      return uri.toFilePath();
    }
    return value.split('?').first;
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
