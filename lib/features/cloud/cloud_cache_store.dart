import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_cache_codec.dart';
import 'package:bujuan/core/storage/cache_box.dart';

class CloudCacheStore {
  const CloudCacheStore();

  Future<List<MediaItem>?> loadSongs() async {
    final cachedSongs = CacheBox.instance.get(_cloudSongsKey);
    if (cachedSongs == null) {
      return null;
    }
    return decodeMediaItemCacheList(cachedSongs.cast<String>());
  }

  Future<void> saveSongs(List<MediaItem> songs) async {
    await CacheBox.instance.put(
      _cloudSongsKey,
      await encodeMediaItemCacheList(songs),
    );
  }

  static const String _cloudSongsKey = 'CLOUD_SONGS_PAGE_1';
}
