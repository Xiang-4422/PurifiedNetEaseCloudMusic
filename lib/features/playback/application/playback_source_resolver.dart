import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 播放源类型，区分本地文件、远程 URL 和网易云缓存流。
enum PlaybackResolvedSourceKind {
  /// 没有可播放音源。
  empty,

  /// 本地文件路径音源。
  filePath,

  /// 普通远程 URL 音源。
  url,

  /// 网易云加密缓存文件流。
  neteaseCacheStream,
}

/// 解析后的真实播放源。
class PlaybackResolvedSource {
  /// 创建解析后的播放源。
  const PlaybackResolvedSource({
    required this.kind,
    this.url = '',
    this.fileType = '',
    this.markAsCached = false,
  });

  /// 播放源类型。
  final PlaybackResolvedSourceKind kind;

  /// 播放源地址或本地路径。
  final String url;

  /// 缓存流解密后的文件类型。
  final String fileType;

  /// 该音源是否应被标记为已缓存。
  final bool markAsCached;

  /// 当前播放源是否为空。
  bool get isEmpty => kind == PlaybackResolvedSourceKind.empty || url.isEmpty;
}

/// 将播放队列项解析成 just_audio 可消费的真实音源。
class PlaybackSourceResolver {
  /// 创建播放源解析器。
  PlaybackSourceResolver({required PlaybackRepository repository})
      : _repository = repository;

  final PlaybackRepository _repository;

  /// 将 audio_service 媒体项解析为底层播放器可消费的音源。
  Future<PlaybackResolvedSource> resolve(
    MediaItem mediaItem, {
    required bool preferHighQuality,
  }) async {
    if (mediaItem.extras?['type'] == MediaType.local.name) {
      final url = mediaItem.extras?['url'] as String? ?? '';
      return PlaybackResolvedSource(
        kind: url.isEmpty
            ? PlaybackResolvedSourceKind.empty
            : PlaybackResolvedSourceKind.filePath,
        url: url,
        markAsCached: url.isNotEmpty,
      );
    }

    if (mediaItem.extras?['type'] == MediaType.neteaseCache.name) {
      final url = mediaItem.extras?['url'] as String? ?? '';
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

    return resolveRemote(mediaItem, preferHighQuality: preferHighQuality);
  }

  /// 忽略本地缓存标记，直接解析远程播放地址。
  Future<PlaybackResolvedSource> resolveRemote(
    MediaItem mediaItem, {
    required bool preferHighQuality,
  }) async {
    final url = (await _repository.fetchPlaybackUrl(
              mediaItem.id,
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
