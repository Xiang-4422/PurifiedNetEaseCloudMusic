import 'app_cache_data_source.dart';
import 'dao/cache_dao.dart';

class DriftAppCacheDataSource implements AppCacheDataSource {
  DriftAppCacheDataSource({required CacheDao dao}) : _dao = dao;

  final CacheDao _dao;

  @override
  Future<AppCacheRecord?> load(String cacheKey) {
    return _dao.load(cacheKey);
  }

  @override
  Future<String?> loadPayloadJson(String cacheKey) async {
    return (await load(cacheKey))?.payloadJson;
  }

  @override
  Future<void> save({required String cacheKey, required String payloadJson}) {
    return _dao.save(cacheKey: cacheKey, payloadJson: payloadJson);
  }

  @override
  Future<bool> isFresh(
    String cacheKey, {
    required Duration ttl,
  }) async {
    final record = await load(cacheKey);
    if (record == null) {
      return false;
    }
    return record.isFresh(ttl);
  }

  @override
  Future<void> delete(String cacheKey) {
    return _dao.delete(cacheKey);
  }

  @override
  Future<void> deleteByPrefix(String cacheKeyPrefix) {
    return _dao.deleteByPrefix(cacheKeyPrefix);
  }
}
