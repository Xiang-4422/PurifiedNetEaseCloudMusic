import 'package:bujuan/core/database/drift_database.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:drift/drift.dart' as drift;

/// 应用缓存 DAO。
class CacheDao {
  /// 创建应用缓存 DAO。
  CacheDao({required BujuanDriftDatabase database}) : _database = database;

  final BujuanDriftDatabase _database;

  /// 加载缓存记录。
  Future<AppCacheRecord?> load(String cacheKey) async {
    final row = await (_database.select(_database.appCacheEntries)
          ..where((tbl) => tbl.cacheKey.equals(cacheKey)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return AppCacheRecord(
      cacheKey: row.cacheKey,
      payloadJson: row.payloadJson,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs),
    );
  }

  /// 保存缓存记录。
  Future<void> save({
    required String cacheKey,
    required String payloadJson,
  }) {
    return _database.into(_database.appCacheEntries).insertOnConflictUpdate(
          AppCacheEntriesCompanion(
            cacheKey: drift.Value(cacheKey),
            payloadJson: drift.Value(payloadJson),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  /// 删除缓存记录。
  Future<void> delete(String cacheKey) {
    return (_database.delete(_database.appCacheEntries)
          ..where((tbl) => tbl.cacheKey.equals(cacheKey)))
        .go();
  }

  /// 删除指定前缀下的缓存记录。
  Future<void> deleteByPrefix(String cacheKeyPrefix) {
    return (_database.delete(_database.appCacheEntries)
          ..where((tbl) => tbl.cacheKey.like('$cacheKeyPrefix%')))
        .go();
  }
}
