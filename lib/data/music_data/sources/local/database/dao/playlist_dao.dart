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
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.playlists)..where((tbl) => tbl.title.like('%$normalizedKeyword%'))).get();
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
    final normalizedPlaylistId = _normalizedPlaylistEntityId(playlistId);
    if (_isBlankPlaylistEntityId(normalizedPlaylistId)) {
      return null;
    }
    final row = await (_database.select(_database.playlists)..where((tbl) => tbl.playlistId.equals(normalizedPlaylistId))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final trackRefsByPlaylistId = await loadTrackRefsByPlaylistIds([
      normalizedPlaylistId,
    ]);
    return _mapPlaylistRow(
      row,
      trackRefs: trackRefsByPlaylistId[normalizedPlaylistId] ?? const [],
    );
  }

  /// 保存歌单列表。
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    final normalizedPlaylists = _normalizedPlaylists(playlists);
    if (normalizedPlaylists.isEmpty) {
      return;
    }
    await _database.transaction(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.playlists,
          normalizedPlaylists
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
      for (final playlist in normalizedPlaylists) {
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
    final normalizedPlaylistId = _normalizedPlaylistEntityId(playlistId);
    if (_isBlankPlaylistEntityId(normalizedPlaylistId)) {
      return Future<void>.value();
    }
    return (_database.delete(_database.playlistTrackRefs)..where((tbl) => tbl.playlistId.equals(normalizedPlaylistId))).go();
  }

  /// 批量加载歌单曲目引用。
  Future<Map<String, List<PlaylistTrackRef>>> loadTrackRefsByPlaylistIds(
    List<String> playlistIds,
  ) async {
    final normalizedPlaylistIds = _normalizedPlaylistEntityIds(playlistIds);
    if (normalizedPlaylistIds.isEmpty) {
      return const {};
    }
    final rows = await (_database.select(_database.playlistTrackRefs)
          ..where((tbl) => tbl.playlistId.isIn(normalizedPlaylistIds))
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const <PlaylistSummaryData>[];
    }
    final refs = await (_database.select(_database.userPlaylistListRefs)
          ..where(
            (tbl) => tbl.userId.equals(normalizedUserId) & tbl.listKind.equals(kind.name),
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const <PlaylistSummaryData>[];
    }
    final refs = await (_database.select(_database.userPlaylistListRefs)
          ..where((tbl) => tbl.userId.equals(normalizedUserId))
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return;
    }
    final normalizedItems = _normalizedPlaylistSummaries(items);
    await _database.transaction(() async {
      await (_database.delete(_database.userPlaylistListRefs)
            ..where(
              (tbl) => tbl.userId.equals(normalizedUserId) & tbl.listKind.equals(kind.name),
            ))
          .go();
      if (normalizedItems.isEmpty) {
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.playlists,
          _playlistSummaryCompanions(normalizedItems),
        );
        batch.insertAll(
          _database.userPlaylistListRefs,
          normalizedItems
              .asMap()
              .entries
              .map(
                (entry) => db.UserPlaylistListRefsCompanion.insert(
                  userId: normalizedUserId,
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
    final normalizedUserId = _normalizedUserId(userId);
    final normalizedItems = _normalizedPlaylistSummaries(items);
    if (_isBlankUserId(normalizedUserId) || normalizedItems.isEmpty) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.playlists,
        _playlistSummaryCompanions(normalizedItems),
      );
      batch.insertAllOnConflictUpdate(
        _database.userPlaylistListRefs,
        normalizedItems
            .asMap()
            .entries
            .map(
              (entry) => db.UserPlaylistListRefsCompanion(
                userId: drift.Value(normalizedUserId),
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

  List<PlaylistEntity> _normalizedPlaylists(List<PlaylistEntity> playlists) {
    return playlists.map(_normalizedPlaylistForSave).where((playlist) => !_isBlankPlaylistEntityId(playlist.id)).toList();
  }

  PlaylistEntity _normalizedPlaylistForSave(PlaylistEntity playlist) {
    final normalizedPlaylistId = _normalizedPlaylistEntityId(playlist.id);
    return playlist.copyWith(
      id: normalizedPlaylistId,
      sourceType: MusicResourceId.sourceTypeOf(normalizedPlaylistId),
      sourceId: MusicResourceId.toSourceId(normalizedPlaylistId),
      trackRefs: _normalizedPlaylistTrackRefs(playlist.trackRefs),
    );
  }

  List<PlaylistTrackRef> _normalizedPlaylistTrackRefs(
    List<PlaylistTrackRef> refs,
  ) {
    final seen = <String>{};
    final result = <PlaylistTrackRef>[];
    for (final ref in refs) {
      final normalizedTrackId = _normalizedTrackId(ref.trackId);
      if (_isBlankTrackId(normalizedTrackId) || !seen.add(normalizedTrackId)) {
        continue;
      }
      result.add(
        PlaylistTrackRef(
          trackId: normalizedTrackId,
          order: ref.order,
          addedAt: ref.addedAt,
        ),
      );
    }
    return result;
  }

  String _normalizedUserId(String userId) {
    return userId.trim();
  }

  bool _isBlankUserId(String userId) {
    return userId.isEmpty;
  }

  String _normalizedPlaylistEntityId(String playlistId) {
    return MusicResourceId.toNeteaseEntityId(playlistId.trim());
  }

  bool _isBlankPlaylistEntityId(String playlistId) {
    return playlistId.isEmpty;
  }

  List<String> _normalizedPlaylistEntityIds(List<String> playlistIds) {
    final seen = <String>{};
    final result = <String>[];
    for (final playlistId in playlistIds) {
      final normalizedPlaylistId = _normalizedPlaylistEntityId(playlistId);
      if (_isBlankPlaylistEntityId(normalizedPlaylistId) || !seen.add(normalizedPlaylistId)) {
        continue;
      }
      result.add(normalizedPlaylistId);
    }
    return result;
  }

  String _normalizedTrackId(String trackId) {
    return MusicResourceId.toNeteaseEntityId(trackId.trim());
  }

  bool _isBlankTrackId(String trackId) {
    return trackId.isEmpty;
  }

  List<PlaylistSummaryData> _normalizedPlaylistSummaries(
    List<PlaylistSummaryData> items,
  ) {
    return items
        .map(
          (item) => item.copyWith(
            id: _normalizedPlaylistEntityId(item.id),
          ),
        )
        .where((item) => !_isBlankPlaylistEntityId(item.id))
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
