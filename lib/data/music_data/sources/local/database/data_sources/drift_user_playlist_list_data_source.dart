import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as db;
import 'package:drift/drift.dart' as drift;

import 'user_scoped_data_source.dart';

/// Drift 实现的用户歌单列表数据源。
class DriftUserPlaylistListDataSource implements UserPlaylistListDataSource {
  /// 创建 Drift 用户歌单列表数据源。
  const DriftUserPlaylistListDataSource({
    required db.BujuanDriftDatabase database,
  }) : _database = database;

  final db.BujuanDriftDatabase _database;

  @override
  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  }) async {
    final refs = await (_database.select(_database.userPlaylistListRefs)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.listKind.equals(kind.name),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return _loadPlaylistSummariesFromRefs(
      refs,
      keyword: keyword,
    );
  }

  @override
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  ) async {
    final refs = await (_database.select(_database.userPlaylistListRefs)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return _loadPlaylistSummariesFromRefs(
      refs,
      keyword: keyword,
    );
  }

  @override
  Future<void> replacePlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items,
  ) async {
    await _database.transaction(() async {
      await (_database.delete(_database.userPlaylistListRefs)
            ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.listKind.equals(kind.name),
            ))
          .go();
      if (items.isEmpty) {
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.playlists,
          _playlistCompanions(items),
        );
        batch.insertAll(
          _database.userPlaylistListRefs,
          items
              .asMap()
              .entries
              .map(
                (entry) => db.UserPlaylistListRefsCompanion.insert(
                  userId: userId,
                  listKind: kind.name,
                  playlistId: MusicResourceId.toNeteaseEntityId(entry.value.id),
                  sortOrder: entry.key,
                  updatedAtMs: now,
                ),
              )
              .toList(),
        );
      });
    });
  }

  @override
  Future<void> appendPlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items, {
    required int startOrder,
  }) async {
    if (items.isEmpty) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.playlists,
        _playlistCompanions(items),
      );
      batch.insertAllOnConflictUpdate(
        _database.userPlaylistListRefs,
        items
            .asMap()
            .entries
            .map(
              (entry) => db.UserPlaylistListRefsCompanion(
                userId: drift.Value(userId),
                listKind: drift.Value(kind.name),
                playlistId: drift.Value(MusicResourceId.toNeteaseEntityId(entry.value.id)),
                sortOrder: drift.Value(startOrder + entry.key),
                updatedAtMs: drift.Value(now),
              ),
            )
            .toList(),
      );
    });
  }

  Future<List<PlaylistSummaryData>> _loadPlaylistSummariesFromRefs(
    List<db.UserPlaylistListRef> refs, {
    String? keyword,
  }) async {
    if (refs.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword?.trim() ?? '';
    final playlistRows = await (_database.select(_database.playlists)
          ..where((tbl) => tbl.playlistId.isIn(refs.map((item) => item.playlistId)))
          ..where(
            (tbl) => normalizedKeyword.isEmpty ? const drift.Constant(true) : tbl.title.like('%$normalizedKeyword%'),
          ))
        .get();
    final playlistsById = {
      for (final row in playlistRows) row.playlistId: row,
    };
    return refs.map((ref) => playlistsById[ref.playlistId]).whereType<db.Playlist>().map(_mapPlaylistRow).toList();
  }

  List<db.PlaylistsCompanion> _playlistCompanions(List<PlaylistSummaryData> items) {
    return items
        .map(
          (item) => db.PlaylistsCompanion(
            playlistId: drift.Value(MusicResourceId.toNeteaseEntityId(item.id)),
            sourceType: drift.Value(MusicResourceId.sourceTypeOf(item.id).name),
            sourceId: drift.Value(MusicResourceId.toSourceId(item.id)),
            title: drift.Value(item.title),
            description: drift.Value(item.description),
            coverUrl: drift.Value(item.coverUrl),
            trackCount: drift.Value(item.trackCount),
          ),
        )
        .toList();
  }

  PlaylistSummaryData _mapPlaylistRow(db.Playlist row) {
    return PlaylistSummaryData(
      id: row.sourceId,
      title: row.title,
      coverUrl: row.coverUrl,
      trackCount: row.trackCount,
      description: row.description,
    );
  }
}
