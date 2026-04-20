import 'package:bujuan/core/database/drift_database.dart';
import 'package:bujuan/domain/entities/download_task.dart' as domain;
import 'package:drift/drift.dart' as drift;

import 'download_task_data_source.dart';

class DriftDownloadTaskDataSource implements DownloadTaskDataSource {
  DriftDownloadTaskDataSource({required BujuanDriftDatabase database})
      : _database = database;

  final BujuanDriftDatabase _database;

  @override
  Future<domain.DownloadTask?> getTask(String trackId) async {
    final row = await (_database.select(_database.downloadTasks)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapRow(row);
  }

  @override
  Future<List<domain.DownloadTask>> getTasks({
    Set<domain.DownloadTaskStatus>? statuses,
  }) async {
    final rows = await (_database.select(_database.downloadTasks)
          ..orderBy([
            (tbl) => drift.OrderingTerm.desc(tbl.updatedAtMs),
          ]))
        .get();
    return rows
        .map(_mapRow)
        .where((task) => statuses == null || statuses.contains(task.status))
        .toList();
  }

  @override
  Future<void> saveTask(domain.DownloadTask task) {
    return _database.into(_database.downloadTasks).insertOnConflictUpdate(
          DownloadTasksCompanion(
            trackId: drift.Value(task.trackId),
            status: drift.Value(task.status.name),
            updatedAtMs: drift.Value(task.updatedAt.millisecondsSinceEpoch),
            progress: drift.Value(task.progress),
            localPath: drift.Value(task.localPath),
            artworkPath: drift.Value(task.artworkPath),
            lyricsPath: drift.Value(task.lyricsPath),
            failureReason: drift.Value(task.failureReason),
          ),
        );
  }

  @override
  Future<void> removeTask(String trackId) {
    return (_database.delete(_database.downloadTasks)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .go();
  }

  domain.DownloadTask _mapRow(DownloadTask row) {
    return domain.DownloadTask(
      trackId: row.trackId,
      status: domain.DownloadTaskStatus.values.firstWhere(
        (item) => item.name == row.status,
        orElse: () => domain.DownloadTaskStatus.queued,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs),
      progress: row.progress,
      localPath: row.localPath,
      artworkPath: row.artworkPath,
      lyricsPath: row.lyricsPath,
      failureReason: row.failureReason,
    );
  }
}
