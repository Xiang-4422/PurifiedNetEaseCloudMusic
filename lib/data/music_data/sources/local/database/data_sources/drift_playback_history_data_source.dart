import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:drift/drift.dart' as drift;

import 'playback_history_data_source.dart';

/// Drift 实现的播放历史数据源。
class DriftPlaybackHistoryDataSource implements PlaybackHistoryDataSource {
  /// 创建 Drift 播放历史数据源。
  DriftPlaybackHistoryDataSource({required BujuanDriftDatabase database}) : _database = database;

  final BujuanDriftDatabase _database;

  @override
  Future<void> recordPlayedTrack(
    String trackId, {
    DateTime? playedAt,
  }) {
    final normalizedTrackId = trackId.trim();
    if (normalizedTrackId.isEmpty) {
      return Future<void>.value();
    }
    final timestamp = (playedAt ?? DateTime.now()).millisecondsSinceEpoch;
    return _database.into(_database.playbackHistoryEntries).insertOnConflictUpdate(
          PlaybackHistoryEntriesCompanion(
            trackId: drift.Value(normalizedTrackId),
            playedAtMs: drift.Value(timestamp),
          ),
        );
  }

  @override
  Future<List<String>> loadRecentTrackIds({int limit = 20}) async {
    if (limit <= 0) {
      return const [];
    }
    final rows = await (_database.select(_database.playbackHistoryEntries)
          ..orderBy([
            (tbl) => drift.OrderingTerm.desc(tbl.playedAtMs),
          ])
          ..limit(limit))
        .get();
    return rows.map((row) => row.trackId).toList(growable: false);
  }

  @override
  Future<void> prune({int maxEntries = 100}) async {
    if (maxEntries <= 0) {
      await _database.delete(_database.playbackHistoryEntries).go();
      return;
    }
    final rows = await (_database.select(_database.playbackHistoryEntries)
          ..orderBy([
            (tbl) => drift.OrderingTerm.desc(tbl.playedAtMs),
          ]))
        .get();
    final staleTrackIds = rows.skip(maxEntries).map((row) => row.trackId).toList(growable: false);
    if (staleTrackIds.isEmpty) {
      return;
    }
    await (_database.delete(_database.playbackHistoryEntries)..where((tbl) => tbl.trackId.isIn(staleTrackIds))).go();
  }
}
