import 'dart:convert';

import 'package:bujuan/core/playback/playback_queue_item_cache_codec.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';

class CloudCacheStore {
  const CloudCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

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

  Future<void> saveSongs(List<PlaybackQueueItem> songs) async {
    await _cacheDataSource.save(
      cacheKey: _cloudSongsKey,
      payloadJson: jsonEncode(await encodePlaybackQueueItemCacheList(songs)),
    );
  }

  static const String _cloudSongsKey = 'CLOUD_SONGS_PAGE_1';
}
