import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/library/library_repository.dart';

/// 云盘仓库，聚合云盘远程数据、用户缓存和本地曲库资源。
class CloudRepository {
  /// 创建云盘仓库。
  CloudRepository({
    required LibraryRepository libraryRepository,
    required UserScopedDataSource userScopedDataSource,
    NeteaseCloudRemoteDataSource? remoteDataSource,
  })  : _remoteDataSource = remoteDataSource ?? NeteaseCloudRemoteDataSource(),
        _libraryRepository = libraryRepository,
        _userScopedDataSource = userScopedDataSource;

  final NeteaseCloudRemoteDataSource _remoteDataSource;
  final LibraryRepository _libraryRepository;
  final UserScopedDataSource _userScopedDataSource;

  /// 加载缓存的云盘歌曲。
  Future<List<PlaybackQueueItem>> loadCachedSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    final trackIds = await _userScopedDataSource.loadTrackIds(
      userId,
      UserTrackListKind.cloud,
    );
    if (trackIds.isEmpty) {
      return const [];
    }
    final tracks = await _libraryRepository.getTracksWithResources(trackIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = {for (final track in tracks) track.track.id: track};
    final orderedTracks = trackIds
        .map((trackId) => tracksById[trackId])
        .whereType<TrackWithResources>()
        .toList();
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      orderedTracks,
      likedSongIds: likedSongIds,
    );
  }

  /// 分页获取云盘歌曲并写入本地曲库和用户缓存。
  Future<CloudSongPage> fetchCloudSongs({
    required String userId,
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchCloudSongs(
      offset: offset,
      limit: limit,
    );
    await _libraryRepository.saveTracks(result.tracks);
    final items = PlaybackQueueItemMapper.fromTrackList(
      result.tracks,
      likedSongIds: likedSongIds,
    );
    final trackIds = result.tracks.map((track) => track.id).toList();
    if (offset == 0) {
      await _userScopedDataSource.replaceTrackList(
        userId,
        UserTrackListKind.cloud,
        trackIds,
      );
    } else {
      await _userScopedDataSource.appendTrackList(
        userId,
        UserTrackListKind.cloud,
        trackIds,
        startOrder: offset,
      );
    }
    return CloudSongPage(
      items: items,
      hasMore: result.itemCount >= limit,
      nextOffset: offset + result.itemCount,
    );
  }
}

/// 云盘歌曲分页数据。
class CloudSongPage {
  /// 创建云盘歌曲分页数据。
  const CloudSongPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  /// 云盘歌曲播放队列项。
  final List<PlaybackQueueItem> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页偏移量。
  final int nextOffset;
}
