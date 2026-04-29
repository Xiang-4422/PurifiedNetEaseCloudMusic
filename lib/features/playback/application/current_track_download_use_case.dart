import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// CurrentTrackDownloadResult。
class CurrentTrackDownloadResult {
  /// 创建 CurrentTrackDownloadResult。
  const CurrentTrackDownloadResult({
    required this.track,
    required this.queueItem,
  });

  /// track。
  final Track track;

  /// queueItem。
  final PlaybackQueueItem? queueItem;
}

/// 当前歌曲下载相关用例，负责把下载结果转换回播放队列模型。
class CurrentTrackDownloadUseCase {
  /// 创建 CurrentTrackDownloadUseCase。
  CurrentTrackDownloadUseCase({
    required DownloadRepository downloadRepository,
    required PlaybackRepository playbackRepository,
    required PlaybackUserContentPort userContentPort,
  })  : _downloadRepository = downloadRepository,
        _playbackRepository = playbackRepository,
        _userContentPort = userContentPort;

  final DownloadRepository _downloadRepository;
  final PlaybackRepository _playbackRepository;
  final PlaybackUserContentPort _userContentPort;

  /// downloadTrackById。
  Future<CurrentTrackDownloadResult?> downloadTrackById(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final updatedTrack = await _downloadRepository.downloadTrack(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    return _buildResult(updatedTrack);
  }

  /// removeDownloadedTrackById。
  Future<CurrentTrackDownloadResult?> removeDownloadedTrackById(
    String trackId,
  ) async {
    await _downloadRepository.removeDownloadedTrack(trackId);
    return _buildResult(await _playbackRepository.getTrack(trackId));
  }

  /// cancelTrackDownloadById。
  Future<CurrentTrackDownloadResult?> cancelTrackDownloadById(
    String trackId,
  ) async {
    await _downloadRepository.cancelTask(trackId);
    return _buildResult(await _playbackRepository.getTrack(trackId));
  }

  /// retryTrackDownloadById。
  Future<CurrentTrackDownloadResult?> retryTrackDownloadById(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final updatedTrack = await _downloadRepository.retryTask(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    return _buildResult(updatedTrack);
  }

  /// queueTrackDownloads。
  Future<void> queueTrackDownloads(
    Iterable<String> trackIds, {
    bool preferHighQuality = true,
  }) {
    return _downloadRepository.queueTracks(
      trackIds,
      preferHighQuality: preferHighQuality,
    );
  }

  /// cacheTrackForPlayback。
  Future<PlaybackQueueItem?> cacheTrackForPlayback(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    final updatedTrack = await _downloadRepository.cacheTrackForPlayback(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    if (updatedTrack == null) {
      return null;
    }
    return _buildQueueItem(updatedTrack);
  }

  Future<CurrentTrackDownloadResult?> _buildResult(Track? track) async {
    if (track == null) {
      return null;
    }
    return CurrentTrackDownloadResult(
      track: track,
      queueItem: await _buildQueueItem(track),
    );
  }

  Future<PlaybackQueueItem?> _buildQueueItem(Track track) async {
    final trackWithResources =
        await _playbackRepository.getTrackWithResources(track.id);
    final queueItems = PlaybackQueueItemMapper.fromTrackWithResourcesList(
      [
        trackWithResources ??
            TrackWithResources(
              track: track,
              resources: const TrackResourceBundle(),
            ),
      ],
      likedSongIds: _userContentPort.likedSongIds(),
    );
    return queueItems.isEmpty ? null : queueItems.first;
  }
}
