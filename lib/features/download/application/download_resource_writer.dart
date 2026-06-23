import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';

/// 下载资源索引写入器，集中处理缓存资源和正式下载资源的归属。
class DownloadResourceWriter {
  /// 创建下载资源索引写入器。
  DownloadResourceWriter({
    required LocalResourceIndexRepository resourceIndexRepository,
  }) : _resourceIndexRepository = resourceIndexRepository;

  final LocalResourceIndexRepository _resourceIndexRepository;

  /// 保存正式下载资源索引。
  Future<bool> saveManagedDownloadResources(
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
      availableAudioOrigins: const {
        TrackResourceOrigin.localImport,
        TrackResourceOrigin.managedDownload,
      },
    );
  }

  /// 保存播放缓存资源索引。
  Future<bool> savePlaybackCacheResources(
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
      availableAudioOrigins: const {
        TrackResourceOrigin.localImport,
        TrackResourceOrigin.managedDownload,
        TrackResourceOrigin.playbackCache,
      },
    );
  }

  /// 将已有资源提升为正式下载资源。
  Future<bool> promoteResourcesToManagedDownload(
    String trackId,
    TrackResourceBundle bundle,
  ) async {
    if (bundle.audio?.origin == TrackResourceOrigin.localImport) {
      return _hasAvailableAudioResource(
        trackId,
        availableAudioOrigins: const {
          TrackResourceOrigin.localImport,
        },
      );
    }
    if (bundle.audio?.path.isNotEmpty == true) {
      await _resourceIndexRepository.saveAudioResource(
        trackId,
        path: bundle.audio!.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    final audioAvailable = await _hasAvailableAudioResource(
      trackId,
      availableAudioOrigins: const {
        TrackResourceOrigin.localImport,
        TrackResourceOrigin.managedDownload,
      },
    );
    if (!audioAvailable) {
      return false;
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
    return true;
  }

  Future<bool> _saveResources(
    String trackId, {
    required String audioPath,
    String? artworkPath,
    String? lyricsPath,
    required TrackResourceOrigin origin,
    required Set<TrackResourceOrigin> availableAudioOrigins,
  }) async {
    await _resourceIndexRepository.saveAudioResource(
      trackId,
      path: audioPath,
      origin: origin,
    );
    final audioAvailable = await _hasAvailableAudioResource(
      trackId,
      availableAudioOrigins: availableAudioOrigins,
    );
    if (!audioAvailable) {
      return false;
    }
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
    return true;
  }

  Future<bool> _hasAvailableAudioResource(
    String trackId, {
    required Set<TrackResourceOrigin> availableAudioOrigins,
  }) async {
    final audioResource = await _resourceIndexRepository.getPrimaryAudioResource(trackId);
    return audioResource != null && availableAudioOrigins.contains(audioResource.origin);
  }
}
