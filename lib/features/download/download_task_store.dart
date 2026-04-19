import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/persistent_download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:get_it/get_it.dart';

class DownloadTaskStore {
  DownloadTaskStore({
    DownloadTaskDataSource? dataSource,
  }) : _dataSource = dataSource ??
            (GetIt.instance.isRegistered<DownloadTaskDataSource>()
                ? GetIt.instance<DownloadTaskDataSource>()
                : const PersistentDownloadTaskDataSource());

  final DownloadTaskDataSource _dataSource;

  Future<DownloadTask?> getTask(String trackId) async {
    return _dataSource.getTask(trackId);
  }

  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    return _dataSource.getTasks(statuses: statuses);
  }

  Future<void> saveTask(DownloadTask task) {
    return _dataSource.saveTask(task);
  }

  Future<void> removeTask(String trackId) {
    return _dataSource.removeTask(trackId);
  }
}
