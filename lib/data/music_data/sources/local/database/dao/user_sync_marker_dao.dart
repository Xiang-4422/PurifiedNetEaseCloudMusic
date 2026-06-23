import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as db;
import 'package:drift/drift.dart' as drift;

/// 用户同步标记 DAO。
class UserSyncMarkerDao {
  /// 创建用户同步标记 DAO。
  UserSyncMarkerDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  /// 读取同步标记时间。
  Future<DateTime?> loadSyncMarker(String userId, String markerKey) async {
    final row = await (_database.select(_database.userSyncMarkers)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.markerKey.equals(markerKey),
          ))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs);
  }

  /// 标记同步时间为当前时间。
  Future<void> markSyncMarkerUpdated(String userId, String markerKey) {
    return _database.into(_database.userSyncMarkers).insertOnConflictUpdate(
          db.UserSyncMarkersCompanion(
            userId: drift.Value(userId),
            markerKey: drift.Value(markerKey),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  /// 清理同步标记。
  Future<void> clearSyncMarker(String userId, String markerKey) {
    return (_database.delete(_database.userSyncMarkers)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.markerKey.equals(markerKey),
          ))
        .go();
  }
}
