import 'dart:async';

import 'package:bujuan/domain/entities/playback_queue_item.dart';
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

  final Map<String, _CachedPlaybackSource> _cache = {};
  final Map<String, Future<PlaybackResolvedSource>> _inFlight = {};

  /// 解析播放源，优先使用预取缓存。
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    final key = _cacheKey(item, preferHighQuality: preferHighQuality);
    final cached = _cache[key];
    final now = DateTime.now();
    if (cached != null && now.difference(cached.createdAt) < ttl) {
      return Future.value(cached.source);
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
  }) {
    final key =
        '${_cacheKey(item, preferHighQuality: preferHighQuality)}|remote';
    return _resolveAndCache(
      key,
      () => _resolver.resolveRemote(item, preferHighQuality: preferHighQuality),
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

  Future<PlaybackResolvedSource> _resolveAndCache(
    String key,
    Future<PlaybackResolvedSource> Function() load,
  ) {
    final loading = _inFlight[key];
    if (loading != null) {
      return loading;
    }
    final loadFuture = load().then((source) {
      if (!source.isEmpty) {
        _cache[key] = _CachedPlaybackSource(source, DateTime.now());
        _trimCache();
      }
      return source;
    }).whenComplete(() {
      _inFlight.remove(key);
    });
    _inFlight[key] = loadFuture;
    return loadFuture;
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
    return '${item.id}|${item.playbackUrl ?? ''}|$preferHighQuality';
  }
}

class _CachedPlaybackSource {
  const _CachedPlaybackSource(this.source, this.createdAt);

  final PlaybackResolvedSource source;
  final DateTime createdAt;
}
