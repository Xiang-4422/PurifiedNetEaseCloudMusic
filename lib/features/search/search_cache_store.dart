import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';

class SearchCacheStore {
  const SearchCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

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

  Future<void> saveHotKeywords(List<String> keywords) async {
    await _cacheDataSource.save(
      cacheKey: searchHotKeywordsSp,
      payloadJson: jsonEncode(keywords),
    );
  }

  Future<bool> isHotKeywordsFresh({
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      searchHotKeywordsSp,
      ttl: ttl,
    );
  }
}
