import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';

/// 下载资源索引写入器，集中处理缓存资源和正式下载资源的归属。
class DownloadResourceWriter {
  /// 创建下载资源索引写入器。
  DownloadResourceWriter({
    required LocalResourceIndexRepository resourceIndexRepository,
  }) : _resourceIndexRepository = resourceIndexRepository;

  final LocalResourceIndexRepository _resourceIndexRepository;

  /// 保存正式下载资源索引。
  Future<void> saveManagedDownloadResources(
    String trackId, {
    required String localPath,
    String? artworkPath,
    String? lyricsPath,
  }) {
    return _saveResources(
      trackId,
      audioPath: localPath,
      artworkPath: artworkPath,
      lyricsPath: lyricsPath,
      origin: TrackResourceOrigin.managedDownload,
    );
  }

  /// 保存播放缓存资源索引。
  Future<void> savePlaybackCacheResources(
    String trackId, {
    required String audioPath,
    String? artworkPath,
    String? lyricsPath,
  }) {
    return _saveResources(
      trackId,
      audioPath: audioPath,
      artworkPath: artworkPath,
      lyricsPath: lyricsPath,
      origin: TrackResourceOrigin.playbackCache,
    );
  }

  /// 将已有资源提升为正式下载资源。
  Future<void> promoteResourcesToManagedDownload(
    String trackId,
    TrackResourceBundle bundle,
  ) async {
    if (bundle.audio?.path.isNotEmpty == true) {
      await _resourceIndexRepository.saveAudioResource(
        trackId,
        path: bundle.audio!.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    if (bundle.artwork?.path.isNotEmpty == true) {
      await _resourceIndexRepository.saveArtworkResource(
        trackId,
        path: bundle.artwork!.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    if (bundle.lyrics?.path.isNotEmpty == true) {
      await _resourceIndexRepository.saveLyricsResource(
        trackId,
        path: bundle.lyrics!.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
  }

  Future<void> _saveResources(
    String trackId, {
    required String audioPath,
    String? artworkPath,
    String? lyricsPath,
    required TrackResourceOrigin origin,
  }) async {
    await _resourceIndexRepository.saveAudioResource(
      trackId,
      path: audioPath,
      origin: origin,
    );
    if (artworkPath?.isNotEmpty == true) {
      await _resourceIndexRepository.saveArtworkResource(
        trackId,
        path: artworkPath!,
        origin: origin,
      );
    }
    if (lyricsPath?.isNotEmpty == true) {
      await _resourceIndexRepository.saveLyricsResource(
        trackId,
        path: lyricsPath!,
        origin: origin,
      );
    }
  }
}
