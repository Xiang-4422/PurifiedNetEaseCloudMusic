/// 识别远程播放 URL 自带的过期时间。
class PlaybackUrlExpiry {
  const PlaybackUrlExpiry._();

  static const Set<String> _expiryQueryKeys = {
    'authtime',
    'exp',
    'expire',
    'expires',
  };

  /// 返回 URL query 中声明的最早过期时间。
  static DateTime? expiresAt(String? url) {
    final trimmedUrl = url?.trim() ?? '';
    if (trimmedUrl.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmedUrl);
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null || (scheme != 'http' && scheme != 'https') || uri.host.isEmpty) {
      return null;
    }

    DateTime? earliestExpiry;
    for (final entry in uri.queryParametersAll.entries) {
      if (!_expiryQueryKeys.contains(entry.key.toLowerCase())) {
        continue;
      }
      for (final value in entry.value) {
        final expiry = _parseEpoch(value);
        if (expiry == null) {
          continue;
        }
        if (earliestExpiry == null || expiry.isBefore(earliestExpiry)) {
          earliestExpiry = expiry;
        }
      }
    }
    return earliestExpiry;
  }

  /// 判断 URL query 中声明的过期时间是否已经失效。
  static bool isExpired(String? url, {DateTime? now}) {
    final expiry = expiresAt(url);
    if (expiry == null) {
      return false;
    }
    final currentTime = now ?? DateTime.now();
    return !currentTime.isBefore(expiry);
  }

  static DateTime? _parseEpoch(String value) {
    final epoch = int.tryParse(value.trim());
    if (epoch == null || epoch <= 0) {
      return null;
    }
    final milliseconds = epoch >= 1000000000000 ? epoch : epoch * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}
