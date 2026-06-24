import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as db;
import 'package:drift/drift.dart' as drift;

/// 用户曲目列表 DAO。
class UserTrackListDao {
  /// 创建用户曲目列表 DAO。
  UserTrackListDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  /// 读取用户曲目 id 列表。
  Future<List<String>> loadTrackIds(
    String userId,
    UserTrackListKind kind,
  ) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const <String>[];
    }
    final rows = await (_database.select(_database.userTrackListRefs)
          ..where(
            (tbl) => tbl.userId.equals(normalizedUserId) & tbl.listKind.equals(kind.name),
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return;
    }
    final normalizedTrackIds = _normalizedTrackIds(trackIds);
    await _database.transaction(() async {
      await (_database.delete(_database.userTrackListRefs)
            ..where(
              (tbl) => tbl.userId.equals(normalizedUserId) & tbl.listKind.equals(kind.name),
            ))
          .go();
      if (normalizedTrackIds.isEmpty) {
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.batch((batch) {
        batch.insertAll(
          _database.userTrackListRefs,
          normalizedTrackIds
              .asMap()
              .entries
              .map(
                (entry) => db.UserTrackListRefsCompanion.insert(
                  userId: normalizedUserId,
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
    final normalizedUserId = _normalizedUserId(userId);
    final normalizedTrackIds = _normalizedTrackIds(trackIds);
    if (_isBlankUserId(normalizedUserId) || normalizedTrackIds.isEmpty) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.userTrackListRefs,
        normalizedTrackIds
            .asMap()
            .entries
            .map(
              (entry) => db.UserTrackListRefsCompanion(
                userId: drift.Value(normalizedUserId),
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
    final normalizedUserId = _normalizedUserId(userId);
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankUserId(normalizedUserId) || _isBlankTrackId(normalizedTrackId)) {
      return;
    }
    await deleteTrackRef(normalizedUserId, kind, normalizedTrackId);
    final resolvedOrder = sortOrder ?? await nextTrackSortOrder(normalizedUserId, kind);
    await _database.into(_database.userTrackListRefs).insertOnConflictUpdate(
          db.UserTrackListRefsCompanion(
            userId: drift.Value(normalizedUserId),
            listKind: drift.Value(kind.name),
            trackId: drift.Value(normalizedTrackId),
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
    final normalizedUserId = _normalizedUserId(userId);
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankUserId(normalizedUserId) || _isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return (_database.delete(_database.userTrackListRefs)
          ..where(
            (tbl) => tbl.userId.equals(normalizedUserId) & tbl.listKind.equals(kind.name) & tbl.trackId.equals(normalizedTrackId),
          ))
        .go();
  }

  /// 获取下一个曲目排序值。
  Future<int> nextTrackSortOrder(
    String userId,
    UserTrackListKind kind,
  ) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return 0;
    }
    final row = await (_database.select(_database.userTrackListRefs)
          ..where(
            (tbl) => tbl.userId.equals(normalizedUserId) & tbl.listKind.equals(kind.name),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return 0;
    }
    return row.sortOrder + 1;
  }

  String _normalizedUserId(String userId) {
    return userId.trim();
  }

  bool _isBlankUserId(String userId) {
    return userId.isEmpty;
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }

  bool _isBlankTrackId(String trackId) {
    return trackId.isEmpty;
  }

  List<String> _normalizedTrackIds(List<String> trackIds) {
    return trackIds.map(_normalizedTrackId).where((trackId) => !_isBlankTrackId(trackId)).toList();
  }
}
