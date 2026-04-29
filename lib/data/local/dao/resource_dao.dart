import 'package:bujuan/core/database/drift_database.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:drift/drift.dart' as drift;

/// 本地资源 DAO。
class ResourceDao {
  /// 创建本地资源 DAO。
  ResourceDao({required BujuanDriftDatabase database}) : _database = database;

  final BujuanDriftDatabase _database;

  /// 获取指定歌曲的指定类型资源。
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  ) async {
    final row = await (_database.select(_database.localResourceEntries)
          ..where(
            (tbl) => tbl.trackId.equals(trackId) & tbl.kind.equals(kind.name),
          ))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapRow(row);
  }

  /// 获取指定歌曲的全部资源。
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    final rows = await (_database.select(_database.localResourceEntries)
          ..where((tbl) => tbl.trackId.equals(trackId))
          ..orderBy([
            (tbl) => drift.OrderingTerm.asc(tbl.kind),
          ]))
        .get();
    return rows.map(_mapRow).toList();
  }

  /// 批量获取歌曲资源。
  Future<Map<String, List<LocalResourceEntry>>> getTrackResourcesByIds(
    Iterable<String> trackIds,
  ) async {
    final ids = trackIds.toSet().toList();
    if (ids.isEmpty) {
      return const {};
    }
    final rows = await (_database.select(_database.localResourceEntries)
          ..where((tbl) => tbl.trackId.isIn(ids))
          ..orderBy([
            (tbl) => drift.OrderingTerm.asc(tbl.trackId),
            (tbl) => drift.OrderingTerm.asc(tbl.kind),
          ]))
        .get();
    final result = <String, List<LocalResourceEntry>>{};
    for (final row in rows) {
      result.putIfAbsent(row.trackId, () => []).add(_mapRow(row));
    }
    return result;
  }

  /// 列出音频资源。
  Future<List<LocalResourceEntry>> listAudioResources({
    Set<TrackResourceOrigin>? origins,
  }) async {
    final query = _database.select(_database.localResourceEntries)
      ..where((tbl) => tbl.kind.equals(LocalResourceKind.audio.name))
      ..orderBy([
        (tbl) => drift.OrderingTerm.asc(tbl.trackId),
      ]);
    if (origins != null && origins.isNotEmpty) {
      query.where((tbl) => tbl.origin.isIn(origins.map((item) => item.name)));
    }
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  /// 保存资源。
  Future<void> saveResource(LocalResourceEntry entry) {
    return _database
        .into(_database.localResourceEntries)
        .insertOnConflictUpdate(
          LocalResourceEntriesCompanion(
            trackId: drift.Value(entry.trackId),
            kind: drift.Value(entry.kind.name),
            path: drift.Value(entry.path),
            origin: drift.Value(entry.origin.name),
            sizeBytes: drift.Value(entry.sizeBytes),
            createdAtMs: drift.Value(entry.createdAt.millisecondsSinceEpoch),
            lastAccessedAtMs: drift.Value(
              entry.lastAccessedAt.millisecondsSinceEpoch,
            ),
          ),
        );
  }

  /// 更新资源最近访问时间。
  Future<void> touchResource(
    String trackId,
    LocalResourceKind kind, {
    required DateTime accessedAt,
  }) {
    return (_database.update(_database.localResourceEntries)
          ..where(
            (tbl) => tbl.trackId.equals(trackId) & tbl.kind.equals(kind.name),
          ))
        .write(
      LocalResourceEntriesCompanion(
        lastAccessedAtMs: drift.Value(accessedAt.millisecondsSinceEpoch),
      ),
    );
  }

  /// 删除指定资源。
  Future<void> removeResource(String trackId, LocalResourceKind kind) {
    return (_database.delete(_database.localResourceEntries)
          ..where(
            (tbl) => tbl.trackId.equals(trackId) & tbl.kind.equals(kind.name),
          ))
        .go();
  }

  /// 删除指定歌曲的全部资源。
  Future<void> removeTrackResources(String trackId) {
    return (_database.delete(_database.localResourceEntries)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .go();
  }

  /// 删除指定来源的全部资源。
  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin) {
    return (_database.delete(_database.localResourceEntries)
          ..where((tbl) => tbl.origin.equals(origin.name)))
        .go();
  }

  LocalResourceEntry _mapRow(LocalResourceEntrie row) {
    return LocalResourceEntry(
      trackId: row.trackId,
      kind: LocalResourceKind.values.firstWhere(
        (item) => item.name == row.kind,
        orElse: () => LocalResourceKind.audio,
      ),
      path: row.path,
      origin: TrackResourceOrigin.values.firstWhere(
        (item) => item.name == row.origin,
        orElse: () => TrackResourceOrigin.none,
      ),
      sizeBytes: row.sizeBytes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
      lastAccessedAt: DateTime.fromMillisecondsSinceEpoch(row.lastAccessedAtMs),
    );
  }
}
