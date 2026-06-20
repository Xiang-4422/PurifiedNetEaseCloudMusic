import 'dart:io';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
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
    if (item.mediaType == MediaType.local) {
      return _resolveLocalFileSource(item.playbackUrl ?? '');
    }

    if (item.mediaType == MediaType.neteaseCache) {
      return _resolveNeteaseCacheSource(item.playbackUrl ?? '');
    }

    return resolveRemote(item, preferHighQuality: preferHighQuality);
  }

  /// 忽略本地缓存标记，直接解析远程播放地址。
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    final url = await _repository.fetchPlaybackUrl(
          item.id,
          preferHighQuality: preferHighQuality,
          forceRefresh: forceRefresh,
        ) ??
        '';
    if (url.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }

    final localPath = _localPathCandidate(url);
    if (File(localPath).existsSync()) {
      return PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.filePath,
        url: localPath,
        markAsCached: true,
      );
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: url,
    );
  }

  bool _isEncryptedNeteaseCache(String url) {
    return url.endsWith('.uc!');
  }

  PlaybackResolvedSource _resolveLocalFileSource(String url) {
    final localPath = _localPathCandidate(url);
    if (localPath.isEmpty || !File(localPath).existsSync()) {
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

  PlaybackResolvedSource _resolveNeteaseCacheSource(String url) {
    final localPath = _localPathCandidate(url);
    if (localPath.isEmpty || !File(localPath).existsSync()) {
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

  String _localPathCandidate(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return url.split('?').first;
  }
}
