import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

class DownloadTaskStateStore {
  DownloadTaskStateStore({
    required DownloadTaskDataSource taskDataSource,
    required LibraryRepository libraryRepository,
  })  : _taskDataSource = taskDataSource,
        _libraryRepository = libraryRepository;

  final DownloadTaskDataSource _taskDataSource;
  final LibraryRepository _libraryRepository;

  Future<DownloadTask?> getTask(String trackId) {
    return _taskDataSource.getTask(trackId);
  }

  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskDataSource.getTasks(statuses: statuses);
  }

  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskDataSource.watchTasks(statuses: statuses);
  }

  Future<void> clearTask(String trackId) {
    return _taskDataSource.removeTask(trackId);
  }

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
