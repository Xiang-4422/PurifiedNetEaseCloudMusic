import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// PlaybackResolvedSourceKind。
enum PlaybackResolvedSourceKind {
  /// empty。
  empty,

  /// filePath。
  filePath,

  /// url。
  url,

  /// neteaseCacheStream。
  neteaseCacheStream,
}

/// PlaybackResolvedSource。
class PlaybackResolvedSource {
  /// 创建 PlaybackResolvedSource。
  const PlaybackResolvedSource({
    required this.kind,
    this.url = '',
    this.fileType = '',
    this.markAsCached = false,
  });

  /// kind。
  final PlaybackResolvedSourceKind kind;

  /// url。
  final String url;

  /// fileType。
  final String fileType;

  /// markAsCached。
  final bool markAsCached;

  /// isEmpty。
  bool get isEmpty => kind == PlaybackResolvedSourceKind.empty || url.isEmpty;
}

/// 将播放队列项解析成 just_audio 可消费的真实音源。
class PlaybackSourceResolver {
  /// 创建 PlaybackSourceResolver。
  PlaybackSourceResolver({required PlaybackRepository repository})
      : _repository = repository;

  final PlaybackRepository _repository;

  /// resolve。
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
            : PlaybackResolvedSourceKind.neteaseCacheStream,
        url: url,
        fileType: url.replaceAll('.uc!', '').split('.').last,
        markAsCached: url.isNotEmpty,
      );
    }

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
}
