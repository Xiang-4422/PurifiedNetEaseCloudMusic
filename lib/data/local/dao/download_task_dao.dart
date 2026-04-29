import 'package:bujuan/core/database/drift_database.dart';
import 'package:bujuan/domain/entities/download_task.dart' as domain;
import 'package:drift/drift.dart' as drift;

class DownloadTaskDao {
  DownloadTaskDao({required BujuanDriftDatabase database})
      : _database = database;

  final BujuanDriftDatabase _database;

  Future<domain.DownloadTask?> getTask(String trackId) async {
    final row = await (_database.select(_database.downloadTasks)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapRow(row);
  }

  Future<List<domain.DownloadTask>> getTasks({
    Set<domain.DownloadTaskStatus>? statuses,
  }) {
    return _buildTaskQuery(statuses: statuses).get().then(
          (rows) => rows.map(_mapRow).toList(),
        );
  }

  Stream<List<domain.DownloadTask>> watchTasks({
    Set<domain.DownloadTaskStatus>? statuses,
  }) {
    return _buildTaskQuery(statuses: statuses).watch().map(
          (rows) => rows.map(_mapRow).toList(),
        );
  }

  Future<void> saveTask(domain.DownloadTask task) {
    return _database.into(_database.downloadTasks).insertOnConflictUpdate(
          DownloadTasksCompanion(
            trackId: drift.Value(task.trackId),
            status: drift.Value(task.status.name),
            updatedAtMs: drift.Value(task.updatedAt.millisecondsSinceEpoch),
            progress: drift.Value(task.progress),
            temporaryPath: drift.Value(task.temporaryPath),
            failureReason: drift.Value(task.failureReason),
          ),
        );
  }

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
      temporaryPath: row.temporaryPath,
      failureReason: row.failureReason,
    );
  }

  drift.Selectable<DownloadTask> _buildTaskQuery({
    Set<domain.DownloadTaskStatus>? statuses,
  }) {
    final query = _database.select(_database.downloadTasks)
      ..orderBy([
        (tbl) => drift.OrderingTerm.desc(tbl.updatedAtMs),
      ]);
    if (statuses != null && statuses.isNotEmpty) {
      query.where(
        (tbl) => tbl.status.isIn(statuses.map((item) => item.name)),
      );
    }
    return query;
  }
}
