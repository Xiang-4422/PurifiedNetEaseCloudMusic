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
    final normalizedUserId = _normalizedUserId(userId);
    final normalizedPlaylistId = _normalizedPlaylistId(playlistId);
    if (_isBlankUserId(normalizedUserId) || _isBlankPlaylistId(normalizedPlaylistId)) {
      return null;
    }
    final row = await (_database.select(_database.userPlaylistStates)
          ..where(
            (tbl) => tbl.userId.equals(normalizedUserId) & tbl.playlistId.equals(normalizedPlaylistId),
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
    final normalizedUserId = _normalizedUserId(userId);
    final normalizedPlaylistId = _normalizedPlaylistId(playlistId);
    if (_isBlankUserId(normalizedUserId) || _isBlankPlaylistId(normalizedPlaylistId)) {
      return Future<void>.value();
    }
    return _database.into(_database.userPlaylistStates).insertOnConflictUpdate(
          db.UserPlaylistStatesCompanion(
            userId: drift.Value(normalizedUserId),
            playlistId: drift.Value(normalizedPlaylistId),
            isSubscribed: drift.Value(isSubscribed),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  String _normalizedUserId(String userId) {
    return userId.trim();
  }

  bool _isBlankUserId(String userId) {
    return userId.isEmpty;
  }

  String _normalizedPlaylistId(String playlistId) {
    return playlistId.trim();
  }

  bool _isBlankPlaylistId(String playlistId) {
    return playlistId.isEmpty;
  }
}
