import 'dart:convert';

import 'package:bujuan/core/playback/playback_queue_item_cache_codec.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';

import 'playlist_repository.dart';

/// 保存歌单快照和歌单歌曲队列缓存。
class PlaylistCacheStore {
  /// 创建歌单缓存存储。
  const PlaylistCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  /// 读取缓存的歌单歌曲队列。
  Future<List<PlaybackQueueItem>?> loadSongs(String playlistId) async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(_songsCacheKey(playlistId));
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

  /// 保存歌单歌曲队列缓存。
  Future<void> saveSongs(
    String playlistId,
    List<PlaybackQueueItem> songs,
  ) async {
    await _cacheDataSource.save(
      cacheKey: _songsCacheKey(playlistId),
      payloadJson: jsonEncode(await encodePlaybackQueueItemCacheList(songs)),
    );
    await _touchCacheAccess(playlistId);
    await _pruneCaches();
  }

  /// 读取缓存的歌单快照。
  Future<PlaylistSnapshotData?> loadSnapshot(String playlistId) async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(_snapshotCacheKey(playlistId));
    if (payloadJson == null) {
      return null;
    }
    final cachedSnapshot = jsonDecode(payloadJson);
    if (cachedSnapshot is! Map) {
      return null;
    }
    return PlaylistSnapshotData.fromJson(
      Map<String, dynamic>.from(
        cachedSnapshot.map((key, value) => MapEntry('$key', value)),
      ),
    );
  }

  /// 保存歌单快照缓存。
  Future<void> saveSnapshot(
    String playlistId,
    PlaylistSnapshotData snapshot,
  ) async {
    await _cacheDataSource.save(
      cacheKey: _snapshotCacheKey(playlistId),
      payloadJson: jsonEncode(snapshot.toJson()),
    );
    await _touchCacheAccess(playlistId);
    await _pruneCaches();
  }

  /// 删除指定歌单的歌曲、快照和刷新标记缓存。
  Future<void> invalidate(String playlistId) async {
    await _cacheDataSource.delete(_songsCacheKey(playlistId));
    await _cacheDataSource.delete(_snapshotCacheKey(playlistId));
    await _cacheDataSource.delete(_refreshCacheKey(playlistId));
  }

  String _songsCacheKey(String playlistId) => 'PLAYLIST_SONGS_$playlistId';

  String _snapshotCacheKey(String playlistId) =>
      'PLAYLIST_SNAPSHOT_$playlistId';

  /// 更新歌单缓存刷新时间。
  Future<void> touchRefresh(String playlistId) {
    return _cacheDataSource.save(
      cacheKey: _refreshCacheKey(playlistId),
      payloadJson: '{}',
    );
  }

  /// 判断歌单缓存是否仍在 TTL 内。
  Future<bool> isFresh(
    String playlistId, {
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      _refreshCacheKey(playlistId),
      ttl: ttl,
    );
  }

  Future<void> _touchCacheAccess(String playlistId) async {
    final rawJson = await _cacheDataSource.loadPayloadJson(_playlistAccessKey);
    final raw = rawJson == null ? null : jsonDecode(rawJson);
    final accessMap = <String, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        accessMap['${entry.key}'] = entry.value is int ? entry.value as int : 0;
      }
    }
    accessMap[playlistId] = DateTime.now().millisecondsSinceEpoch;
    await _cacheDataSource.save(
      cacheKey: _playlistAccessKey,
      payloadJson: jsonEncode(accessMap),
    );
    await touchRefresh(playlistId);
  }

  Future<void> _pruneCaches() async {
    final rawJson = await _cacheDataSource.loadPayloadJson(_playlistAccessKey);
    final raw = rawJson == null ? null : jsonDecode(rawJson);
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
      await _cacheDataSource.delete(_songsCacheKey(playlistId));
      await _cacheDataSource.delete(_snapshotCacheKey(playlistId));
      await _cacheDataSource.delete(_refreshCacheKey(playlistId));
    }
    await _cacheDataSource.save(
      cacheKey: _playlistAccessKey,
      payloadJson: jsonEncode(nextMap),
    );
  }

  static const String _playlistAccessKey = 'PLAYLIST_CACHE_LAST_ACCESS';
  static const int _maxPlaylistCacheCount = 30;

  String _refreshCacheKey(String playlistId) =>
      'PLAYLIST_CACHE_LAST_REFRESH_$playlistId';
}
