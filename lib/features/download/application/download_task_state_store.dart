import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';

/// 下载任务状态存储，集中更新任务状态并回读曲目信息。
class DownloadTaskStateStore {
  /// 创建下载任务状态存储。
  DownloadTaskStateStore({
    required DownloadTaskDataSource taskDataSource,
    required MusicDataRepository musicDataRepository,
  })  : _taskDataSource = taskDataSource,
        _musicDataRepository = musicDataRepository;

  final DownloadTaskDataSource _taskDataSource;
  final MusicDataRepository _musicDataRepository;

  /// 获取指定歌曲的下载任务。
  Future<DownloadTask?> getTask(String trackId) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<DownloadTask?>.value();
    }
    return _getCurrentTask(trackId, normalizedTrackId);
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return _clearTaskAliases(trackId, normalizedTrackId);
  }

  /// 标记任务进入排队状态。
  Future<Track?> markQueued(String trackId, {String? temporaryPath}) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final currentTask = await _getCurrentTask(trackId, normalizedTrackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: normalizedTrackId,
        status: DownloadTaskStatus.queued,
        updatedAt: DateTime.now(),
        progress: 0,
        temporaryPath: temporaryPath ?? currentTask?.temporaryPath,
      ),
    );
    await _removeRawTaskIfNeeded(trackId, normalizedTrackId);
    return _musicDataRepository.getTrack(normalizedTrackId);
  }

  /// 标记任务进入下载中状态。
  Future<Track?> markDownloading(
    String trackId, {
    double? progress,
    String? temporaryPath,
  }) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final currentTask = await _getCurrentTask(trackId, normalizedTrackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: normalizedTrackId,
        status: DownloadTaskStatus.downloading,
        updatedAt: DateTime.now(),
        progress: progress ?? 0,
        temporaryPath: temporaryPath ?? currentTask?.temporaryPath,
      ),
    );
    await _removeRawTaskIfNeeded(trackId, normalizedTrackId);
    return _musicDataRepository.getTrack(normalizedTrackId);
  }

  /// 标记任务失败。
  Future<Track?> markFailed(String trackId, {String? reason}) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final currentTask = await _getCurrentTask(trackId, normalizedTrackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: normalizedTrackId,
        status: DownloadTaskStatus.failed,
        updatedAt: DateTime.now(),
        progress: currentTask?.progress,
        temporaryPath: currentTask?.temporaryPath,
        failureReason: reason,
      ),
    );
    await _removeRawTaskIfNeeded(trackId, normalizedTrackId);
    return _musicDataRepository.getTrack(normalizedTrackId);
  }

  Future<DownloadTask?> _getCurrentTask(
    String rawTrackId,
    String normalizedTrackId,
  ) async {
    final normalizedTask = await _taskDataSource.getTask(normalizedTrackId);
    if (normalizedTask != null || rawTrackId == normalizedTrackId) {
      return normalizedTask;
    }
    return _taskDataSource.getTask(rawTrackId);
  }

  Future<void> _clearTaskAliases(
    String rawTrackId,
    String normalizedTrackId,
  ) async {
    await _taskDataSource.removeTask(normalizedTrackId);
    await _removeRawTaskIfNeeded(rawTrackId, normalizedTrackId);
  }

  Future<void> _removeRawTaskIfNeeded(
    String rawTrackId,
    String normalizedTrackId,
  ) {
    if (rawTrackId == normalizedTrackId) {
      return Future<void>.value();
    }
    return _taskDataSource.removeTask(rawTrackId);
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }

  bool _isBlankTrackId(String trackId) {
    return _normalizedTrackId(trackId).isEmpty;
  }
}
