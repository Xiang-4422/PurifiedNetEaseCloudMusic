import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/download_task_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as drift_db;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadTaskDao', () {
    late drift_db.BujuanDriftDatabase database;
    late DownloadTaskDao dao;

    setUp(() {
      database = drift_db.BujuanDriftDatabase.connect(NativeDatabase.memory());
      dao = DownloadTaskDao(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('normalizes track ids before saving, reading, and removing tasks', () async {
      await dao.saveTask(
        _task(
          ' track-1 ',
          DownloadTaskStatus.downloading,
          progress: 0.6,
        ),
      );

      final task = await dao.getTask(' track-1 ');
      final rows = await database.select(database.downloadTasks).get();

      expect(task?.trackId, 'track-1');
      expect(task?.status, DownloadTaskStatus.downloading);
      expect(task?.progress, 0.6);
      expect(rows.map((row) => row.trackId), ['track-1']);

      await dao.removeTask(' track-1 ');

      expect(await dao.getTasks(), isEmpty);
    });

    test('ignores blank track ids before touching download task table', () async {
      await dao.saveTask(_task('   ', DownloadTaskStatus.queued));
      await dao.removeTask('   ');

      expect(await dao.getTask('   '), isNull);
      expect(await dao.getTasks(), isEmpty);
    });
  });
}

DownloadTask _task(
  String trackId,
  DownloadTaskStatus status, {
  double? progress,
}) {
  return DownloadTask(
    trackId: trackId,
    status: status,
    updatedAt: DateTime(2026),
    progress: progress,
  );
}
