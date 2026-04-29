import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';
import 'package:drift/drift.dart' as drift;

/// 用户作用域 DAO。
class UserDao {
  /// 创建用户作用域 DAO。
  UserDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  /// 读取用户资料。
  Future<UserProfileData?> loadProfile(String userId) async {
    final row = await (_database.select(_database.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return UserProfileData(
      userId: row.userId,
      nickname: row.nickname,
      signature: row.signature,
      follows: row.follows,
      followeds: row.followeds,
      playlistCount: row.playlistCount,
      avatarUrl: row.avatarUrl,
    );
  }

  /// 保存用户资料。
  Future<void> saveProfile(UserProfileData profile) {
    return _database.into(_database.userProfiles).insertOnConflictUpdate(
          db.UserProfilesCompanion(
            userId: drift.Value(profile.userId),
            nickname: drift.Value(profile.nickname),
            signature: drift.Value(profile.signature),
            follows: drift.Value(profile.follows),
            followeds: drift.Value(profile.followeds),
            playlistCount: drift.Value(profile.playlistCount),
            avatarUrl: drift.Value(profile.avatarUrl),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  /// 读取用户曲目 id 列表。
  Future<List<String>> loadTrackIds(
    String userId,
    UserTrackListKind kind,
  ) async {
    final rows = await (_database.select(_database.userTrackListRefs)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.listKind.equals(kind.name),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return rows.map((row) => row.trackId).toList();
  }

  /// 替换用户曲目列表。
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  ) async {
    await _database.transaction(() async {
      await (_database.delete(_database.userTrackListRefs)
            ..where(
              (tbl) =>
                  tbl.userId.equals(userId) & tbl.listKind.equals(kind.name),
            ))
          .go();
      if (trackIds.isEmpty) {
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.batch((batch) {
        batch.insertAll(
          _database.userTrackListRefs,
          trackIds
              .asMap()
              .entries
              .map(
                (entry) => db.UserTrackListRefsCompanion.insert(
                  userId: userId,
                  listKind: kind.name,
                  trackId: entry.value,
                  sortOrder: entry.key,
                  updatedAtMs: now,
                ),
              )
              .toList(),
        );
      });
    });
  }

  /// 追加用户曲目列表。
  Future<void> appendTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds, {
    required int startOrder,
  }) async {
    if (trackIds.isEmpty) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.userTrackListRefs,
        trackIds
            .asMap()
            .entries
            .map(
              (entry) => db.UserTrackListRefsCompanion(
                userId: drift.Value(userId),
                listKind: drift.Value(kind.name),
                trackId: drift.Value(entry.value),
                sortOrder: drift.Value(startOrder + entry.key),
                updatedAtMs: drift.Value(now),
              ),
            )
            .toList(),
      );
    });
  }

  /// 插入或更新单个用户曲目引用。
  Future<void> upsertTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId, {
    int? sortOrder,
  }) async {
    await deleteTrackRef(userId, kind, trackId);
    final resolvedOrder = sortOrder ?? await nextTrackSortOrder(userId, kind);
    await _database.into(_database.userTrackListRefs).insertOnConflictUpdate(
          db.UserTrackListRefsCompanion(
            userId: drift.Value(userId),
            listKind: drift.Value(kind.name),
            trackId: drift.Value(trackId),
            sortOrder: drift.Value(resolvedOrder),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  /// 删除单个用户曲目引用。
  Future<void> deleteTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId,
  ) {
    return (_database.delete(_database.userTrackListRefs)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.listKind.equals(kind.name) &
                tbl.trackId.equals(trackId),
          ))
        .go();
  }

  /// 获取下一个曲目排序值。
  Future<int> nextTrackSortOrder(
    String userId,
    UserTrackListKind kind,
  ) async {
    final row = await (_database.select(_database.userTrackListRefs)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.listKind.equals(kind.name),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return 0;
    }
    return row.sortOrder + 1;
  }

  /// 读取歌单订阅状态。
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  ) async {
    final row = await (_database.select(_database.userPlaylistStates)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.playlistId.equals(playlistId),
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

  /// 读取同步标记时间。
  Future<DateTime?> loadSyncMarker(String userId, String markerKey) async {
    final row = await (_database.select(_database.userSyncMarkers)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.markerKey.equals(markerKey),
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
            (tbl) =>
                tbl.userId.equals(userId) & tbl.markerKey.equals(markerKey),
          ))
        .go();
  }
}
