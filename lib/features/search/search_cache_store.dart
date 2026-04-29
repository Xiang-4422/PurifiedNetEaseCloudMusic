import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';

/// 搜索缓存存储。
class SearchCacheStore {
  /// 创建搜索缓存存储。
  const SearchCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  /// 加载热搜关键词缓存。
  Future<List<String>?> loadHotKeywords() async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(searchHotKeywordsSp);
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
      cacheKey: searchHotKeywordsSp,
      payloadJson: jsonEncode(keywords),
    );
  }

  /// 判断热搜关键词缓存是否新鲜。
  Future<bool> isHotKeywordsFresh({
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      searchHotKeywordsSp,
      ttl: ttl,
    );
  }
}
