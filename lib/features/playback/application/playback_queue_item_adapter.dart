import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';

class PlaybackQueueItemAdapter {
  const PlaybackQueueItemAdapter._();

  static MediaItem toMediaItem(PlaybackQueueItem item) {
    return MediaItem(
      id: item.id,
      title: item.title,
      album: item.albumTitle,
      artist: item.artist,
      duration: item.duration,
      artUri: _toArtUri(item.localArtworkPath),
      extras: {
        ...item.metadata,
        'type': item.mediaType.name,
        'image': item.artworkUrl ?? item.localArtworkPath ?? '',
        'url': item.playbackUrl ?? '',
        'liked': item.isLiked,
        'artist': item.artist ?? '',
        'artistNames': item.artistNames,
        'artistIds': item.artistIds,
        'albumTitle': item.albumTitle ?? '',
        'sourceId': item.sourceId,
        'localArtworkPath': item.localArtworkPath ?? '',
        'lyricKey': item.lyricKey ?? '',
        'cache': item.isCached,
      },
    );
  }

  static List<MediaItem> toMediaItems(List<PlaybackQueueItem> items) {
    return items.map(toMediaItem).toList();
  }

  static PlaybackQueueItem fromMediaItem(MediaItem item) {
    final extras = item.extras ?? const <String, dynamic>{};
    final localArtworkPath = _stringOrNull(extras['localArtworkPath']);
    final image = _stringOrNull(extras['image']);
    return PlaybackQueueItem(
      id: item.id,
      sourceId: _stringOrNull(extras['sourceId']) ?? item.id,
      title: item.title,
      albumTitle: item.album ?? _stringOrNull(extras['albumTitle']),
      artistNames: (extras['artistNames'] as List? ?? const [])
          .map((artist) => '$artist')
          .toList(),
      artistIds: (extras['artistIds'] as List? ?? const [])
          .map((artistId) => '$artistId')
          .toList(),
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
      metadata: Map<String, dynamic>.from(extras),
    );
  }

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
}
