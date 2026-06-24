import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/track.dart';
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final row = await (_database.select(_database.localResourceEntries)
          ..where(
            (tbl) => tbl.trackId.equals(normalizedTrackId) & tbl.kind.equals(kind.name),
          ))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapRow(row);
  }

  /// 获取指定歌曲的全部资源。
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return const [];
    }
    final rows = await (_database.select(_database.localResourceEntries)
          ..where((tbl) => tbl.trackId.equals(normalizedTrackId))
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
    final ids = _candidateTrackIds(trackIds);
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
    return listResources(
      origins: origins,
      kinds: const {LocalResourceKind.audio},
    );
  }

  /// 列出资源。
  Future<List<LocalResourceEntry>> listResources({
    Set<TrackResourceOrigin>? origins,
    Set<LocalResourceKind>? kinds,
  }) async {
    final query = _database.select(_database.localResourceEntries)
      ..orderBy([
        (tbl) => drift.OrderingTerm.asc(tbl.trackId),
        (tbl) => drift.OrderingTerm.asc(tbl.kind),
      ]);
    if (kinds != null && kinds.isNotEmpty) {
      query.where((tbl) => tbl.kind.isIn(kinds.map((item) => item.name)));
    }
    if (origins != null && origins.isNotEmpty) {
      query.where((tbl) => tbl.origin.isIn(origins.map((item) => item.name)));
    }
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  /// 保存资源。
  Future<void> saveResource(LocalResourceEntry entry) async {
    final normalizedEntry = _normalizedResourceForSave(entry);
    if (_isBlankTrackId(normalizedEntry.trackId)) {
      return;
    }
    await _database.into(_database.localResourceEntries).insertOnConflictUpdate(
          LocalResourceEntriesCompanion(
            trackId: drift.Value(normalizedEntry.trackId),
            kind: drift.Value(normalizedEntry.kind.name),
            path: drift.Value(normalizedEntry.path),
            origin: drift.Value(normalizedEntry.origin.name),
            sizeBytes: drift.Value(normalizedEntry.sizeBytes),
            createdAtMs: drift.Value(normalizedEntry.createdAt.millisecondsSinceEpoch),
            lastAccessedAtMs: drift.Value(
              normalizedEntry.lastAccessedAt.millisecondsSinceEpoch,
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return (_database.update(_database.localResourceEntries)
          ..where(
            (tbl) => tbl.trackId.equals(normalizedTrackId) & tbl.kind.equals(kind.name),
          ))
        .write(
      LocalResourceEntriesCompanion(
        lastAccessedAtMs: drift.Value(accessedAt.millisecondsSinceEpoch),
      ),
    );
  }

  /// 删除指定资源。
  Future<void> removeResource(String trackId, LocalResourceKind kind) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return (_database.delete(_database.localResourceEntries)
          ..where(
            (tbl) => tbl.trackId.equals(normalizedTrackId) & tbl.kind.equals(kind.name),
          ))
        .go();
  }

  /// 删除指定歌曲的全部资源。
  Future<void> removeTrackResources(String trackId) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return (_database.delete(_database.localResourceEntries)..where((tbl) => tbl.trackId.equals(normalizedTrackId))).go();
  }

  /// 删除指定来源的全部资源。
  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin) {
    return (_database.delete(_database.localResourceEntries)..where((tbl) => tbl.origin.equals(origin.name))).go();
  }

  LocalResourceEntry _normalizedResourceForSave(LocalResourceEntry entry) {
    return entry.copyWith(trackId: _normalizedTrackId(entry.trackId));
  }

  List<String> _candidateTrackIds(Iterable<String> trackIds) {
    final seen = <String>{};
    final result = <String>[];
    for (final trackId in trackIds) {
      final normalizedTrackId = _normalizedTrackId(trackId);
      if (_isBlankTrackId(normalizedTrackId) || !seen.add(normalizedTrackId)) {
        continue;
      }
      result.add(normalizedTrackId);
    }
    return result;
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }

  bool _isBlankTrackId(String trackId) {
    return trackId.isEmpty;
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
