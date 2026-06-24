import 'package:bujuan/core/util/playback_source_reference.dart';

/// Resolves playback URLs through a short-lived in-memory remote URL cache.
typedef LocalPlaybackResourceResolver = Future<String?> Function(String trackId);

/// Coordinates playback URL de-duplication, TTL caching, and local overrides.
class PlaybackUrlCacheCoordinator {
  /// Creates a playback URL cache coordinator.
  PlaybackUrlCacheCoordinator({
    required LocalPlaybackResourceResolver resolveLocalResourceUrl,
    Duration ttl = const Duration(minutes: 2),
    int maxEntries = 64,
    DateTime Function()? now,
  })  : _resolveLocalResourceUrl = resolveLocalResourceUrl,
        _ttl = ttl,
        _maxEntries = maxEntries,
        _now = now ?? DateTime.now;

  final LocalPlaybackResourceResolver _resolveLocalResourceUrl;
  final Duration _ttl;
  final int _maxEntries;
  final DateTime Function() _now;
  final Map<String, Future<String?>> _loads = {};
  final Set<String> _forceRefreshLoads = <String>{};
  final Map<String, _CachedPlaybackUrl> _cache = {};

  /// Returns a playback URL for [trackId], preferring fresh local resources.
  Future<String?> resolve(
    String trackId, {
    required String? qualityLevel,
    required bool forceRefresh,
    required Future<String?> Function() load,
  }) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (normalizedTrackId.isEmpty) {
      return null;
    }
    final cacheKey = _cacheKey(normalizedTrackId, qualityLevel);
    final localUrl = await _resolveLocalResourceUrlOrNull(normalizedTrackId);
    if (localUrl != null) {
      _dropRemoteState(cacheKey);
      return localUrl;
    }
    final loadingUrl = _loads[cacheKey];
    final canReuseForceRefreshLoad = forceRefresh && _forceRefreshLoads.contains(cacheKey);
    if (forceRefresh) {
      _cache.remove(cacheKey);
    }
    final cachedUrl = _cache[cacheKey];
    final now = _now();
    if (!forceRefresh && cachedUrl != null) {
      if (now.difference(cachedUrl.createdAt) < _ttl && PlaybackSourceReference.isFreshRemoteHttpUrl(cachedUrl.url, now: now)) {
        _touch(cacheKey, cachedUrl);
        return cachedUrl.url;
      }
      _cache.remove(cacheKey);
    }
    if (loadingUrl != null && (!forceRefresh || canReuseForceRefreshLoad)) {
      return loadingUrl;
    }
    late final Future<String?> loadFuture;
    try {
      final remoteLoad = load();
      if (forceRefresh) {
        _forceRefreshLoads.add(cacheKey);
      }
      loadFuture = remoteLoad.then((url) {
        final normalizedUrl = _normalizePlaybackUrl(url);
        if (identical(_loads[cacheKey], loadFuture)) {
          _cacheRemoteUrl(cacheKey, normalizedUrl);
        }
        return normalizedUrl;
      }).whenComplete(() {
        if (identical(_loads[cacheKey], loadFuture)) {
          _loads.remove(cacheKey);
          _forceRefreshLoads.remove(cacheKey);
        }
      });
    } catch (_) {
      if (forceRefresh) {
        _forceRefreshLoads.remove(cacheKey);
      }
      rethrow;
    }
    _loads[cacheKey] = loadFuture;
    return loadFuture;
  }

  Future<String?> _resolveLocalResourceUrlOrNull(String trackId) async {
    try {
      final url = await _resolveLocalResourceUrl(trackId);
      final normalizedUrl = PlaybackSourceReference.localPath(url);
      return normalizedUrl.isEmpty ? null : normalizedUrl;
    } catch (_) {
      return null;
    }
  }

  void _cacheRemoteUrl(String cacheKey, String? url) {
    final now = _now();
    final remoteUrl = PlaybackSourceReference.freshRemoteHttpUrl(url, now: now);
    if (remoteUrl.isNotEmpty) {
      _cache.remove(cacheKey);
      _cache[cacheKey] = _CachedPlaybackUrl(
        url: remoteUrl,
        createdAt: now,
      );
      _trim();
    }
  }

  void _touch(String cacheKey, _CachedPlaybackUrl cachedUrl) {
    _cache
      ..remove(cacheKey)
      ..[cacheKey] = cachedUrl;
  }

  void _dropRemoteState(String cacheKey) {
    _cache.remove(cacheKey);
    _loads.remove(cacheKey);
    _forceRefreshLoads.remove(cacheKey);
  }

  void _trim() {
    while (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  static String _cacheKey(String trackId, String? qualityLevel) {
    final normalizedQualityLevel = qualityLevel?.trim() ?? '';
    return '${_normalizedTrackId(trackId)}|$normalizedQualityLevel';
  }

  static String? _normalizePlaybackUrl(String? url) {
    final normalizedUrl = PlaybackSourceReference.playbackReference(url);
    return normalizedUrl.isEmpty ? null : normalizedUrl;
  }

  static String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }
}

class _CachedPlaybackUrl {
  const _CachedPlaybackUrl({
    required this.url,
    required this.createdAt,
  });

  final String url;
  final DateTime createdAt;
}
