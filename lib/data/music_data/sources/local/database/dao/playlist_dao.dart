import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as db;
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/playlist_track_ref.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:drift/drift.dart' as drift;

/// 歌单 DAO。
class PlaylistDao {
  /// 创建歌单 DAO。
  PlaylistDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  /// 搜索歌单。
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.playlists)..where((tbl) => tbl.title.like('%$keyword%'))).get();
    final trackRefsByPlaylistId = await loadTrackRefsByPlaylistIds(
      rows.map((row) => row.playlistId).toList(),
    );
    return rows
        .map(
          (row) => _mapPlaylistRow(
            row,
            trackRefs: trackRefsByPlaylistId[row.playlistId] ?? const [],
          ),
        )
        .toList();
  }

  /// 获取歌单。
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final row = await (_database.select(_database.playlists)..where((tbl) => tbl.playlistId.equals(playlistId))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final trackRefsByPlaylistId = await loadTrackRefsByPlaylistIds([
      playlistId,
    ]);
    return _mapPlaylistRow(
      row,
      trackRefs: trackRefsByPlaylistId[playlistId] ?? const [],
    );
  }

  /// 保存歌单列表。
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    await _database.transaction(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.playlists,
          playlists
              .map(
                (playlist) => db.PlaylistsCompanion(
                  playlistId: drift.Value(playlist.id),
                  sourceType: drift.Value(playlist.sourceType.name),
                  sourceId: drift.Value(playlist.sourceId),
                  title: drift.Value(playlist.title),
                  description: drift.Value(playlist.description),
                  coverUrl: drift.Value(playlist.coverUrl),
                  trackCount: drift.Value(playlist.trackCount),
                ),
              )
              .toList(),
        );
      });
      for (final playlist in playlists) {
        await clearPlaylistTrackRefs(playlist.id);
        if (playlist.trackRefs.isEmpty) {
          continue;
        }
        await _database.batch((batch) {
          batch.insertAll(
            _database.playlistTrackRefs,
            playlist.trackRefs
                .map(
                  (trackRef) => db.PlaylistTrackRefsCompanion.insert(
                    playlistId: playlist.id,
                    trackId: trackRef.trackId,
                    order: trackRef.order,
                    addedAt: drift.Value(trackRef.addedAt),
                  ),
                )
                .toList(),
          );
        });
      }
    });
  }

  /// 清空歌单曲目引用。
  Future<void> clearPlaylistTrackRefs(String playlistId) {
    return (_database.delete(_database.playlistTrackRefs)..where((tbl) => tbl.playlistId.equals(playlistId))).go();
  }

  /// 批量加载歌单曲目引用。
  Future<Map<String, List<PlaylistTrackRef>>> loadTrackRefsByPlaylistIds(
    List<String> playlistIds,
  ) async {
    if (playlistIds.isEmpty) {
      return const {};
    }
    final rows = await (_database.select(_database.playlistTrackRefs)
          ..where((tbl) => tbl.playlistId.isIn(playlistIds))
          ..orderBy([
            (tbl) => drift.OrderingTerm.asc(tbl.order),
          ]))
        .get();
    final refsByPlaylistId = <String, List<PlaylistTrackRef>>{};
    for (final row in rows) {
      refsByPlaylistId.putIfAbsent(row.playlistId, () => []).add(
            PlaylistTrackRef(
              trackId: row.trackId,
              order: row.order,
              addedAt: row.addedAt,
            ),
          );
    }
    return refsByPlaylistId;
  }

  /// 读取用户歌单摘要列表。
  Future<List<PlaylistSummaryData>> loadUserPlaylistItems(
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

  /// 搜索用户歌单摘要。
  Future<List<PlaylistSummaryData>> searchUserPlaylistItems(
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

  /// 替换用户歌单摘要列表。
  Future<void> replaceUserPlaylistItems(
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
          _playlistSummaryCompanions(items),
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

  /// 追加用户歌单摘要列表。
  Future<void> appendUserPlaylistItems(
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
        _playlistSummaryCompanions(items),
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
    return refs.map((ref) => playlistsById[ref.playlistId]).whereType<db.Playlist>().map(_mapPlaylistSummaryRow).toList();
  }

  List<db.PlaylistsCompanion> _playlistSummaryCompanions(
    List<PlaylistSummaryData> items,
  ) {
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

  PlaylistEntity _mapPlaylistRow(
    db.Playlist row, {
    required List<PlaylistTrackRef> trackRefs,
  }) {
    return PlaylistEntity(
      id: row.playlistId,
      sourceType: SourceType.values.firstWhere(
        (item) => item.name == row.sourceType,
        orElse: () => SourceType.unknown,
      ),
      sourceId: row.sourceId,
      title: row.title,
      description: row.description,
      coverUrl: row.coverUrl,
      trackCount: row.trackCount,
      trackRefs: trackRefs,
    );
  }

  PlaylistSummaryData _mapPlaylistSummaryRow(db.Playlist row) {
    return PlaylistSummaryData(
      id: row.sourceId,
      title: row.title,
      coverUrl: row.coverUrl,
      trackCount: row.trackCount,
      description: row.description,
    );
  }
}
