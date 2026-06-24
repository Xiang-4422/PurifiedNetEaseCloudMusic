import 'dart:io';

import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/features/download/application/download_background_error_handler.dart';
import 'package:bujuan/features/download/application/download_file_store.dart';
import 'package:bujuan/features/download/application/download_queue_planner.dart';
import 'package:bujuan/features/download/application/download_recovery_service.dart';
import 'package:bujuan/features/download/application/download_resource_writer.dart';
import 'package:bujuan/features/download/application/download_task_state_store.dart';
import 'package:bujuan/features/download/application/download_task_queue.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:dio/dio.dart';

part 'download_repository_workflow.dart';

/// 下载业务门面，组合任务队列、文件写入、资源索引和恢复流程。
class DownloadRepository {
  /// 创建下载仓库。
  DownloadRepository({
    required MusicDataRepository musicDataRepository,
    required DownloadTaskDataSource taskDataSource,
    required LocalResourceIndexRepository resourceIndexRepository,
    Dio? dio,
    DownloadTaskQueue? taskQueue,
    DownloadFileStore? fileStore,
    DownloadResourceWriter? resourceWriter,
    DownloadRecoveryService? recoveryService,
    DownloadQueuePlanner? queuePlanner,
    DownloadTaskStateStore? taskStateStore,
    DownloadBackgroundErrorHandler? onBackgroundError,
  })  : _musicDataRepository = musicDataRepository,
        _resourceIndexRepository = resourceIndexRepository,
        _taskQueue = taskQueue ?? DownloadTaskQueue(),
        _fileStore = fileStore ?? DownloadFileStore(dio: dio),
        _resourceWriter = resourceWriter ??
            DownloadResourceWriter(
              resourceIndexRepository: resourceIndexRepository,
            ),
        _recoveryService = recoveryService ??
            DownloadRecoveryService(
              taskDataSource: taskDataSource,
              fileStore: fileStore ?? DownloadFileStore(dio: dio),
              onQueuedRestartError: onBackgroundError,
            ),
        _queuePlanner = queuePlanner ??
            DownloadQueuePlanner(
              musicDataRepository: musicDataRepository,
              taskDataSource: taskDataSource,
              onQueuedDownloadError: onBackgroundError,
            ),
        _taskStateStore = taskStateStore ??
            DownloadTaskStateStore(
              taskDataSource: taskDataSource,
              musicDataRepository: musicDataRepository,
            );

  final MusicDataRepository _musicDataRepository;
  final LocalResourceIndexRepository _resourceIndexRepository;
  final DownloadTaskQueue _taskQueue;
  final DownloadFileStore _fileStore;
  final DownloadResourceWriter _resourceWriter;
  final DownloadRecoveryService _recoveryService;
  final DownloadQueuePlanner _queuePlanner;
  final DownloadTaskStateStore _taskStateStore;

  /// 恢复上次启动中断的下载任务。
  Future<List<DownloadTask>> recoverInterruptedTasks() async {
    return _recoveryService.recoverInterruptedTasks(
      markInterruptedFailed: (trackId) => _taskStateStore.markFailed(
        trackId,
        reason: 'download_interrupted',
      ),
      restartQueuedTask: downloadTrack,
    );
  }

  /// 下载指定曲目，返回下载完成或已存在资源对应的曲目。
  Future<Track?> downloadTrack(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    _taskQueue.clearCancelled(normalizedTrackId);
    final existingTask = _taskQueue.existingDownload(normalizedTrackId);
    if (existingTask != null) {
      return existingTask;
    }
    await _taskStateStore.markQueued(trackId);

    return _taskQueue.scheduleDownload(
      normalizedTrackId,
      () => performDownloadTrack(
        normalizedTrackId,
        preferHighQuality: preferHighQuality,
      ),
    );
  }

  /// 批量加入下载队列，内部会跳过已下载或已排队曲目。
  Future<void> queueTracks(
    Iterable<String> trackIds, {
    bool preferHighQuality = true,
  }) async {
    return _queuePlanner.queueTracks(
      trackIds,
      downloadTrack: downloadTrack,
      preferHighQuality: preferHighQuality,
    );
  }

  /// 为播放临时缓存曲目资源，不写入正式下载任务列表。
  Future<Track?> cacheTrackForPlayback(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final existingTask = _taskQueue.existingPlaybackCache(normalizedTrackId);
    if (existingTask != null) {
      return existingTask;
    }
    return _taskQueue.schedulePlaybackCache(
      normalizedTrackId,
      () => performCacheTrackForPlayback(
        normalizedTrackId,
        preferHighQuality: preferHighQuality,
      ),
    );
  }

  /// 删除已下载曲目的本地资源。
  Future<void> removeDownloadedTrack(String trackId) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return;
    }
    await _taskStateStore.clearTask(trackId);
    final trackWithResources = await _musicDataRepository.getTrackWithResources(
      normalizedTrackId,
    );
    final audioOrigin = trackWithResources?.resources.audio?.origin;
    await _musicDataRepository.removeLocalTrackResources(
      normalizedTrackId,
      deleteSourceFiles: audioOrigin != TrackResourceOrigin.localImport,
    );
  }

  /// 删除本地曲目资源入口，当前复用下载删除流程。
  Future<void> removeLocalTrack(String trackId) {
    return removeDownloadedTrack(trackId);
  }

  /// 取消指定下载任务并清理临时文件。
  Future<void> cancelTask(String trackId) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return;
    }
    final scheduledTask = _taskQueue.existingDownload(normalizedTrackId);
    _taskQueue.markCancelled(normalizedTrackId);
    final currentTask = await _taskStateStore.getTask(trackId);
    await _fileStore.deleteTemporaryDownloadIfExists(currentTask?.temporaryPath);
    await _taskStateStore.clearTask(trackId);
    if (scheduledTask == null) {
      _taskQueue.clearCancelled(normalizedTrackId);
    }
  }

  /// 读取指定曲目的下载任务。
  Future<DownloadTask?> getTask(String trackId) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<DownloadTask?>.value();
    }
    return _taskStateStore.getTask(trackId);
  }

  /// 重试指定下载任务。
  Future<Track?> retryTask(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final currentTask = await _taskStateStore.getTask(trackId);
    await _fileStore.deleteTemporaryDownloadIfExists(currentTask?.temporaryPath);
    return downloadTrack(
      trackId,
      preferHighQuality: preferHighQuality,
    );
  }

  /// 读取下载任务列表，可按状态过滤。
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskStateStore.getTasks(statuses: statuses);
  }

  /// 监听下载任务列表变化，可按状态过滤。
  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskStateStore.watchTasks(statuses: statuses);
  }

  /// 读取排队中和下载中的任务。
  Future<List<DownloadTask>> getActiveTasks() {
    return getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
  }

  /// 清除指定曲目的下载任务状态。
  Future<void> clearTask(String trackId) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return _taskStateStore.clearTask(trackId);
  }

  /// 清理播放缓存资源。
  Future<void> clearPlaybackCache() async {
    await _musicDataRepository.removePlaybackCache();
    await _fileStore.clearPlaybackCacheFiles(
      retainedPaths: _resourcePaths(
        await _resourceIndexRepository.listResources(),
      ),
    );
  }

  bool _isBlankTrackId(String trackId) {
    return _normalizedTrackId(trackId).isEmpty;
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }

  Set<String> _resourcePaths(List<LocalResourceEntry> resources) {
    final paths = <String>{};
    for (final resource in resources) {
      final path = LocalFilePathNormalizer.normalize(resource.path);
      if (path.isNotEmpty) {
        paths.add(path);
      }
    }
    return paths;
  }
}
