import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/netease_cloud_remote_data_source.dart';
import 'package:bujuan/features/cloud/cloud_cache_store.dart';

class CloudRepository {
  CloudRepository({
    NeteaseCloudRemoteDataSource? remoteDataSource,
    CloudCacheStore? cacheStore,
  })  : _remoteDataSource =
            remoteDataSource ?? const NeteaseCloudRemoteDataSource(),
        _cacheStore = cacheStore ?? const CloudCacheStore();

  final NeteaseCloudRemoteDataSource _remoteDataSource;
  final CloudCacheStore _cacheStore;

  Future<List<MediaItem>?> loadCachedSongs() {
    return _cacheStore.loadSongs();
  }

  Future<CloudSongPage> fetchCloudSongs({
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchCloudSongs(
      offset: offset,
      limit: limit,
      likedSongIds: likedSongIds,
    );
    if (offset == 0 && result.items.isNotEmpty) {
      await _cacheStore.saveSongs(result.items);
    }
    return CloudSongPage(
      items: result.items,
      hasMore: result.itemCount >= limit,
      nextOffset: offset + result.itemCount,
    );
  }
}

class CloudSongPage {
  const CloudSongPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<MediaItem> items;
  final bool hasMore;
  final int nextOffset;
}
