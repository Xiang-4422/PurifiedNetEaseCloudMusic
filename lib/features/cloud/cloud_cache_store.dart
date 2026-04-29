import 'dart:convert';

import 'package:bujuan/core/playback/playback_queue_item_cache_codec.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 云盘缓存存储。
class CloudCacheStore {
  /// 创建云盘缓存存储。
  const CloudCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  /// 加载缓存的云盘歌曲。
  Future<List<PlaybackQueueItem>?> loadSongs() async {
    final payloadJson = await _cacheDataSource.loadPayloadJson(_cloudSongsKey);
    if (payloadJson == null) {
      return null;
    }
    final cachedSongs = jsonDecode(payloadJson);
    if (cachedSongs is! List) {
      return null;
    }
    return decodePlaybackQueueItemCacheList(
      cachedSongs.map((item) => '$item').toList(),
    );
  }

  /// 保存云盘歌曲缓存。
  Future<void> saveSongs(List<PlaybackQueueItem> songs) async {
    await _cacheDataSource.save(
      cacheKey: _cloudSongsKey,
      payloadJson: jsonEncode(await encodePlaybackQueueItemCacheList(songs)),
    );
  }

  static const String _cloudSongsKey = 'CLOUD_SONGS_PAGE_1';
}
