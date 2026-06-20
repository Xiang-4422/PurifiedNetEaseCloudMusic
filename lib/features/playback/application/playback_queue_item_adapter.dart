import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';

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
    return PlaybackQueueItem(
      id: item.id,
      sourceId: _stringOrNull(extras['sourceId']) ?? item.id,
      sourceType: _sourceTypeFrom(extras['sourceType']),
      title: item.title,
      albumTitle: item.album ?? _stringOrNull(extras['albumTitle']),
      albumId: _stringOrNull(extras['albumId']),
      artistNames: (extras['artistNames'] as List? ?? const []).map((artist) => '$artist').toList(),
      artistIds: (extras['artistIds'] as List? ?? const []).map((artistId) => '$artistId').toList(),
      duration: item.duration,
      artworkUrl: image,
      localArtworkPath: localArtworkPath,
      mediaType: MediaType.values.firstWhere(
        (type) => type.name == extras['type'],
        orElse: () => MediaType.playlist,
      ),
      playbackUrl: _stringOrNull(extras['url']),
      lyricKey: _stringOrNull(extras['lyricKey']),
      isLiked: extras['liked'] == true,
      isCached: extras['cache'] == true,
      metadata: _customMetadata(extras),
    );
  }

  /// 批量将 [MediaItem] 转回应用层播放队列项。
  static List<PlaybackQueueItem> fromMediaItems(List<MediaItem> items) {
    return items.map(fromMediaItem).toList();
  }

  static Uri? _toArtUri(String? localArtworkPath) {
    if (localArtworkPath == null || localArtworkPath.isEmpty) {
      return null;
    }
    return Uri.file(File(localArtworkPath).path);
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

  static Map<String, dynamic> _toMediaItemExtras(PlaybackQueueItem item) {
    return {
      ...item.metadata,
      'sourceType': item.sourceType.name,
      'type': item.mediaType.name,
      'image': item.artworkUrl ?? item.localArtworkPath ?? '',
      'url': item.playbackUrl ?? '',
      'liked': item.isLiked,
      'artist': item.artist ?? '',
      'artistNames': item.artistNames,
      'artistIds': item.artistIds,
      'albumTitle': item.albumTitle ?? '',
      'albumId': item.albumId ?? _stringOrNull(item.metadata['albumId']) ?? '',
      'sourceId': item.sourceId,
      'localArtworkPath': item.localArtworkPath ?? '',
      'lyricKey': item.lyricKey ?? '',
      'cache': item.isCached,
    };
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
      'cache',
    };
    final metadata = Map<String, dynamic>.from(extras);
    for (final key in adapterKeys) {
      metadata.remove(key);
    }
    return metadata;
  }
}
