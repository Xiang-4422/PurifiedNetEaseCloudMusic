import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart' show TrackAvailability;
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/features/playback/application/playback_queue_cached_audio_guard.dart';
import 'package:bujuan/features/playback/application/playback_queue_metadata_filter.dart';

/// 播放队列项与 audio_service [MediaItem] 的边界适配器。
class PlaybackQueueItemAdapter {
  /// 禁止实例化，仅提供静态转换方法。
  const PlaybackQueueItemAdapter._();

  /// 将领域播放队列项转换为通知栏和底层播放器使用的 [MediaItem]。
  static MediaItem toMediaItem(PlaybackQueueItem item) {
    return MediaItem(
      id: item.id,
      title: item.title,
      album: item.albumTitle,
      artist: item.artist,
      duration: item.duration,
      artUri: _toArtUri(item.localArtworkPath),
      extras: _toMediaItemExtras(item),
    );
  }

  /// 批量将领域播放队列项转换为 [MediaItem]。
  static List<MediaItem> toMediaItems(List<PlaybackQueueItem> items) {
    return items.map(toMediaItem).toList();
  }

  /// 将 [MediaItem] 转回应用层播放队列项。
  static PlaybackQueueItem fromMediaItem(MediaItem item) {
    final extras = item.extras ?? const <String, dynamic>{};
    final localArtworkPath = _stringOrNull(extras['localArtworkPath']);
    final image = _stringOrNull(extras['image']);
    final sourceType = _sourceTypeFrom(extras['sourceType']);
    final mediaType = MediaType.values.firstWhere(
      (type) => type.name == extras['type'],
      orElse: () => MediaType.playlist,
    );
    final playbackUrl = _stringOrNull(extras['url']);
    return PlaybackQueueItem(
      id: item.id,
      sourceId: _stringOrNull(extras['sourceId']) ?? item.id,
      sourceType: sourceType,
      title: item.title,
      albumTitle: item.album ?? _stringOrNull(extras['albumTitle']),
      albumId: _stringOrNull(extras['albumId']),
      artistNames: (extras['artistNames'] as List? ?? const []).map((artist) => '$artist').toList(),
      artistIds: (extras['artistIds'] as List? ?? const []).map((artistId) => '$artistId').toList(),
      duration: item.duration,
      artworkUrl: image,
      localArtworkPath: localArtworkPath,
      mediaType: mediaType,
      playbackUrl: playbackUrl,
      lyricKey: _stringOrNull(extras['lyricKey']),
      localLyricsPath: _stringOrNull(extras['localLyricsPath']),
      availability: _availabilityFrom(extras['availability']),
      isLiked: extras['liked'] == true,
      isCached: hasUsableCachedAudio(
        isCached: extras['cache'] == true,
        sourceType: sourceType,
        mediaType: mediaType,
        playbackUrl: playbackUrl,
      ),
      metadata: _customMetadata(extras),
    );
  }

  /// 批量将 [MediaItem] 转回应用层播放队列项。
  static List<PlaybackQueueItem> fromMediaItems(List<MediaItem> items) {
    return items.map(fromMediaItem).toList();
  }

  static Uri? _toArtUri(String? localArtworkPath) {
    final normalizedPath = LocalFilePathNormalizer.normalize(localArtworkPath);
    if (normalizedPath.isEmpty) {
      return null;
    }
    return Uri.file(normalizedPath);
  }

  static String? _stringOrNull(Object? value) {
    if (value == null || '$value'.isEmpty) {
      return null;
    }
    return '$value';
  }

  static SourceType _sourceTypeFrom(Object? value) {
    return SourceType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => SourceType.netease,
    );
  }

  static TrackAvailability _availabilityFrom(Object? value) {
    return TrackAvailability.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TrackAvailability.unknown,
    );
  }

  static Map<String, dynamic> _toMediaItemExtras(PlaybackQueueItem item) {
    return {
      ..._customMetadata(item.metadata),
      'sourceType': item.sourceType.name,
      'availability': item.availability.name,
      'type': item.mediaType.name,
      'image': _toArtworkImage(item),
      'url': item.playbackUrl ?? '',
      'liked': item.isLiked,
      'artist': item.artist ?? '',
      'artistNames': item.artistNames,
      'artistIds': item.artistIds,
      'albumTitle': item.albumTitle ?? '',
      'albumId': item.albumId ?? '',
      'sourceId': item.sourceId,
      'localArtworkPath': item.localArtworkPath ?? '',
      'lyricKey': item.lyricKey ?? '',
      'localLyricsPath': item.localLyricsPath ?? '',
      'cache': item.isCached,
    };
  }

  static String _toArtworkImage(PlaybackQueueItem item) {
    final localArtworkPath = LocalFilePathNormalizer.normalize(item.localArtworkPath);
    if (localArtworkPath.isNotEmpty) {
      return localArtworkPath;
    }
    return item.artworkUrl ?? item.localArtworkPath ?? '';
  }

  static Map<String, dynamic> _customMetadata(Map<String, dynamic> extras) {
    const adapterKeys = {
      'type',
      'image',
      'url',
      'liked',
      'artist',
      'artistNames',
      'artistIds',
      'albumTitle',
      'albumId',
      'sourceId',
      'sourceType',
      'localArtworkPath',
      'lyricKey',
      'localLyricsPath',
      'availability',
      'cache',
    };
    return playbackQueueCustomMetadata(
      extras,
      additionalReservedKeys: adapterKeys,
    );
  }
}
