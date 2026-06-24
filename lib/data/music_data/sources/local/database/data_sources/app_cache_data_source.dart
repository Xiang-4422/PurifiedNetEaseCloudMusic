/// 搜索热词短期缓存键。
const String appCacheSearchHotKeywordsKey = 'SEARCH_HOT_KEYWORDS';

/// 评论列表短期缓存键前缀。
const String appCacheCommentListPrefix = 'COMMENT_LIST';

/// 楼层评论短期缓存键前缀。
const String appCacheFloorCommentPrefix = 'FLOOR_COMMENT';

/// 应用通用缓存记录。
class AppCacheRecord {
  /// 创建应用缓存记录。
  const AppCacheRecord({
    required this.cacheKey,
    required this.payloadJson,
    required this.updatedAt,
  });

  /// 缓存键。
  final String cacheKey;

  /// 缓存负载 JSON。
  final String payloadJson;

  /// 更新时间。
  final DateTime updatedAt;

  /// 当前缓存是否仍在 TTL 内。
  bool isFresh(Duration ttl) {
    return DateTime.now().difference(updatedAt) < ttl;
  }
}

/// 应用通用缓存数据源。
abstract class AppCacheDataSource {
  /// 加载缓存记录。
  Future<AppCacheRecord?> load(String cacheKey);

  /// 加载缓存负载 JSON。
  Future<String?> loadPayloadJson(String cacheKey);

  /// 保存缓存负载 JSON。
  Future<void> save({
    required String cacheKey,
    required String payloadJson,
  });

  /// 判断缓存是否仍在 TTL 内。
  Future<bool> isFresh(String cacheKey, {required Duration ttl});

  /// 删除指定缓存。
  Future<void> delete(String cacheKey);

  /// 删除指定前缀下的缓存。
  Future<void> deleteByPrefix(String cacheKeyPrefix);
}
