import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:drift/drift.dart' as drift;

class PlaylistDao {
  PlaylistDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.playlists)
          ..where((tbl) => tbl.title.like('%$keyword%')))
        .get();
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

  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final row = await (_database.select(_database.playlists)
          ..where((tbl) => tbl.playlistId.equals(playlistId)))
        .getSingleOrNull();
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

  Future<void> clearPlaylistTrackRefs(String playlistId) {
    return (_database.delete(_database.playlistTrackRefs)
          ..where((tbl) => tbl.playlistId.equals(playlistId)))
        .go();
  }

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
}
