import 'dart:convert';

import 'package:bujuan/domain/entities/playback_queue_item.dart';

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
    return PlaybackQueueItem.fromJson(raw);
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
  return items.map((item) => jsonEncode(item.toJson())).toList();
}
