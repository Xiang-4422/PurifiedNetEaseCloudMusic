import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/util/playback_source_reference.dart';
import 'package:bujuan/core/util/track_resource_availability.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 将播放队列项解析成 just_audio 可消费的真实音源。
class PlaybackSourceResolver {
  /// 创建播放源解析器。
  PlaybackSourceResolver({required PlaybackRepository repository}) : _repository = repository;

  final PlaybackRepository _repository;

  /// 将播放队列项解析为底层播放器可消费的音源。
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    final itemId = _normalizedQueueItemId(item.id);
    if (itemId.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
    final indexedSource = await _resolveIndexedAudioSource(
      itemId,
    );
    if (!indexedSource.isEmpty) {
      return indexedSource;
    }

    if (item.mediaType == MediaType.local) {
      if (item.sourceType == SourceType.local) {
        return const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.empty,
        );
      }
      return resolveRemote(item, preferHighQuality: preferHighQuality);
    }

    if (item.mediaType == MediaType.neteaseCache) {
      if (item.sourceType == SourceType.local) {
        return const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.empty,
        );
      }
      return resolveRemote(item, preferHighQuality: preferHighQuality);
    }

    return resolveRemote(item, preferHighQuality: preferHighQuality);
  }

  /// 忽略本地缓存标记，直接解析远程播放地址。
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    final itemId = _normalizedQueueItemId(item.id);
    if (itemId.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
    final url = (await _repository.fetchPlaybackUrl(
          itemId,
          preferHighQuality: preferHighQuality,
          forceRefresh: forceRefresh,
        ))
            ?.trim() ??
        '';
    if (url.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }

    final localPath = PlaybackSourceReference.localPath(url);
    if (localPath.isNotEmpty) {
      if (!PlaybackSourceReference.isExistingLocalPath(localPath)) {
        await _pruneMissingIndexedAudioResource(item);
        return const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.empty,
        );
      }
      return PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.filePath,
        url: localPath,
        markAsCached: true,
      );
    }
    final remoteUrl = PlaybackSourceReference.remoteHttpUrl(url);
    if (remoteUrl.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: remoteUrl,
    );
  }

  bool _isEncryptedNeteaseCache(String url) {
    return url.endsWith('.uc!');
  }

  PlaybackResolvedSource _resolveNeteaseCacheSource(String url) {
    final localPath = PlaybackSourceReference.existingLocalPath(url);
    if (localPath.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
    final isEncryptedCache = _isEncryptedNeteaseCache(localPath);
    return PlaybackResolvedSource(
      kind: isEncryptedCache ? PlaybackResolvedSourceKind.neteaseCacheStream : PlaybackResolvedSourceKind.filePath,
      url: localPath,
      fileType: isEncryptedCache ? localPath.replaceAll('.uc!', '').split('.').last : '',
      markAsCached: true,
    );
  }

  Future<PlaybackResolvedSource> _resolveIndexedAudioSource(String itemId) async {
    try {
      final trackWithResources = await _repository.getTrackWithResources(itemId);
      final audio = trackWithResources?.resources.audio;
      final localPath = TrackResourceAvailability.existingLocalPath(
        audio,
        kind: LocalResourceKind.audio,
        allowedOrigins: TrackResourceAvailability.playableAudioOrigins,
      );
      if (audio == null || localPath == null) {
        return const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.empty,
        );
      }
      final markAsCached = TrackResourceAvailability.isCachedAudioResource(audio);
      final cacheSource = _resolveNeteaseCacheSource(localPath);
      if (!cacheSource.isEmpty) {
        return PlaybackResolvedSource(
          kind: cacheSource.kind,
          url: cacheSource.url,
          fileType: cacheSource.fileType,
          markAsCached: markAsCached,
        );
      }
      return PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.filePath,
        url: localPath,
        markAsCached: markAsCached,
      );
    } catch (_) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
  }

  Future<void> _pruneMissingIndexedAudioResource(PlaybackQueueItem item) async {
    final itemId = _normalizedQueueItemId(item.id);
    if (itemId.isEmpty) {
      return;
    }
    try {
      await _repository.getTrackWithResources(itemId);
    } catch (_) {}
  }

  String _normalizedQueueItemId(String id) {
    return id.trim();
  }
}
