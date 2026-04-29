import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

Future<List<MediaItem>> decodeMediaItemCacheList(List<String> cachedItems) {
  return compute(_decodeMediaItemCacheList, cachedItems);
}

List<MediaItem> _decodeMediaItemCacheList(List<String> cachedItems) {
  return cachedItems.map((item) {
    final raw = jsonDecode(item) as Map<String, dynamic>;
    return MediaItem(
      id: raw['id'] as String? ?? '',
      title: raw['title'] as String? ?? '',
      album: raw['album'] as String?,
      artist: raw['artist'] as String?,
      genre: raw['genre'] as String?,
      duration: raw['duration'] != null
          ? Duration(milliseconds: raw['duration'] as int)
          : null,
      artUri: raw['artUri'] != null ? Uri.parse(raw['artUri'] as String) : null,
      playable: raw['playable'] as bool?,
      displayTitle: raw['displayTitle'] as String?,
      displaySubtitle: raw['displaySubtitle'] as String?,
      displayDescription: raw['displayDescription'] as String?,
      extras: raw['extras'] as Map<String, dynamic>?,
    );
  }).toList();
}

Future<List<String>> encodeMediaItemCacheList(List<MediaItem> items) {
  return compute(_encodeMediaItemCacheList, items);
}

List<String> _encodeMediaItemCacheList(List<MediaItem> items) {
  return items
      .map(
        (item) => jsonEncode(
          <String, dynamic>{
            'id': item.id,
            'title': item.title,
            'album': item.album,
            'artist': item.artist,
            'genre': item.genre,
            'duration': item.duration?.inMilliseconds,
            'artUri': item.artUri?.toString(),
            'playable': item.playable,
            'displayTitle': item.displayTitle,
            'displaySubtitle': item.displaySubtitle,
            'displayDescription': item.displayDescription,
            'extras': item.extras,
          },
        ),
      )
      .toList();
}
