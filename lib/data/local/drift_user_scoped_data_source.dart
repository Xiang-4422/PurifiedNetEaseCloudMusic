import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
import 'package:bujuan/features/radio/radio_data.dart';
import 'package:bujuan/features/user/user_profile_data.dart';
import 'package:drift/drift.dart' as drift;

import 'user_scoped_data_source.dart';

class DriftUserScopedDataSource implements UserScopedDataSource {
  DriftUserScopedDataSource({required db.BujuanDriftDatabase database})
      : _database = database;

  final db.BujuanDriftDatabase _database;

  @override
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

  @override
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

  @override
  Future<List<String>> loadTrackIds(
      String userId, UserTrackListKind kind) async {
    final rows = await (_database.select(_database.userTrackListRefs)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.listKind.equals(kind.name),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return rows.map((row) => row.trackId).toList();
  }

  @override
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

  @override
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

  @override
  Future<void> upsertTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId, {
    int? sortOrder,
  }) async {
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

  @override
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

  @override
  Future<int> nextTrackSortOrder(String userId, UserTrackListKind kind) async {
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

  @override
  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  }) async {
    final normalizedKeyword = keyword?.trim() ?? '';
    final rows = await (_database.select(_database.userPlaylistListItems)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.listKind.equals(kind.name) &
                (normalizedKeyword.isEmpty
                    ? const drift.Constant(true)
                    : tbl.title.like('%$normalizedKeyword%')),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return rows.map(_mapPlaylistItemRow).toList();
  }

  @override
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  ) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.userPlaylistListItems)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.title.like('%$normalizedKeyword%'),
          )
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.sortOrder)]))
        .get();
    return rows.map(_mapPlaylistItemRow).toList();
  }

  @override
  Future<void> replacePlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items,
  ) async {
    await _database.transaction(() async {
      await (_database.delete(_database.userPlaylistListItems)
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
        batch.insertAll(
          _database.userPlaylistListItems,
          items
              .asMap()
              .entries
              .map(
                (entry) => db.UserPlaylistListItemsCompanion.insert(
                  userId: userId,
                  listKind: kind.name,
                  playlistId: entry.value.id,
                  sortOrder: entry.key,
                  title: entry.value.title,
                  coverUrl: drift.Value(entry.value.coverUrl),
                  trackCount: drift.Value(entry.value.trackCount),
                  description: drift.Value(entry.value.description),
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
        _database.userPlaylistListItems,
        items
            .asMap()
            .entries
            .map(
              (entry) => db.UserPlaylistListItemsCompanion(
                userId: drift.Value(userId),
                listKind: drift.Value(kind.name),
                playlistId: drift.Value(entry.value.id),
                sortOrder: drift.Value(startOrder + entry.key),
                title: drift.Value(entry.value.title),
                coverUrl: drift.Value(entry.value.coverUrl),
                trackCount: drift.Value(entry.value.trackCount),
                description: drift.Value(entry.value.description),
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
  ) async {
    final row = await (_database.select(_database.userPlaylistStates)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.playlistId.equals(playlistId),
          ))
        .getSingleOrNull();
    return row?.isSubscribed;
  }

  @override
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

  @override
  Future<void> markSyncMarkerUpdated(String userId, String markerKey) {
    return _database.into(_database.userSyncMarkers).insertOnConflictUpdate(
          db.UserSyncMarkersCompanion(
            userId: drift.Value(userId),
            markerKey: drift.Value(markerKey),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  @override
  Future<void> clearSyncMarker(String userId, String markerKey) {
    return (_database.delete(_database.userSyncMarkers)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.markerKey.equals(markerKey),
          ))
        .go();
  }

  PlaylistSummaryData _mapPlaylistItemRow(db.UserPlaylistListItem row) {
    return PlaylistSummaryData(
      id: row.playlistId,
      title: row.title,
      coverUrl: row.coverUrl,
      trackCount: row.trackCount,
      description: row.description,
    );
  }
}
