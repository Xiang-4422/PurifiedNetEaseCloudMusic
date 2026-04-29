import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

enum PlaybackResolvedSourceKind {
  empty,
  filePath,
  url,
  neteaseCacheStream,
}

class PlaybackResolvedSource {
  const PlaybackResolvedSource({
    required this.kind,
    this.url = '',
    this.fileType = '',
    this.markAsCached = false,
  });

  final PlaybackResolvedSourceKind kind;
  final String url;
  final String fileType;
  final bool markAsCached;

  bool get isEmpty => kind == PlaybackResolvedSourceKind.empty || url.isEmpty;
}

/// 将播放队列项解析成 just_audio 可消费的真实音源。
class PlaybackSourceResolver {
  PlaybackSourceResolver({required PlaybackRepository repository})
      : _repository = repository;

  final PlaybackRepository _repository;

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
