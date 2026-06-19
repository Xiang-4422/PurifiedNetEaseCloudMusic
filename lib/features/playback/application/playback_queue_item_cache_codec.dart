import 'dart:convert';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';

/// 异步解码播放队列项缓存列表。
Future<List<PlaybackQueueItem>> decodePlaybackQueueItemCacheList(
  List<String> cachedItems,
) {
  return Future(
    () => _decodePlaybackQueueItemCacheList(cachedItems),
  );
}

List<PlaybackQueueItem> _decodePlaybackQueueItemCacheList(
  List<String> cachedItems,
) {
  return cachedItems.map((item) {
    final raw = jsonDecode(item) as Map<String, dynamic>;
    return _playbackQueueItemFromCacheJson(raw);
  }).toList();
}

/// 异步编码播放队列项缓存列表。
Future<List<String>> encodePlaybackQueueItemCacheList(
  List<PlaybackQueueItem> items,
) {
  return Future(
    () => _encodePlaybackQueueItemCacheList(items),
  );
}

List<String> _encodePlaybackQueueItemCacheList(List<PlaybackQueueItem> items) {
  return items.map((item) => jsonEncode(_playbackQueueItemToCacheJson(item))).toList();
}

PlaybackQueueItem _playbackQueueItemFromCacheJson(Map<String, dynamic> json) {
  return PlaybackQueueItem(
    id: json['id'] as String? ?? '',
    sourceId: json['sourceId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    albumTitle: json['albumTitle'] as String?,
    albumId: _stringOrNull(json['albumId']) ?? _stringOrNull((json['metadata'] as Map?)?['albumId']),
    artistNames: (json['artistNames'] as List? ?? const []).map((item) => '$item').toList(),
    artistIds: (json['artistIds'] as List? ?? const []).map((item) => '$item').toList(),
    duration: json['duration'] is int ? Duration(milliseconds: json['duration'] as int) : null,
    artworkUrl: json['artworkUrl'] as String?,
    localArtworkPath: json['localArtworkPath'] as String?,
    mediaType: MediaType.values.firstWhere(
      (item) => item.name == json['mediaType'],
      orElse: () => MediaType.playlist,
    ),
    playbackUrl: json['playbackUrl'] as String?,
    lyricKey: json['lyricKey'] as String?,
    isLiked: json['isLiked'] as bool? ?? false,
    isCached: json['isCached'] as bool? ?? false,
    metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
  );
}

Map<String, dynamic> _playbackQueueItemToCacheJson(PlaybackQueueItem item) {
  return {
    'id': item.id,
    'sourceId': item.sourceId,
    'title': item.title,
    'albumTitle': item.albumTitle,
    'albumId': item.albumId,
    'artistNames': item.artistNames,
    'artistIds': item.artistIds,
    'duration': item.duration?.inMilliseconds,
    'artworkUrl': item.artworkUrl,
    'localArtworkPath': item.localArtworkPath,
    'mediaType': item.mediaType.name,
    'playbackUrl': item.playbackUrl,
    'lyricKey': item.lyricKey,
    'isLiked': item.isLiked,
    'isCached': item.isCached,
    'metadata': item.metadata,
  };
}

String? _stringOrNull(Object? value) {
  if (value == null || '$value'.isEmpty) {
    return null;
  }
  return '$value';
}
