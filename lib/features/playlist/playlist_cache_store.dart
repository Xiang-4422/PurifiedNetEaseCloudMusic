import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/audio_service_handler.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/core/storage/cache_timestamp_store.dart';

import 'playlist_repository.dart';

class PlaylistCacheStore {
  const PlaylistCacheStore({
    CacheTimestampStore? timestampStore,
  }) : _timestampStore = timestampStore ?? const CacheTimestampStore();

  final CacheTimestampStore _timestampStore;

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
    await _touchCacheAccess(playlistId);
    await _pruneCaches();
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
    await _touchCacheAccess(playlistId);
    await _pruneCaches();
  }

  String _songsCacheKey(String playlistId) => 'PLAYLIST_SONGS_$playlistId';

  String _snapshotCacheKey(String playlistId) =>
      'PLAYLIST_SNAPSHOT_$playlistId';

  Future<void> touchRefresh(String playlistId) {
    return _timestampStore.markUpdated(_refreshCacheKey(playlistId));
  }

  bool isFresh(
    String playlistId, {
    required Duration ttl,
  }) {
    return _timestampStore.isFresh(
      _refreshCacheKey(playlistId),
      ttl: ttl,
    );
  }

  Future<void> _touchCacheAccess(String playlistId) async {
    final raw = CacheBox.instance.get(_playlistAccessKey);
    final accessMap = <String, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        accessMap['${entry.key}'] = entry.value is int ? entry.value as int : 0;
      }
    }
    accessMap[playlistId] = DateTime.now().millisecondsSinceEpoch;
    await CacheBox.instance.put(_playlistAccessKey, accessMap);
    await touchRefresh(playlistId);
  }

  Future<void> _pruneCaches() async {
    final raw = CacheBox.instance.get(_playlistAccessKey);
    if (raw is! Map) {
      return;
    }
    final accessEntries = raw.entries
        .map(
          (entry) => MapEntry(
            '${entry.key}',
            entry.value is int ? entry.value as int : 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    if (accessEntries.length <= _maxPlaylistCacheCount) {
      return;
    }
    final removeCount = accessEntries.length - _maxPlaylistCacheCount;
    final removeIds = accessEntries.take(removeCount).map((entry) => entry.key);
    final nextMap = <String, int>{};
    for (final entry in accessEntries.skip(removeCount)) {
      nextMap[entry.key] = entry.value;
    }
    for (final playlistId in removeIds) {
      await CacheBox.instance.delete(_songsCacheKey(playlistId));
      await CacheBox.instance.delete(_snapshotCacheKey(playlistId));
      await _timestampStore.clear(_refreshCacheKey(playlistId));
    }
    await CacheBox.instance.put(_playlistAccessKey, nextMap);
  }

  static const String _playlistAccessKey = 'PLAYLIST_CACHE_LAST_ACCESS';
  static const int _maxPlaylistCacheCount = 30;

  String _refreshCacheKey(String playlistId) =>
      'PLAYLIST_CACHE_LAST_REFRESH_$playlistId';
}
