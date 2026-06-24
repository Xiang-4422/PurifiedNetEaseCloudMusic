import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:bujuan/features/playback/playback_performance_logger.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/core/util/playback_url_expiry.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';

/// 播放源预取缓存，降低常规上一首/下一首切换时的 URL 等待。
class PlaybackSourcePrefetcher {
  /// 创建播放源预取器。
  PlaybackSourcePrefetcher({
    required PlaybackSourceResolver resolver,
    this.ttl = const Duration(minutes: 2),
    this.maxEntries = 24,
    DateTime Function()? now,
  })  : _resolver = resolver,
        _now = now ?? DateTime.now;

  final PlaybackSourceResolver _resolver;
  final DateTime Function() _now;

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
    final normalizedItemId = _normalizedItemId(item);
    if (normalizedItemId.isEmpty) {
      return Future.value(const PlaybackResolvedSource(kind: PlaybackResolvedSourceKind.empty));
    }
    final key = _cacheKey(
      item,
      normalizedItemId: normalizedItemId,
      preferHighQuality: preferHighQuality,
    );
    final cached = _freshCachedSource(
      key,
      item: item,
      preferHighQuality: preferHighQuality,
      allowLocalRecovery: true,
    );
    if (cached != null) {
      return Future.value(cached);
    }
    final shouldBypassInFlight = _inFlight.containsKey(key) && _itemHasUsableLocalSource(item);
    return _resolveAndCache(
      key,
      () => _resolver.resolve(item, preferHighQuality: preferHighQuality),
      forceRefresh: shouldBypassInFlight,
    );
  }

  /// 直接解析远程播放源，并缓存成功结果。
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) {
    final normalizedItemId = _normalizedItemId(item);
    if (normalizedItemId.isEmpty) {
      return Future.value(const PlaybackResolvedSource(kind: PlaybackResolvedSourceKind.empty));
    }
    final key = _remoteCacheKey(
      item,
      normalizedItemId: normalizedItemId,
      preferHighQuality: preferHighQuality,
    );
    if (forceRefresh) {
      _cache.remove(key);
    }
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
    if (_normalizedItemId(item).isEmpty) {
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
    final now = _now();
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
        return _isRemoteHttpUrl(source.url) && !PlaybackUrlExpiry.isExpired(source.url, now: _now());
      case PlaybackResolvedSourceKind.empty:
        return false;
    }
  }

  bool _itemHasUsableLocalSource(PlaybackQueueItem item) {
    if (item.mediaType != MediaType.local && item.mediaType != MediaType.neteaseCache) {
      return false;
    }
    final localPath = LocalFilePathNormalizer.normalize(item.playbackUrl);
    return localPath.isNotEmpty && File(localPath).existsSync();
  }

  bool _itemLocalSourceRecovered(
    PlaybackQueueItem item,
    PlaybackResolvedSource cachedSource,
  ) {
    if (cachedSource.kind != PlaybackResolvedSourceKind.url) {
      return false;
    }
    return _itemHasUsableLocalSource(item);
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
    loadFuture = Future.sync(load).then((source) {
      final usableSource = _usableResolvedSource(source);
      if (identical(_inFlight[key], loadFuture) && !usableSource.isEmpty) {
        _cache.remove(key);
        _cache[key] = _CachedPlaybackSource(usableSource, _now());
        _trimCache();
      }
      PlaybackPerformanceLogger.elapsed(
        'sourcePrefetch.load',
        stopwatch,
        details: 'key=$key success=${!usableSource.isEmpty} kind=${usableSource.kind.name}',
      );
      return usableSource;
    }).whenComplete(() {
      if (identical(_inFlight[key], loadFuture)) {
        _inFlight.remove(key);
      }
    });
    _inFlight[key] = loadFuture;
    return loadFuture;
  }

  PlaybackResolvedSource _usableResolvedSource(PlaybackResolvedSource source) {
    if (_isCachedSourceStillUsable(source)) {
      return source;
    }
    return const PlaybackResolvedSource(kind: PlaybackResolvedSourceKind.empty);
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
    required String normalizedItemId,
    required bool preferHighQuality,
  }) {
    return '$normalizedItemId|${item.sourceType.name}|${item.mediaType.name}|${_localPlaybackUrlKey(item)}|$preferHighQuality';
  }

  String _remoteCacheKey(
    PlaybackQueueItem item, {
    required String normalizedItemId,
    required bool preferHighQuality,
  }) {
    return '$normalizedItemId|${item.sourceType.name}|remote|$preferHighQuality';
  }

  String _normalizedItemId(PlaybackQueueItem item) {
    return item.id.trim();
  }

  String _localPlaybackUrlKey(PlaybackQueueItem item) {
    return LocalFilePathNormalizer.normalize(item.playbackUrl);
  }

  bool _isRemoteHttpUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    final scheme = uri?.scheme.toLowerCase();
    return (scheme == 'http' || scheme == 'https') && uri?.host.isNotEmpty == true;
  }
}

class _CachedPlaybackSource {
  const _CachedPlaybackSource(this.source, this.createdAt);

  final PlaybackResolvedSource source;
  final DateTime createdAt;
}
