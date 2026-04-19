import 'package:bujuan/domain/entities/download_task.dart';

abstract class DownloadTaskDataSource {
  Future<DownloadTask?> getTask(String trackId);

  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  });

  Future<void> saveTask(DownloadTask task);

  Future<void> removeTask(String trackId);
}
