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
  final Map<String, _CachedPlaybackUrl> _cache = {};

  /// Returns a playback URL for [trackId], preferring fresh local resources.
  Future<String?> resolve(
    String trackId, {
    required String? qualityLevel,
    required bool forceRefresh,
    required Future<String?> Function() load,
  }) async {
    final cacheKey = _cacheKey(trackId, qualityLevel);
    final localUrl = await _resolveLocalResourceUrlOrNull(trackId);
    if (localUrl != null) {
      return localUrl;
    }
    final cachedUrl = _cache[cacheKey];
    final now = _now();
    if (!forceRefresh && cachedUrl != null) {
      if (now.difference(cachedUrl.createdAt) < _ttl) {
        _touch(cacheKey, cachedUrl);
        return cachedUrl.url;
      }
      _cache.remove(cacheKey);
    }
    final loadingUrl = _loads[cacheKey];
    if (!forceRefresh && loadingUrl != null) {
      return loadingUrl;
    }
    late final Future<String?> loadFuture;
    loadFuture = load().then((url) {
      final normalizedUrl = _normalizeRemoteUrl(url);
      if (identical(_loads[cacheKey], loadFuture)) {
        _cacheRemoteUrl(cacheKey, normalizedUrl);
      }
      return normalizedUrl;
    }).whenComplete(() {
      if (identical(_loads[cacheKey], loadFuture)) {
        _loads.remove(cacheKey);
      }
    });
    _loads[cacheKey] = loadFuture;
    return loadFuture;
  }

  Future<String?> _resolveLocalResourceUrlOrNull(String trackId) async {
    try {
      return await _resolveLocalResourceUrl(trackId);
    } catch (_) {
      return null;
    }
  }

  void _cacheRemoteUrl(String cacheKey, String? url) {
    if (url != null && _isRemoteUrl(url)) {
      _cache.remove(cacheKey);
      _cache[cacheKey] = _CachedPlaybackUrl(
        url: url,
        createdAt: _now(),
      );
      _trim();
    }
  }

  void _touch(String cacheKey, _CachedPlaybackUrl cachedUrl) {
    _cache
      ..remove(cacheKey)
      ..[cacheKey] = cachedUrl;
  }

  void _trim() {
    while (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  static String _cacheKey(String trackId, String? qualityLevel) {
    return '$trackId|${qualityLevel ?? ''}';
  }

  static String? _normalizeRemoteUrl(String? url) {
    if (url == null) {
      return null;
    }
    final trimmedUrl = url.trim();
    if (_hasHttpScheme(trimmedUrl)) {
      return trimmedUrl;
    }
    return url;
  }

  static bool _isRemoteUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    return _isHttpUri(uri) && uri?.host.isNotEmpty == true;
  }

  static bool _hasHttpScheme(String url) {
    return _isHttpUri(Uri.tryParse(url));
  }

  static bool _isHttpUri(Uri? uri) {
    final scheme = uri?.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
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
