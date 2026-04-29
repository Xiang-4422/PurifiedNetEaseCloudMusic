import 'package:bujuan/core/database/drift_database.dart';
import 'package:drift/drift.dart' as drift;

import 'app_cache_data_source.dart';

class DriftAppCacheDataSource implements AppCacheDataSource {
  DriftAppCacheDataSource({required BujuanDriftDatabase database})
      : _database = database;

  final BujuanDriftDatabase _database;

  @override
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

  @override
  Future<String?> loadPayloadJson(String cacheKey) async {
    return (await load(cacheKey))?.payloadJson;
  }

  @override
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
    return (_database.delete(_database.appCacheEntries)
          ..where((tbl) => tbl.cacheKey.equals(cacheKey)))
        .go();
  }

  @override
  Future<void> deleteByPrefix(String cacheKeyPrefix) {
    return (_database.delete(_database.appCacheEntries)
          ..where((tbl) => tbl.cacheKey.like('$cacheKeyPrefix%')))
        .go();
  }
}
