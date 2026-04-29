import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/radio_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';
import 'package:drift/drift.dart' as drift;

import 'dao/user_dao.dart';
import 'user_scoped_data_source.dart';

class DriftUserScopedDataSource implements UserScopedDataSource {
  DriftUserScopedDataSource({
    required db.BujuanDriftDatabase database,
    required UserDao userDao,
  })  : _database = database,
        _userDao = userDao;

  final db.BujuanDriftDatabase _database;
  final UserDao _userDao;

  @override
  Future<UserProfileData?> loadProfile(String userId) =>
      _userDao.loadProfile(userId);

  @override
  Future<void> saveProfile(UserProfileData profile) =>
      _userDao.saveProfile(profile);

  @override
  Future<List<String>> loadTrackIds(String userId, UserTrackListKind kind) =>
      _userDao.loadTrackIds(userId, kind);

  @override
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  ) => _userDao.replaceTrackList(userId, kind, trackIds);

  @override
  Future<void> appendTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds, {
    required int startOrder,
  }) {
    return _userDao.appendTrackList(
      userId,
      kind,
      trackIds,
      startOrder: startOrder,
    );
  }

  @override
  Future<void> upsertTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId, {
    int? sortOrder,
  }) {
    return _userDao.upsertTrackRef(
      userId,
      kind,
      trackId,
      sortOrder: sortOrder,
    );
  }

  @override
  Future<void> deleteTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId,
  ) {
    return _userDao.deleteTrackRef(userId, kind, trackId);
  }

  @override
  Future<int> nextTrackSortOrder(String userId, UserTrackListKind kind) =>
      _userDao.nextTrackSortOrder(userId, kind);

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
              (tbl) =>
                  tbl.userId.equals(userId) & tbl.listKind.equals(kind.name),
            ))
          .go();
      if (items.isEmpty) {
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.userPlaylistSnapshots,
          items
              .map(
                (item) => db.UserPlaylistSnapshotsCompanion(
                  playlistId: drift.Value(_toEntityPlaylistId(item.id)),
                  sourceId: drift.Value(item.id),
                  title: drift.Value(item.title),
                  coverUrl: drift.Value(item.coverUrl),
                  trackCount: drift.Value(item.trackCount),
                  description: drift.Value(item.description),
                  updatedAtMs: drift.Value(now),
                ),
              )
              .toList(),
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
                  playlistId: _toEntityPlaylistId(entry.value.id),
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
        _database.userPlaylistSnapshots,
        items
            .map(
              (item) => db.UserPlaylistSnapshotsCompanion(
                playlistId: drift.Value(_toEntityPlaylistId(item.id)),
                sourceId: drift.Value(item.id),
                title: drift.Value(item.title),
                coverUrl: drift.Value(item.coverUrl),
                trackCount: drift.Value(item.trackCount),
                description: drift.Value(item.description),
                updatedAtMs: drift.Value(now),
              ),
            )
            .toList(),
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
                playlistId: drift.Value(_toEntityPlaylistId(entry.value.id)),
                sortOrder: drift.Value(startOrder + entry.key),
                updatedAtMs: drift.Value(now),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  ) {
    return _userDao.loadPlaylistSubscriptionState(userId, playlistId);
  }

  @override
  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  ) {
    return _userDao.savePlaylistSubscriptionState(
      userId,
      playlistId,
      isSubscribed,
    );
  }

  @override
  Future<List<RadioSummaryData>> loadSubscribedRadios(String userId) async {
    final rows = await (_database.select(_database.userRadioSubscriptions)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return rows
        .map(
          (row) => RadioSummaryData(
            id: row.radioId,
            name: row.name,
            coverUrl: row.coverUrl,
            lastProgramName: row.lastProgramName,
          ),
        )
        .toList();
  }

  @override
  Future<void> replaceSubscribedRadios(
    String userId,
    List<RadioSummaryData> items,
  ) async {
    await _database.transaction(() async {
      await (_database.delete(_database.userRadioSubscriptions)
            ..where((tbl) => tbl.userId.equals(userId)))
          .go();
      if (items.isEmpty) {
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.batch((batch) {
        batch.insertAll(
          _database.userRadioSubscriptions,
          items
              .asMap()
              .entries
              .map(
                (entry) => db.UserRadioSubscriptionsCompanion.insert(
                  userId: userId,
                  radioId: entry.value.id,
                  sortOrder: entry.key,
                  name: entry.value.name,
                  coverUrl: entry.value.coverUrl,
                  lastProgramName: entry.value.lastProgramName,
                  updatedAtMs: now,
                ),
              )
              .toList(),
        );
      });
    });
  }

  @override
  Future<void> appendSubscribedRadios(
    String userId,
    List<RadioSummaryData> items, {
    required int startOrder,
  }) async {
    if (items.isEmpty) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.userRadioSubscriptions,
        items
            .asMap()
            .entries
            .map(
              (entry) => db.UserRadioSubscriptionsCompanion(
                userId: drift.Value(userId),
                radioId: drift.Value(entry.value.id),
                sortOrder: drift.Value(startOrder + entry.key),
                name: drift.Value(entry.value.name),
                coverUrl: drift.Value(entry.value.coverUrl),
                lastProgramName: drift.Value(entry.value.lastProgramName),
                updatedAtMs: drift.Value(now),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<List<RadioProgramData>> loadPrograms(
    String userId,
    String radioId, {
    required bool asc,
  }) async {
    final rows = await (_database.select(_database.userRadioPrograms)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.radioId.equals(radioId) &
                tbl.asc.equals(asc),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return rows
        .map(
          (row) => RadioProgramData(
            id: row.programId,
            mainTrackId: row.mainTrackId,
            title: row.title,
            coverUrl: row.coverUrl,
            artistName: row.artistName,
            albumTitle: row.albumTitle,
            durationMs: row.durationMs,
          ),
        )
        .toList();
  }

  @override
  Future<void> replacePrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.userRadioPrograms)
            ..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.radioId.equals(radioId) &
                  tbl.asc.equals(asc),
            ))
          .go();
      if (items.isEmpty) {
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.batch((batch) {
        batch.insertAll(
          _database.userRadioPrograms,
          items
              .asMap()
              .entries
              .map(
                (entry) => db.UserRadioProgramsCompanion.insert(
                  userId: userId,
                  radioId: radioId,
                  asc: asc,
                  programId: entry.value.id,
                  sortOrder: entry.key,
                  mainTrackId: entry.value.mainTrackId,
                  title: entry.value.title,
                  coverUrl: entry.value.coverUrl,
                  artistName: entry.value.artistName,
                  albumTitle: entry.value.albumTitle,
                  durationMs: entry.value.durationMs,
                  updatedAtMs: now,
                ),
              )
              .toList(),
        );
      });
    });
  }

  @override
  Future<void> appendPrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
    required int startOrder,
  }) async {
    if (items.isEmpty) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.userRadioPrograms,
        items
            .asMap()
            .entries
            .map(
              (entry) => db.UserRadioProgramsCompanion(
                userId: drift.Value(userId),
                radioId: drift.Value(radioId),
                asc: drift.Value(asc),
                programId: drift.Value(entry.value.id),
                sortOrder: drift.Value(startOrder + entry.key),
                mainTrackId: drift.Value(entry.value.mainTrackId),
                title: drift.Value(entry.value.title),
                coverUrl: drift.Value(entry.value.coverUrl),
                artistName: drift.Value(entry.value.artistName),
                albumTitle: drift.Value(entry.value.albumTitle),
                durationMs: drift.Value(entry.value.durationMs),
                updatedAtMs: drift.Value(now),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<DateTime?> loadSyncMarker(String userId, String markerKey) {
    return _userDao.loadSyncMarker(userId, markerKey);
  }

  @override
  Future<void> markSyncMarkerUpdated(String userId, String markerKey) {
    return _userDao.markSyncMarkerUpdated(userId, markerKey);
  }

  @override
  Future<void> clearSyncMarker(String userId, String markerKey) {
    return _userDao.clearSyncMarker(userId, markerKey);
  }

  Future<List<PlaylistSummaryData>> _loadPlaylistSummariesFromRefs(
    List<db.UserPlaylistListRef> refs, {
    String? keyword,
  }) async {
    if (refs.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword?.trim() ?? '';
    final snapshotRows =
        await (_database.select(_database.userPlaylistSnapshots)
              ..where((tbl) =>
                  tbl.playlistId.isIn(refs.map((item) => item.playlistId)))
              ..where(
                (tbl) => normalizedKeyword.isEmpty
                    ? const drift.Constant(true)
                    : tbl.title.like('%$normalizedKeyword%'),
              ))
            .get();
    final snapshotsById = {
      for (final row in snapshotRows) row.playlistId: row,
    };
    return refs
        .map((ref) => snapshotsById[ref.playlistId])
        .whereType<db.UserPlaylistSnapshot>()
        .map(_mapPlaylistSnapshotRow)
        .toList();
  }

  PlaylistSummaryData _mapPlaylistSnapshotRow(db.UserPlaylistSnapshot row) {
    return PlaylistSummaryData(
      id: row.sourceId,
      title: row.title,
      coverUrl: row.coverUrl,
      trackCount: row.trackCount,
      description: row.description,
    );
  }

  String _toEntityPlaylistId(String playlistId) {
    if (playlistId.startsWith('netease:') || playlistId.startsWith('local:')) {
      return playlistId;
    }
    return 'netease:$playlistId';
  }
}
