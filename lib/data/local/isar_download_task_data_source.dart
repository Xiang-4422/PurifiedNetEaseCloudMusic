import 'package:bujuan/core/database/isar_download_task_entity.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:isar/isar.dart';

import 'download_task_data_source.dart';
import 'download_task_record_codec.dart';

class IsarDownloadTaskDataSource implements DownloadTaskDataSource {
  IsarDownloadTaskDataSource({required Isar isar}) : _isar = isar;

  final Isar _isar;

  @override
  Future<DownloadTask?> getTask(String trackId) async {
    final entity = await _isar.isarDownloadTaskEntitys
        .where()
        .trackIdEqualTo(trackId)
        .findFirst();
    if (entity == null) {
      return null;
    }
    return DownloadTaskRecordCodec.decodeEntity(entity);
  }

  @override
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    final entities = await _isar.isarDownloadTaskEntitys.where().findAll();
    final tasks = entities
        .map(DownloadTaskRecordCodec.decodeEntity)
        .where((task) => statuses == null || statuses.contains(task.status))
        .toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return tasks;
  }

  @override
  Future<void> saveTask(DownloadTask task) async {
    final entity = DownloadTaskRecordCodec.encodeEntity(task);
    await _isar.writeTxn(() async {
      await _isar.isarDownloadTaskEntitys.putByTrackId(entity);
    });
  }

  @override
  Future<void> removeTask(String trackId) async {
    await _isar.writeTxn(() async {
      await _isar.isarDownloadTaskEntitys.where().trackIdEqualTo(trackId).deleteAll();
    });
  }
}
