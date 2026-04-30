part of 'player_controller.dart';

/// 当前歌曲下载相关命令。
extension PlayerDownloadCommands on PlayerController {
  /// 当前播放歌曲的下载入口必须同步回写队列项，避免 UI 继续展示旧资源态。
  Future<Track?> downloadCurrentTrack({
    bool preferHighQuality = true,
  }) async {
    final currentSong = currentSongState.value;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return downloadTrackById(
      currentSong.id,
      preferHighQuality: preferHighQuality,
    );
  }

  /// 删除当前歌曲的下载资源。
  Future<Track?> removeCurrentTrackDownload() async {
    final currentSong = currentSongState.value;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return removeDownloadedTrackById(currentSong.id);
  }

  /// 取消当前歌曲的下载任务。
  Future<Track?> cancelCurrentTrackDownload() async {
    final currentSong = currentSongState.value;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return cancelTrackDownloadById(currentSong.id);
  }

  /// 重试当前歌曲的下载任务。
  Future<Track?> retryCurrentTrackDownload({
    bool preferHighQuality = true,
  }) async {
    final currentSong = currentSongState.value;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return retryTrackDownloadById(
      currentSong.id,
      preferHighQuality: preferHighQuality,
    );
  }

  /// 下载指定曲目并同步当前队列项资源状态。
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

  /// 删除指定曲目的下载资源并同步当前队列项。
  Future<Track?> removeDownloadedTrackById(String trackId) async {
    final result = await _downloadUseCase.removeDownloadedTrackById(trackId);
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  /// 取消指定曲目的下载任务并同步当前队列项。
  Future<Track?> cancelTrackDownloadById(String trackId) async {
    final result = await _downloadUseCase.cancelTrackDownloadById(trackId);
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  /// 重试指定曲目的下载任务并同步当前队列项。
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

  /// 批量加入下载队列。
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
        currentSongState.value.id != result.track.id ||
        result.queueItem == null) {
      return;
    }
    await _syncCurrentQueueItem(result.queueItem!);
  }
}
