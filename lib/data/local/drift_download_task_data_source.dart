import 'package:bujuan/domain/entities/download_task.dart' as domain;

import 'dao/download_task_dao.dart';
import 'download_task_data_source.dart';

class DriftDownloadTaskDataSource implements DownloadTaskDataSource {
  DriftDownloadTaskDataSource({required DownloadTaskDao dao}) : _dao = dao;

  final DownloadTaskDao _dao;

  @override
  Future<domain.DownloadTask?> getTask(String trackId) {
    return _dao.getTask(trackId);
  }

  @override
  Future<List<domain.DownloadTask>> getTasks({
    Set<domain.DownloadTaskStatus>? statuses,
  }) {
    return _dao.getTasks(statuses: statuses);
  }

  @override
  Stream<List<domain.DownloadTask>> watchTasks({
    Set<domain.DownloadTaskStatus>? statuses,
  }) {
    return _dao.watchTasks(statuses: statuses);
  }

  @override
  Future<void> saveTask(domain.DownloadTask task) {
    return _dao.saveTask(task);
  }

  @override
  Future<void> removeTask(String trackId) {
    return _dao.removeTask(trackId);
  }
}
