import 'dart:convert';

import 'package:bujuan/domain/entities/playback_queue_item.dart';

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
    return PlaybackQueueItem.fromJson(raw);
  }).toList();
}

Future<List<String>> encodePlaybackQueueItemCacheList(
  List<PlaybackQueueItem> items,
) {
  return Future(
    () => _encodePlaybackQueueItemCacheList(items),
  );
}

List<String> _encodePlaybackQueueItemCacheList(List<PlaybackQueueItem> items) {
  return items.map((item) => jsonEncode(item.toJson())).toList();
}
