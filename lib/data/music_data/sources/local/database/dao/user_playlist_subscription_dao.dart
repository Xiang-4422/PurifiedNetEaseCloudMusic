import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as db;
import 'package:drift/drift.dart' as drift;

/// 用户歌单订阅状态 DAO。
class UserPlaylistSubscriptionDao {
  /// 创建用户歌单订阅状态 DAO。
  UserPlaylistSubscriptionDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  /// 读取歌单订阅状态。
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  ) async {
    final row = await (_database.select(_database.userPlaylistStates)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.playlistId.equals(playlistId),
          ))
        .getSingleOrNull();
    return row?.isSubscribed;
  }

  /// 保存歌单订阅状态。
  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  ) {
    return _database.into(_database.userPlaylistStates).insertOnConflictUpdate(
          db.UserPlaylistStatesCompanion(
            userId: drift.Value(userId),
            playlistId: drift.Value(playlistId),
            isSubscribed: drift.Value(isSubscribed),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }
}
