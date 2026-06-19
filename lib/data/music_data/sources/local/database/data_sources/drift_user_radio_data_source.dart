import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as db;
import 'package:drift/drift.dart' as drift;

import 'user_scoped_data_source.dart';

/// Drift 实现的用户电台数据源。
class DriftUserRadioDataSource implements UserRadioDataSource {
  /// 创建 Drift 用户电台数据源。
  const DriftUserRadioDataSource({
    required db.BujuanDriftDatabase database,
  }) : _database = database;

  final db.BujuanDriftDatabase _database;

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
      await (_database.delete(_database.userRadioSubscriptions)..where((tbl) => tbl.userId.equals(userId))).go();
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
            (tbl) => tbl.userId.equals(userId) & tbl.radioId.equals(radioId) & tbl.asc.equals(asc),
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
              (tbl) => tbl.userId.equals(userId) & tbl.radioId.equals(radioId) & tbl.asc.equals(asc),
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
}
