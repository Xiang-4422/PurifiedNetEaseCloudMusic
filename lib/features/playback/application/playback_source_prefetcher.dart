import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:bujuan/features/playback/playback_performance_logger.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';

/// 播放源预取缓存，降低常规上一首/下一首切换时的 URL 等待。
class PlaybackSourcePrefetcher {
  /// 创建播放源预取器。
  PlaybackSourcePrefetcher({
    required PlaybackSourceResolver resolver,
    this.ttl = const Duration(minutes: 2),
    this.maxEntries = 24,
  }) : _resolver = resolver;

  final PlaybackSourceResolver _resolver;

  /// 预取结果有效期。
  final Duration ttl;

  /// 最多缓存的播放源数量。
  final int maxEntries;

  final LinkedHashMap<String, _CachedPlaybackSource> _cache = LinkedHashMap<String, _CachedPlaybackSource>();
  final Map<String, Future<PlaybackResolvedSource>> _inFlight = {};

  /// 解析播放源，优先使用预取缓存。
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    final key = _cacheKey(item, preferHighQuality: preferHighQuality);
    final cached = _freshCachedSource(
      key,
      item: item,
      preferHighQuality: preferHighQuality,
      allowLocalRecovery: true,
    );
    if (cached != null) {
      return Future.value(cached);
    }
    return _resolveAndCache(
      key,
      () => _resolver.resolve(item, preferHighQuality: preferHighQuality),
    );
  }

  /// 直接解析远程播放源，并缓存成功结果。
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) {
    final key = '${_cacheKey(item, preferHighQuality: preferHighQuality)}|remote';
    if (!forceRefresh) {
      final cached = _freshCachedSource(
        key,
        item: item,
        preferHighQuality: preferHighQuality,
        allowLocalRecovery: false,
      );
      if (cached != null) {
        return Future.value(cached);
      }
    }
    return _resolveAndCache(
      key,
      () => _resolver.resolveRemote(
        item,
        preferHighQuality: preferHighQuality,
        forceRefresh: forceRefresh,
      ),
      forceRefresh: forceRefresh,
    );
  }

  /// 后台预取指定歌曲。
  void prefetch(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    if (item.id.isEmpty) {
      return;
    }
    unawaited(
      resolve(item, preferHighQuality: preferHighQuality).catchError(
        (_) => const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.empty,
        ),
      ),
    );
  }

  PlaybackResolvedSource? _freshCachedSource(
    String key, {
    required PlaybackQueueItem item,
    required bool preferHighQuality,
    required bool allowLocalRecovery,
  }) {
    final cached = _cache[key];
    final now = DateTime.now();
    if (cached == null) {
      return null;
    }
    if (now.difference(cached.createdAt) >= ttl) {
      _cache.remove(key);
      return null;
    }
    if (!_isCachedSourceStillUsable(cached.source) || (allowLocalRecovery && _itemLocalSourceRecovered(item, cached.source))) {
      _cache.remove(key);
      return null;
    }
    PlaybackPerformanceLogger.log(
      'sourcePrefetch.cacheHit id=${item.id} highQuality=$preferHighQuality kind=${cached.source.kind.name}',
    );
    _touchCache(key, cached);
    return cached.source;
  }

  bool _isCachedSourceStillUsable(PlaybackResolvedSource source) {
    switch (source.kind) {
      case PlaybackResolvedSourceKind.filePath:
      case PlaybackResolvedSourceKind.neteaseCacheStream:
        return source.url.isNotEmpty && File(source.url).existsSync();
      case PlaybackResolvedSourceKind.url:
      case PlaybackResolvedSourceKind.empty:
        return true;
    }
  }

  bool _itemLocalSourceRecovered(
    PlaybackQueueItem item,
    PlaybackResolvedSource cachedSource,
  ) {
    if (cachedSource.kind != PlaybackResolvedSourceKind.url) {
      return false;
    }
    if (item.mediaType != MediaType.local && item.mediaType != MediaType.neteaseCache) {
      return false;
    }
    final localPath = LocalFilePathNormalizer.normalize(item.playbackUrl);
    return localPath.isNotEmpty && File(localPath).existsSync();
  }

  Future<PlaybackResolvedSource> _resolveAndCache(
    String key,
    Future<PlaybackResolvedSource> Function() load, {
    bool forceRefresh = false,
  }) {
    final loading = _inFlight[key];
    if (!forceRefresh && loading != null) {
      PlaybackPerformanceLogger.log('sourcePrefetch.inFlight key=$key');
      return loading;
    }
    final stopwatch = PlaybackPerformanceLogger.start();
    late final Future<PlaybackResolvedSource> loadFuture;
    loadFuture = load().then((source) {
      if (identical(_inFlight[key], loadFuture) && !source.isEmpty) {
        _cache.remove(key);
        _cache[key] = _CachedPlaybackSource(source, DateTime.now());
        _trimCache();
      }
      PlaybackPerformanceLogger.elapsed(
        'sourcePrefetch.load',
        stopwatch,
        details: 'key=$key success=${!source.isEmpty} kind=${source.kind.name}',
      );
      return source;
    }).whenComplete(() {
      if (identical(_inFlight[key], loadFuture)) {
        _inFlight.remove(key);
      }
    });
    _inFlight[key] = loadFuture;
    return loadFuture;
  }

  void _touchCache(String key, _CachedPlaybackSource cached) {
    _cache
      ..remove(key)
      ..[key] = cached;
  }

  void _trimCache() {
    while (_cache.length > maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  String _cacheKey(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    return '${item.id}|${item.sourceType.name}|${item.mediaType.name}|${item.playbackUrl ?? ''}|$preferHighQuality';
  }
}

class _CachedPlaybackSource {
  const _CachedPlaybackSource(this.source, this.createdAt);

  final PlaybackResolvedSource source;
  final DateTime createdAt;
}
