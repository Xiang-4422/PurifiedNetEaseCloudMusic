import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/netease_cloud_remote_data_source.dart';
class CloudRepository {
  CloudRepository({NeteaseCloudRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? const NeteaseCloudRemoteDataSource();

  final NeteaseCloudRemoteDataSource _remoteDataSource;

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
