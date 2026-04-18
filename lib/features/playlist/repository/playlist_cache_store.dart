import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:bujuan/core/storage/cache_box.dart';

class PlaylistCacheStore {
  const PlaylistCacheStore();

  Future<List<MediaItem>?> loadSongs(String playlistId) async {
    final cachedSongs = CacheBox.instance.get(_songsCacheKey(playlistId));
    if (cachedSongs == null) {
      return null;
    }
    return stringToPlayList(cachedSongs.cast<String>());
  }

  Future<void> saveSongs(
    String playlistId,
    List<MediaItem> songs,
  ) async {
    await CacheBox.instance.put(
      _songsCacheKey(playlistId),
      await playListToString(songs),
    );
  }

  String _songsCacheKey(String playlistId) => 'PLAYLIST_SONGS_$playlistId';
}
