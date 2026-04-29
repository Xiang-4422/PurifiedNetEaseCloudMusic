part of 'player_controller.dart';

extension PlayerDownloadCommands on PlayerController {
  /// 当前播放歌曲的下载入口必须同步回写队列项，避免 UI 继续展示旧资源态。
  Future<Track?> downloadCurrentTrack({
    bool preferHighQuality = true,
  }) async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return downloadTrackById(
      currentSong.id,
      preferHighQuality: preferHighQuality,
    );
  }

  Future<Track?> removeCurrentTrackDownload() async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return removeDownloadedTrackById(currentSong.id);
  }

  Future<Track?> cancelCurrentTrackDownload() async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return cancelTrackDownloadById(currentSong.id);
  }

  Future<Track?> retryCurrentTrackDownload({
    bool preferHighQuality = true,
  }) async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return retryTrackDownloadById(
      currentSong.id,
      preferHighQuality: preferHighQuality,
    );
  }

  Future<Track?> downloadTrackById(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final result = await _downloadUseCase.downloadTrackById(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<Track?> removeDownloadedTrackById(String trackId) async {
    final result = await _downloadUseCase.removeDownloadedTrackById(trackId);
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<Track?> cancelTrackDownloadById(String trackId) async {
    final result = await _downloadUseCase.cancelTrackDownloadById(trackId);
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<Track?> retryTrackDownloadById(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final result = await _downloadUseCase.retryTrackDownloadById(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<void> queueTrackDownloads(
    Iterable<String> trackIds, {
    bool preferHighQuality = true,
  }) {
    return _downloadUseCase.queueTrackDownloads(
      trackIds,
      preferHighQuality: preferHighQuality,
    );
  }

  Future<void> _syncDownloadResultIfCurrent(
    CurrentTrackDownloadResult? result,
  ) async {
    if (result == null ||
        runtimeState.value.currentSong.id != result.track.id ||
        result.queueItem == null) {
      return;
    }
    await _syncCurrentQueueItem(result.queueItem!);
  }
}
