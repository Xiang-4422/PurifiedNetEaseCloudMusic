import 'dart:convert';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart' show TrackAvailability;
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/features/playback/application/playback_queue_cached_audio_guard.dart';
import 'package:bujuan/features/playback/application/playback_queue_metadata_filter.dart';

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
  final decodedItems = <PlaybackQueueItem>[];
  for (final item in cachedItems) {
    final decodedItem = _tryDecodePlaybackQueueItemCache(item);
    if (decodedItem != null && decodedItem.id.isNotEmpty) {
      decodedItems.add(decodedItem);
    }
  }
  return decodedItems;
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
  return items.where((item) => _normalizedQueueItemId(item.id).isNotEmpty).map((item) => jsonEncode(_playbackQueueItemToCacheJson(item))).toList();
}

PlaybackQueueItem _playbackQueueItemFromCacheJson(Map<String, dynamic> json) {
  final metadata = Map<String, dynamic>.from(json['metadata'] as Map? ?? const {});
  final sourceType = _sourceTypeFrom(json['sourceType'] ?? metadata['sourceType']);
  final mediaType = MediaType.values.firstWhere(
    (item) => item.name == json['mediaType'],
    orElse: () => MediaType.playlist,
  );
  final playbackUrl = _restorablePlaybackUrl(json['playbackUrl']);
  return PlaybackQueueItem(
    id: _normalizedQueueItemId(json['id'] as String? ?? ''),
    sourceId: json['sourceId'] as String? ?? '',
    sourceType: sourceType,
    title: json['title'] as String? ?? '',
    albumTitle: json['albumTitle'] as String?,
    albumId: _stringOrNull(json['albumId']) ?? _stringOrNull(metadata['albumId']),
    artistNames: (json['artistNames'] as List? ?? const []).map((item) => '$item').toList(),
    artistIds: _stringList(json['artistIds'] ?? metadata['artistIds']),
    duration: json['duration'] is int ? Duration(milliseconds: json['duration'] as int) : null,
    artworkUrl: json['artworkUrl'] as String?,
    localArtworkPath: _restorableLocalPath(json['localArtworkPath']),
    mediaType: mediaType,
    playbackUrl: playbackUrl,
    lyricKey: json['lyricKey'] as String?,
    localLyricsPath: _restorableLocalPath(json['localLyricsPath']) ?? _restorableLocalPath(metadata['localLyricsPath']),
    availability: _availabilityFrom(json['availability'] ?? metadata['availability']),
    isLiked: json['isLiked'] as bool? ?? false,
    isCached: hasUsableCachedAudio(
      isCached: json['isCached'] as bool? ?? false,
      sourceType: sourceType,
      mediaType: mediaType,
      playbackUrl: playbackUrl,
    ),
    customMetadata: PlaybackQueueItemMetadata.custom(playbackQueueCustomMetadata(metadata)),
  );
}

Map<String, dynamic> _playbackQueueItemToCacheJson(PlaybackQueueItem item) {
  return {
    'id': _normalizedQueueItemId(item.id),
    'sourceId': item.sourceId,
    'sourceType': item.sourceType.name,
    'title': item.title,
    'albumTitle': item.albumTitle,
    'albumId': item.albumId,
    'artistNames': item.artistNames,
    'artistIds': item.artistIds,
    'duration': item.duration?.inMilliseconds,
    'artworkUrl': item.artworkUrl,
    'localArtworkPath': _restorableLocalPath(item.localArtworkPath),
    'mediaType': item.mediaType.name,
    'playbackUrl': _restorablePlaybackUrl(item.playbackUrl),
    'lyricKey': item.lyricKey,
    'localLyricsPath': _restorableLocalPath(item.localLyricsPath),
    'availability': item.availability.name,
    'isLiked': item.isLiked,
    'isCached': hasUsableCachedAudio(
      isCached: item.isCached,
      sourceType: item.sourceType,
      mediaType: item.mediaType,
      playbackUrl: item.playbackUrl,
    ),
    'metadata': _customMetadata(item.customMetadata.values),
  };
}

String _normalizedQueueItemId(String id) {
  return id.trim();
}

Map<String, dynamic> _customMetadata(Map<String, dynamic> metadata) {
  return playbackQueueCustomMetadata(metadata);
}

PlaybackQueueItem? _tryDecodePlaybackQueueItemCache(String item) {
  try {
    final raw = jsonDecode(item);
    if (raw is! Map) {
      return null;
    }
    return _playbackQueueItemFromCacheJson(Map<String, dynamic>.from(raw));
  } catch (_) {
    return null;
  }
}

SourceType _sourceTypeFrom(Object? value) {
  return SourceType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => SourceType.netease,
  );
}

TrackAvailability _availabilityFrom(Object? value) {
  return TrackAvailability.values.firstWhere(
    (item) => item.name == value,
    orElse: () => TrackAvailability.unknown,
  );
}

List<String> _stringList(Object? value) {
  return (value as List? ?? const []).map((item) => '$item').where((item) => item.isNotEmpty).toList();
}

String? _stringOrNull(Object? value) {
  if (value == null || '$value'.isEmpty) {
    return null;
  }
  return '$value';
}

String? _restorablePlaybackUrl(Object? value) {
  final normalized = LocalFilePathNormalizer.normalize(_stringOrNull(value));
  return normalized.isEmpty ? null : normalized;
}

String? _restorableLocalPath(Object? value) {
  final normalized = LocalFilePathNormalizer.normalize(_stringOrNull(value));
  return normalized.isEmpty ? null : normalized;
}
