part of 'download_repository.dart';

/// 下载仓库的实际文件下载与播放缓存工作流。
extension DownloadRepositoryWorkflow on DownloadRepository {
  /// 执行正式下载流程。
  Future<Track?> performDownloadTrack(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    if (_taskQueue.isCancelled(trackId)) {
      await clearCancelledTask(trackId);
      return null;
    }
    final trackWithResources = await _musicDataRepository.getTrackWithResources(
      trackId,
    );
    if (trackWithResources == null) {
      await _taskStateStore.markFailed(trackId, reason: 'track_not_found');
      return null;
    }

    final track = trackWithResources.track;
    if (track.sourceType == SourceType.local) {
      await _taskStateStore.clearTask(trackId);
      return track;
    }
    final audioResource = trackWithResources.resources.audio;
    if (audioResource != null && File(audioResource.path).existsSync()) {
      if (audioResource.origin != TrackResourceOrigin.managedDownload && track.sourceType != SourceType.local) {
        final promoted = await _resourceWriter.promoteResourcesToManagedDownload(
          track.id,
          trackWithResources.resources,
        );
        if (!promoted) {
          return _taskStateStore.markFailed(
            trackId,
            reason: 'local_resource_index_unavailable',
          );
        }
      }
      await _taskStateStore.clearTask(trackId);
      return track;
    }

    if (_taskQueue.isCancelled(trackId)) {
      await clearCancelledTask(trackId);
      return null;
    }

    try {
      final playbackUrl = await _musicDataRepository.getPlaybackUrlWithQuality(
        trackId,
        qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
      );
      if (playbackUrl == null || playbackUrl.isEmpty) {
        return _taskStateStore.markFailed(
          trackId,
          reason: 'playback_url_unavailable',
        );
      }

      final directories = await _fileStore.ensureDownloadDirectories();
      final cancelToken = _taskQueue.createCancelToken(trackId);

      final audioPath = _fileStore.buildAudioPath(track, playbackUrl, directories.audio);
      final temporaryPath = '$audioPath.download';
      await _taskStateStore.markQueued(trackId, temporaryPath: temporaryPath);
      await _fileStore.downloadBinaryFile(
        playbackUrl,
        audioPath,
        onProgress: (progress) => _taskStateStore.markDownloading(
          trackId,
          progress: progress,
          temporaryPath: temporaryPath,
        ),
        cancelToken: cancelToken,
      );
      if (_taskQueue.isCancelled(trackId)) {
        await _fileStore.deleteTemporaryDownloadIfExists(temporaryPath);
        await clearCancelledTask(trackId);
        return null;
      }

      final artworkPath = await _fileStore.downloadArtworkFile(
        track,
        directories.artwork,
      );
      final lyricsPath = await _fileStore.writeLyricsFile(
        trackId,
        directories.lyrics,
        await _musicDataRepository.getLyrics(trackId),
      );

      final savedResources = await _resourceWriter.saveManagedDownloadResources(
        trackId,
        localPath: audioPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      );
      if (!savedResources) {
        await _fileStore.deleteFileIfExists(audioPath);
        await _fileStore.deleteFileIfExists(artworkPath);
        await _fileStore.deleteFileIfExists(lyricsPath);
        return _taskStateStore.markFailed(
          trackId,
          reason: 'local_resource_index_unavailable',
        );
      }
      await _taskStateStore.clearTask(trackId);
      return track;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        await clearCancelledTask(trackId);
        return null;
      }
      return _taskStateStore.markFailed(trackId, reason: error.toString());
    } catch (error) {
      return _taskStateStore.markFailed(trackId, reason: error.toString());
    } finally {
      _taskQueue.finishActiveTask(trackId);
    }
  }

  /// 执行播放临时缓存流程。
  Future<Track?> performCacheTrackForPlayback(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    final trackWithResources = await _musicDataRepository.getTrackWithResources(
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
      final playbackUrl = await _musicDataRepository.getPlaybackUrlWithQuality(
        trackId,
        qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
      );
      if (playbackUrl == null || playbackUrl.isEmpty) {
        return track;
      }
      final directories = await _fileStore.ensureCacheDirectories();
      final audioPath = _fileStore.buildAudioPath(track, playbackUrl, directories.audio);
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
        await _musicDataRepository.getLyrics(trackId),
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

  /// 清理取消任务状态。
  Future<void> clearCancelledTask(String trackId) async {
    await _taskStateStore.clearTask(trackId);
    _taskQueue.clearCancelled(trackId);
  }
}
