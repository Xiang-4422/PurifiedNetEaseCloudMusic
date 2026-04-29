import 'dart:io';

import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:bujuan/core/storage/local_image_cache_repository.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter/material.dart';

/// 播放封面相关的展示策略：补全封面、取色和本地图片预取。
class PlaybackArtworkPresenter {
  PlaybackArtworkPresenter({
    required PlaybackRepository repository,
    LocalImageCacheRepository? imageCacheRepository,
  })  : _repository = repository,
        _imageCacheRepository =
            imageCacheRepository ?? LocalImageCacheRepository();

  final PlaybackRepository _repository;
  final LocalImageCacheRepository _imageCacheRepository;

  final Map<String, Color> _albumColorCache = {};

  Future<Color?> resolveDominantColor(PlaybackQueueItem item) async {
    final imageUrl = item.artworkUrl ?? item.localArtworkPath;
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    final imagePath = await _imageCacheRepository.resolveImagePath(imageUrl);
    if (imagePath.isEmpty) {
      return null;
    }

    final cachedColor = _albumColorCache[imagePath];
    if (cachedColor != null) {
      return cachedColor;
    }

    final color = await ImageColorService.dominantColor(imagePath);
    if (_albumColorCache.length > 20) {
      _albumColorCache.remove(_albumColorCache.keys.first);
    }
    _albumColorCache[imagePath] = color;
    return color;
  }

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

  String _resolveArtworkSource(TrackWithResources trackWithResources) {
    final localArtworkPath = trackWithResources.resources.artwork?.path ?? '';
    if (localArtworkPath.isNotEmpty) {
      return localArtworkPath;
    }
    return trackWithResources.track.artworkUrl ?? '';
  }
}
