import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

/// 下载任务状态存储，集中更新任务状态并回读曲目信息。
class DownloadTaskStateStore {
  /// 创建下载任务状态存储。
  DownloadTaskStateStore({
    required DownloadTaskDataSource taskDataSource,
    required LibraryRepository libraryRepository,
  })  : _taskDataSource = taskDataSource,
        _libraryRepository = libraryRepository;

  final DownloadTaskDataSource _taskDataSource;
  final LibraryRepository _libraryRepository;

  /// 获取指定歌曲的下载任务。
  Future<DownloadTask?> getTask(String trackId) {
    return _taskDataSource.getTask(trackId);
  }

  /// 获取下载任务列表。
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskDataSource.getTasks(statuses: statuses);
  }

  /// 监听下载任务列表。
  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskDataSource.watchTasks(statuses: statuses);
  }

  /// 清理指定歌曲的下载任务。
  Future<void> clearTask(String trackId) {
    return _taskDataSource.removeTask(trackId);
  }

  /// 标记任务进入排队状态。
  Future<Track?> markQueued(String trackId, {String? temporaryPath}) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.queued,
        updatedAt: DateTime.now(),
        progress: 0,
        temporaryPath: temporaryPath ?? currentTask?.temporaryPath,
      ),
    );
    return _libraryRepository.getTrack(trackId);
  }

  /// 标记任务进入下载中状态。
  Future<Track?> markDownloading(
    String trackId, {
    double? progress,
    String? temporaryPath,
  }) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.downloading,
        updatedAt: DateTime.now(),
        progress: progress ?? 0,
        temporaryPath: temporaryPath ?? currentTask?.temporaryPath,
      ),
    );
    return _libraryRepository.getTrack(trackId);
  }

  /// 标记任务失败。
  Future<Track?> markFailed(String trackId, {String? reason}) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.failed,
        updatedAt: DateTime.now(),
        progress: currentTask?.progress,
        temporaryPath: currentTask?.temporaryPath,
        failureReason: reason,
      ),
    );
    return _libraryRepository.getTrack(trackId);
  }
}
