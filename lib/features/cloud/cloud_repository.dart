import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/playback/application/track_playback_queue_builder.dart';

/// 云盘仓库，聚合云盘远程数据、用户缓存和本地曲库资源。
class CloudRepository {
  /// 创建云盘仓库。
  CloudRepository({
    required MusicDataRepository musicDataRepository,
    required UserTrackListDataSource userTrackListDataSource,
    required CloudRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _musicDataRepository = musicDataRepository,
        _userTrackListDataSource = userTrackListDataSource,
        _queueBuilder = TrackPlaybackQueueBuilder(musicDataRepository);

  final CloudRemoteDataSource _remoteDataSource;
  final MusicDataRepository _musicDataRepository;
  final UserTrackListDataSource _userTrackListDataSource;
  final TrackPlaybackQueueBuilder _queueBuilder;

  /// 加载缓存的云盘歌曲。
  Future<List<PlaybackQueueItem>> loadCachedSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final trackIds = await _userTrackListDataSource.loadTrackIds(
      normalizedUserId,
      UserTrackListKind.cloud,
    );
    if (trackIds.isEmpty) {
      return const [];
    }
    return _queueBuilder.buildFromTrackIds(
      trackIds,
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const CloudSongPage(
        items: [],
        hasMore: false,
        nextOffset: 0,
      );
    }
    final result = await _remoteDataSource.fetchCloudSongs(
      offset: offset,
      limit: limit,
    );
    await _musicDataRepository.saveTracks(
      result.tracks,
      precacheArtwork: true,
      awaitArtworkPrecache: false,
    );
    final items = await _queueBuilder.build(
      result.tracks,
      likedSongIds: likedSongIds,
    );
    final trackIds = result.tracks.map((track) => track.id).toList();
    if (offset == 0) {
      await _userTrackListDataSource.replaceTrackList(
        normalizedUserId,
        UserTrackListKind.cloud,
        trackIds,
      );
    } else {
      await _userTrackListDataSource.appendTrackList(
        normalizedUserId,
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

  bool _isBlankUserId(String userId) {
    return _normalizedUserId(userId).isEmpty;
  }

  String _normalizedUserId(String userId) {
    return userId.trim();
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
