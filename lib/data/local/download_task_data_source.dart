import 'package:bujuan/domain/entities/download_task.dart';

/// 下载任务本地数据源。
abstract class DownloadTaskDataSource {
  /// 获取指定歌曲的下载任务。
  Future<DownloadTask?> getTask(String trackId);

  /// 获取下载任务列表。
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  });

  /// 监听下载任务列表。
  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  });

  /// 保存下载任务。
  Future<void> saveTask(DownloadTask task);

  /// 删除指定歌曲的下载任务。
  Future<void> removeTask(String trackId);
}
