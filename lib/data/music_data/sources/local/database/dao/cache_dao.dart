import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart';
import 'package:drift/drift.dart' as drift;

/// 应用缓存 DAO。
class CacheDao {
  /// 创建应用缓存 DAO。
  CacheDao({required BujuanDriftDatabase database}) : _database = database;

  final BujuanDriftDatabase _database;

  /// 加载缓存记录。
  Future<AppCacheRecord?> load(String cacheKey) async {
    final normalizedCacheKey = _normalizedCacheKey(cacheKey);
    if (_isBlankCacheKey(normalizedCacheKey)) {
      return null;
    }
    final row = await (_database.select(_database.appCacheEntries)..where((tbl) => tbl.cacheKey.equals(normalizedCacheKey))).getSingleOrNull();
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
  }) async {
    final normalizedCacheKey = _normalizedCacheKey(cacheKey);
    if (_isBlankCacheKey(normalizedCacheKey)) {
      return;
    }
    await _database.into(_database.appCacheEntries).insertOnConflictUpdate(
          AppCacheEntriesCompanion(
            cacheKey: drift.Value(normalizedCacheKey),
            payloadJson: drift.Value(payloadJson),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  /// 删除缓存记录。
  Future<void> delete(String cacheKey) {
    final normalizedCacheKey = _normalizedCacheKey(cacheKey);
    if (_isBlankCacheKey(normalizedCacheKey)) {
      return Future<void>.value();
    }
    return (_database.delete(_database.appCacheEntries)..where((tbl) => tbl.cacheKey.equals(normalizedCacheKey))).go();
  }

  /// 删除指定前缀下的缓存记录。
  Future<void> deleteByPrefix(String cacheKeyPrefix) {
    final normalizedCacheKeyPrefix = _normalizedCacheKey(cacheKeyPrefix);
    if (_isBlankCacheKey(normalizedCacheKeyPrefix)) {
      return Future<void>.value();
    }
    return (_database.delete(_database.appCacheEntries)..where((tbl) => tbl.cacheKey.like('$normalizedCacheKeyPrefix%'))).go();
  }

  String _normalizedCacheKey(String cacheKey) {
    return cacheKey.trim();
  }

  bool _isBlankCacheKey(String cacheKey) {
    return cacheKey.isEmpty;
  }
}
