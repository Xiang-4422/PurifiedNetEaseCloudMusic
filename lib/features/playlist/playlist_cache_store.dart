import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/audio_service_handler.dart';
import 'package:bujuan/core/storage/cache_box.dart';

import 'playlist_repository.dart';

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

  Future<PlaylistSnapshotData?> loadSnapshot(String playlistId) async {
    final cachedSnapshot = CacheBox.instance.get(_snapshotCacheKey(playlistId));
    if (cachedSnapshot is! Map) {
      return null;
    }
    return PlaylistSnapshotData.fromJson(
      Map<String, dynamic>.from(
        cachedSnapshot.map((key, value) => MapEntry('$key', value)),
      ),
    );
  }

  Future<void> saveSnapshot(
    String playlistId,
    PlaylistSnapshotData snapshot,
  ) async {
    await CacheBox.instance.put(
      _snapshotCacheKey(playlistId),
      snapshot.toJson(),
    );
  }

  String _songsCacheKey(String playlistId) => 'PLAYLIST_SONGS_$playlistId';

  String _snapshotCacheKey(String playlistId) =>
      'PLAYLIST_SNAPSHOT_$playlistId';
}
