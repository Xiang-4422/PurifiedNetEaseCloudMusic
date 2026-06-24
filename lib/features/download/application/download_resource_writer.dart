import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/util/track_resource_availability.dart';
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (normalizedTrackId.isEmpty) {
      return false;
    }
    if (bundle.audio?.origin == TrackResourceOrigin.localImport) {
      return _hasAvailableAudioResource(
        normalizedTrackId,
        availableAudioOrigins: const {
          TrackResourceOrigin.localImport,
        },
      );
    }
    final audioFile = TrackResourceAvailability.existingFileForPath(bundle.audio?.path);
    if (audioFile != null) {
      await _resourceIndexRepository.saveAudioResource(
        normalizedTrackId,
        path: audioFile.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    final audioAvailable = await _hasAvailableAudioResource(
      normalizedTrackId,
      availableAudioOrigins: const {
        TrackResourceOrigin.localImport,
        TrackResourceOrigin.managedDownload,
      },
    );
    if (!audioAvailable) {
      return false;
    }
    final artworkFile = TrackResourceAvailability.existingFileForPath(bundle.artwork?.path);
    if (artworkFile != null) {
      await _resourceIndexRepository.saveArtworkResource(
        normalizedTrackId,
        path: artworkFile.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    final lyricsFile = TrackResourceAvailability.existingFileForPath(bundle.lyrics?.path);
    if (lyricsFile != null) {
      await _resourceIndexRepository.saveLyricsResource(
        normalizedTrackId,
        path: lyricsFile.path,
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (normalizedTrackId.isEmpty) {
      return false;
    }
    final audioFile = TrackResourceAvailability.existingFileForPath(audioPath);
    if (audioFile == null) {
      return false;
    }
    await _resourceIndexRepository.saveAudioResource(
      normalizedTrackId,
      path: audioFile.path,
      origin: origin,
    );
    final audioAvailable = await _hasAvailableAudioResource(
      normalizedTrackId,
      availableAudioOrigins: availableAudioOrigins,
    );
    if (!audioAvailable) {
      return false;
    }
    final artworkFile = TrackResourceAvailability.existingFileForPath(artworkPath);
    if (artworkFile != null) {
      await _resourceIndexRepository.saveArtworkResource(
        normalizedTrackId,
        path: artworkFile.path,
        origin: origin,
      );
    }
    final lyricsFile = TrackResourceAvailability.existingFileForPath(lyricsPath);
    if (lyricsFile != null) {
      await _resourceIndexRepository.saveLyricsResource(
        normalizedTrackId,
        path: lyricsFile.path,
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
    return TrackResourceAvailability.isAvailableAudioResource(
      audioResource,
      allowedOrigins: availableAudioOrigins,
    );
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }
}
