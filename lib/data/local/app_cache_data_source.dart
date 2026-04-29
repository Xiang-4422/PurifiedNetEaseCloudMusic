class AppCacheRecord {
  const AppCacheRecord({
    required this.cacheKey,
    required this.payloadJson,
    required this.updatedAt,
  });

  final String cacheKey;
  final String payloadJson;
  final DateTime updatedAt;

  bool isFresh(Duration ttl) {
    return DateTime.now().difference(updatedAt) < ttl;
  }
}

abstract class AppCacheDataSource {
  Future<AppCacheRecord?> load(String cacheKey);

  Future<String?> loadPayloadJson(String cacheKey);

  Future<void> save({
    required String cacheKey,
    required String payloadJson,
  });

  Future<bool> isFresh(
    String cacheKey, {
    required Duration ttl,
  });

  Future<void> delete(String cacheKey);

  Future<void> deleteByPrefix(String cacheKeyPrefix);
}
