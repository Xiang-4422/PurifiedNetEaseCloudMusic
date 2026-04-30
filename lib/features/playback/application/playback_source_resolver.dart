import 'dart:io';

import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 将播放队列项解析成 just_audio 可消费的真实音源。
class PlaybackSourceResolver {
  /// 创建播放源解析器。
  PlaybackSourceResolver({required PlaybackRepository repository})
      : _repository = repository;

  final PlaybackRepository _repository;

  /// 将播放队列项解析为底层播放器可消费的音源。
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    if (item.mediaType == MediaType.local) {
      final url = item.playbackUrl ?? '';
      return PlaybackResolvedSource(
        kind: url.isEmpty
            ? PlaybackResolvedSourceKind.empty
            : PlaybackResolvedSourceKind.filePath,
        url: url,
        markAsCached: url.isNotEmpty,
      );
    }

    if (item.mediaType == MediaType.neteaseCache) {
      final url = item.playbackUrl ?? '';
      return PlaybackResolvedSource(
        kind: url.isEmpty
            ? PlaybackResolvedSourceKind.empty
            : _isEncryptedNeteaseCache(url)
                ? PlaybackResolvedSourceKind.neteaseCacheStream
                : PlaybackResolvedSourceKind.filePath,
        url: url,
        fileType: url.replaceAll('.uc!', '').split('.').last,
        markAsCached: url.isNotEmpty,
      );
    }

    return resolveRemote(item, preferHighQuality: preferHighQuality);
  }

  /// 忽略本地缓存标记，直接解析远程播放地址。
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    final url = (await _repository.fetchPlaybackUrl(
              item.id,
              preferHighQuality: preferHighQuality,
            ) ??
            '')
        .split('?')
        .first;
    if (url.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }

    if (File(url).existsSync()) {
      return PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.filePath,
        url: url,
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
}
