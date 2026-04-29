import 'dart:async';
import 'dart:io';

import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/application/download_file_store.dart';
import 'package:bujuan/features/download/application/download_recovery_service.dart';
import 'package:bujuan/features/download/application/download_resource_writer.dart';
import 'package:bujuan/features/download/application/download_task_queue.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:dio/dio.dart';

class DownloadRepository {
  DownloadRepository({
    required LibraryRepository libraryRepository,
    required DownloadTaskDataSource taskDataSource,
    required LocalResourceIndexRepository resourceIndexRepository,
    Dio? dio,
    DownloadTaskQueue? taskQueue,
    DownloadFileStore? fileStore,
    DownloadResourceWriter? resourceWriter,
    DownloadRecoveryService? recoveryService,
  })  : _libraryRepository = libraryRepository,
        _taskDataSource = taskDataSource,
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
            );

  final LibraryRepository _libraryRepository;
  final DownloadTaskDataSource _taskDataSource;
  final DownloadTaskQueue _taskQueue;
  final DownloadFileStore _fileStore;
  final DownloadResourceWriter _resourceWriter;
  final DownloadRecoveryService _recoveryService;

  Future<List<DownloadTask>> recoverInterruptedTasks() async {
    return _recoveryService.recoverInterruptedTasks(
      markInterruptedFailed: (trackId) =>
          markFailed(trackId, reason: 'download_interrupted'),
      restartQueuedTask: downloadTrack,
    );
  }

  Future<Track?> downloadTrack(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    _taskQueue.clearCancelled(trackId);
    final existingTask = _taskQueue.existingDownload(trackId);
    if (existingTask != null) {
      return existingTask;
    }
    await markQueued(trackId);

    return _taskQueue.scheduleDownload(
      trackId,
      () => _performDownloadTrack(
        trackId,
        preferHighQuality: preferHighQuality,
      ),
    );
  }

  Future<void> queueTracks(
    Iterable<String> trackIds, {
    bool preferHighQuality = true,
  }) async {
    final candidateIds = trackIds.toSet().toList();
    if (candidateIds.isEmpty) {
      return;
    }
    final tracksWithResources =
        await _libraryRepository.getTracksWithResources(candidateIds);
    final tracksById = {
      for (final item in tracksWithResources) item.track.id: item,
    };
    for (final trackId in candidateIds) {
      final trackWithResources = tracksById[trackId];
      final currentTask = await _taskDataSource.getTask(trackId);
      if (currentTask != null &&
          {
            DownloadTaskStatus.queued,
            DownloadTaskStatus.downloading,
          }.contains(currentTask.status)) {
        continue;
      }
      if (trackWithResources == null) {
        continue;
      }
      final track = trackWithResources.track;
      final audioResource = trackWithResources.resources.audio;
      if (track.sourceType == SourceType.local ||
          audioResource?.origin == TrackResourceOrigin.managedDownload) {
        continue;
      }
      unawaited(
        downloadTrack(
          trackId,
          preferHighQuality: preferHighQuality,
        ),
      );
    }
  }

  Future<Track?> cacheTrackForPlayback(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final existingTask = _taskQueue.existingPlaybackCache(trackId);
    if (existingTask != null) {
      return existingTask;
    }
    return _taskQueue.schedulePlaybackCache(
      trackId,
      () => _performCacheTrackForPlayback(
        trackId,
        preferHighQuality: preferHighQuality,
      ),
    );
  }

  Future<Track?> _performDownloadTrack(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    if (_taskQueue.isCancelled(trackId)) {
      await _clearCancelledTask(trackId);
      return null;
    }
    final trackWithResources = await _libraryRepository.getTrackWithResources(
      trackId,
    );
    if (trackWithResources == null) {
      await markFailed(trackId, reason: 'track_not_found');
      return null;
    }

    final track = trackWithResources.track;
    if (track.sourceType == SourceType.local) {
      await clearTask(trackId);
      return track;
    }
    final audioResource = trackWithResources.resources.audio;
    if (audioResource != null && File(audioResource.path).existsSync()) {
      if (audioResource.origin != TrackResourceOrigin.managedDownload &&
          track.sourceType != SourceType.local) {
        await _resourceWriter.promoteResourcesToManagedDownload(
          track.id,
          trackWithResources.resources,
        );
      }
      await clearTask(trackId);
      return track;
    }

    if (_taskQueue.isCancelled(trackId)) {
      await _clearCancelledTask(trackId);
      return null;
    }

    try {
      final playbackUrl = await _libraryRepository.getPlaybackUrlWithQuality(
        trackId,
        qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
      );
      if (playbackUrl == null || playbackUrl.isEmpty) {
        return markFailed(trackId, reason: 'playback_url_unavailable');
      }

      final directories = await _fileStore.ensureDownloadDirectories();
      final cancelToken = _taskQueue.createCancelToken(trackId);

      final audioPath =
          _fileStore.buildAudioPath(track, playbackUrl, directories.audio);
      final temporaryPath = '$audioPath.download';
      await markQueued(trackId, temporaryPath: temporaryPath);
      await _fileStore.downloadBinaryFile(
        playbackUrl,
        audioPath,
        onProgress: (progress) => markDownloading(
          trackId,
          progress: progress,
          temporaryPath: temporaryPath,
        ),
        cancelToken: cancelToken,
      );
      if (_taskQueue.isCancelled(trackId)) {
        await _fileStore.deleteTemporaryDownloadIfExists(temporaryPath);
        await _clearCancelledTask(trackId);
        return null;
      }

      final artworkPath = await _fileStore.downloadArtworkFile(
        track,
        directories.artwork,
      );
      final lyricsPath = await _fileStore.writeLyricsFile(
        trackId,
        directories.lyrics,
        await _libraryRepository.getLyrics(trackId),
      );

      await _resourceWriter.saveManagedDownloadResources(
        trackId,
        localPath: audioPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      );
      await clearTask(trackId);
      return track;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        await _clearCancelledTask(trackId);
        return null;
      }
      return markFailed(trackId, reason: error.toString());
    } catch (error) {
      return markFailed(trackId, reason: error.toString());
    } finally {
      _taskQueue.finishActiveTask(trackId);
    }
  }

  Future<void> removeDownloadedTrack(String trackId) async {
    await clearTask(trackId);
    final trackWithResources = await _libraryRepository.getTrackWithResources(
      trackId,
    );
    final audioOrigin = trackWithResources?.resources.audio?.origin;
    await _libraryRepository.removeLocalTrackResources(
      trackId,
      deleteSourceFiles: audioOrigin != TrackResourceOrigin.localImport,
    );
  }

  Future<void> removeLocalTrack(String trackId) {
    return removeDownloadedTrack(trackId);
  }

  Future<void> cancelTask(String trackId) async {
    _taskQueue.markCancelled(trackId);
    final currentTask = await _taskDataSource.getTask(trackId);
    await _fileStore
        .deleteTemporaryDownloadIfExists(currentTask?.temporaryPath);
    await _clearCancelledTask(trackId);
  }

  Future<DownloadTask?> getTask(String trackId) {
    return _taskDataSource.getTask(trackId);
  }

  Future<Track?> retryTask(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _fileStore
        .deleteTemporaryDownloadIfExists(currentTask?.temporaryPath);
    return downloadTrack(
      trackId,
      preferHighQuality: preferHighQuality,
    );
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

  Future<List<DownloadTask>> getActiveTasks() {
    return getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
  }

  Future<void> clearTask(String trackId) {
    return _taskDataSource.removeTask(trackId);
  }

  Future<void> clearPlaybackCache() {
    return _libraryRepository.removePlaybackCache();
  }

  Future<Track?> markQueued(
    String trackId, {
    String? temporaryPath,
  }) async {
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

  Future<Track?> _performCacheTrackForPlayback(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    final trackWithResources = await _libraryRepository.getTrackWithResources(
      trackId,
    );
    final track = trackWithResources?.track;
    if (track == null || track.sourceType == SourceType.local) {
      return track;
    }
    final audioResource = trackWithResources?.resources.audio;
    if (audioResource != null && File(audioResource.path).existsSync()) {
      return track;
    }
    try {
      final playbackUrl = await _libraryRepository.getPlaybackUrlWithQuality(
        trackId,
        qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
      );
      if (playbackUrl == null || playbackUrl.isEmpty) {
        return track;
      }
      final directories = await _fileStore.ensureCacheDirectories();
      final audioPath =
          _fileStore.buildAudioPath(track, playbackUrl, directories.audio);
      await _fileStore.downloadBinaryFile(
        playbackUrl,
        audioPath,
        onProgress: (_) async {},
      );
      final artworkPath = await _fileStore.downloadArtworkFile(
        track,
        directories.artwork,
      );
      final lyricsPath = await _fileStore.writeLyricsFile(
        trackId,
        directories.lyrics,
        await _libraryRepository.getLyrics(trackId),
      );
      await _resourceWriter.savePlaybackCacheResources(
        trackId,
        audioPath: audioPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      );
      return track;
    } catch (_) {
      return track;
    }
  }

  Future<Track?> markFailed(
    String trackId, {
    String? reason,
  }) async {
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

  Future<void> _clearCancelledTask(String trackId) async {
    await clearTask(trackId);
    _taskQueue.clearCancelled(trackId);
  }
}
