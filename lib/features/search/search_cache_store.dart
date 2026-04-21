import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/core/storage/cache_timestamp_store.dart';

class SearchCacheStore {
  const SearchCacheStore({
    CacheTimestampStore? timestampStore,
  }) : _timestampStore = timestampStore ?? const CacheTimestampStore();

  final CacheTimestampStore _timestampStore;

  Future<List<String>?> loadHotKeywords() async {
    final cachedKeywords = CacheBox.instance.get(searchHotKeywordsSp);
    if (cachedKeywords is! List) {
      return null;
    }
    return cachedKeywords.map((item) => '$item').toList();
  }

  Future<void> saveHotKeywords(List<String> keywords) async {
    await CacheBox.instance.put(searchHotKeywordsSp, keywords);
    await _timestampStore.markUpdated(searchHotKeywordsLastRefreshSp);
  }

  bool isHotKeywordsFresh({
    required Duration ttl,
  }) {
    return _timestampStore.isFresh(
      searchHotKeywordsLastRefreshSp,
      ttl: ttl,
    );
  }
}
