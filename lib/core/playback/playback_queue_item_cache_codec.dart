import 'dart:convert';

import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:flutter/foundation.dart';

/// 在 isolate 中解码播放队列缓存列表。
Future<List<PlaybackQueueItem>> decodePlaybackQueueItemCacheList(
  List<String> cachedItems,
) {
  return compute(_decodePlaybackQueueItemCacheList, cachedItems);
}

List<PlaybackQueueItem> _decodePlaybackQueueItemCacheList(
  List<String> cachedItems,
) {
  return cachedItems
      .map((item) => PlaybackQueueItem.fromJson(jsonDecode(item)))
      .toList();
}

/// 在 isolate 中编码播放队列缓存列表。
Future<List<String>> encodePlaybackQueueItemCacheList(
  List<PlaybackQueueItem> items,
) {
  return compute(_encodePlaybackQueueItemCacheList, items);
}

List<String> _encodePlaybackQueueItemCacheList(
  List<PlaybackQueueItem> items,
) {
  return items.map((item) => jsonEncode(item.toJson())).toList();
}
