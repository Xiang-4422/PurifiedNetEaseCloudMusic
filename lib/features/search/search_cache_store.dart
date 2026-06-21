import 'dart:convert';

import 'package:bujuan/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart';

/// 搜索缓存存储。
class SearchCacheStore {
  /// 创建搜索缓存存储。
  const SearchCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  /// 加载热搜关键词缓存。
  Future<List<String>?> loadHotKeywords() async {
    final payloadJson = await _cacheDataSource.loadPayloadJson(appCacheSearchHotKeywordsKey);
    if (payloadJson == null) {
      return null;
    }
    final cachedKeywords = jsonDecode(payloadJson);
    if (cachedKeywords is! List) {
      return null;
    }
    return cachedKeywords.map((item) => '$item').toList();
  }

  /// 保存热搜关键词缓存。
  Future<void> saveHotKeywords(List<String> keywords) async {
    await _cacheDataSource.save(
      cacheKey: appCacheSearchHotKeywordsKey,
      payloadJson: jsonEncode(keywords),
    );
  }

  /// 判断热搜关键词缓存是否新鲜。
  Future<bool> isHotKeywordsFresh({
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      appCacheSearchHotKeywordsKey,
      ttl: ttl,
    );
  }
}
