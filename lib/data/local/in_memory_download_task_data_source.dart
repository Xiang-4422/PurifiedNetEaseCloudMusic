import 'package:bujuan/domain/entities/download_task.dart';

import 'download_task_data_source.dart';

class InMemoryDownloadTaskDataSource implements DownloadTaskDataSource {
  const InMemoryDownloadTaskDataSource();

  static final Map<String, DownloadTask> _tasks = {};

  @override
  Future<DownloadTask?> getTask(String trackId) async {
    return _tasks[trackId];
  }

  @override
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    final tasks = _tasks.values
        .where((task) => statuses == null || statuses.contains(task.status))
        .toList();
    tasks.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return tasks;
  }

  @override
  Future<void> saveTask(DownloadTask task) async {
    _tasks[task.trackId] = task;
  }

  @override
  Future<void> removeTask(String trackId) async {
    _tasks.remove(trackId);
  }
}
