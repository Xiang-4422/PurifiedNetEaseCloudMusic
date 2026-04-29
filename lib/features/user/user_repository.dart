import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/netease_user_remote_data_source.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';
import 'package:bujuan/features/library/library_repository.dart';

/// 聚合用户远程数据、本地用户快照和曲库缓存的仓库。
class UserRepository {
  /// 创建用户仓库。
  UserRepository({
    required LibraryRepository libraryRepository,
    NeteaseUserRemoteDataSource? remoteDataSource,
    required UserScopedDataSource userScopedDataSource,
  })  : _libraryRepository = libraryRepository,
        _remoteDataSource =
            remoteDataSource ?? const NeteaseUserRemoteDataSource(),
        _userScopedDataSource = userScopedDataSource;

  final LibraryRepository _libraryRepository;
  final NeteaseUserRemoteDataSource _remoteDataSource;
  final UserScopedDataSource _userScopedDataSource;

  /// 从本地用户作用域缓存读取用户资料。
  Future<UserProfileData?> loadCachedUserDetail(String userId) {
    return _userScopedDataSource.loadProfile(userId);
  }

  /// 从远程拉取用户资料并写入本地用户快照。
  Future<UserProfileData> fetchUserDetail(String userId) async {
    final profile = await _remoteDataSource.fetchUserDetail(userId);
    await _userScopedDataSource.saveProfile(profile);
    return profile;
  }

  /// 从本地用户作用域缓存读取喜欢歌曲的网易云数字 id。
  Future<List<int>> loadCachedLikedSongIds(String userId) async {
    final trackIds = await _userScopedDataSource.loadTrackIds(
      userId,
      UserTrackListKind.liked,
    );
    return trackIds
        .map(_toSongSourceId)
        .whereType<int>()
        .toList(growable: false);
  }

  /// 从本地用户作用域缓存读取指定类型的歌单列表。
  Future<List<PlaylistSummaryData>> loadCachedPlaylistList(
    String userId,
    UserPlaylistListKind kind,
  ) {
    return _userScopedDataSource.loadPlaylistItems(userId, kind);
  }

  /// 从本地用户作用域缓存读取指定类型的曲目列表并转换为播放队列项。
  Future<List<PlaybackQueueItem>> loadCachedTrackList({
    required String userId,
    required UserTrackListKind kind,
    required List<int> likedSongIds,
  }) async {
    final trackIds = await _userScopedDataSource.loadTrackIds(userId, kind);
    return loadCachedSongsByIds(
      ids: trackIds,
      likedSongIds: likedSongIds,
    );
  }

  /// 判断指定同步标记在给定 TTL 内是否仍然新鲜。
  Future<bool> isSyncMarkerFresh({
    required String userId,
    required String markerKey,
    required Duration ttl,
  }) async {
    final updatedAt = await _userScopedDataSource.loadSyncMarker(
      userId,
      markerKey,
    );
    if (updatedAt == null) {
      return false;
    }
    return DateTime.now().difference(updatedAt) < ttl;
  }

  /// 更新指定同步标记的刷新时间。
  Future<void> markSyncMarkerUpdated({
    required String userId,
    required String markerKey,
  }) {
    return _userScopedDataSource.markSyncMarkerUpdated(userId, markerKey);
  }

  /// 拉取用户喜欢歌曲 id，并替换本地喜欢歌曲索引。
  Future<List<int>> fetchLikedSongIds(String userId) async {
    final likedSongIds = await _remoteDataSource.fetchLikedSongIds(userId);
    await _userScopedDataSource.replaceTrackList(
      userId,
      UserTrackListKind.liked,
      likedSongIds.map((songId) => 'netease:$songId').toList(),
    );
    return likedSongIds;
  }

  /// 拉取推荐歌单，并按分页位置更新本地推荐歌单快照。
  Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists({
    required String userId,
    required int offset,
    int limit = 10,
  }) async {
    final playlists = await _remoteDataSource.fetchRecommendedPlaylists(
      offset: offset,
      limit: limit,
    );
    final summaries = playlists.map(PlaylistSummaryData.fromEntity).toList();
    if (offset == 0) {
      await _userScopedDataSource.replacePlaylistItems(
        userId,
        UserPlaylistListKind.recommended,
        summaries,
      );
    } else {
      await _userScopedDataSource.appendPlaylistItems(
        userId,
        UserPlaylistListKind.recommended,
        summaries,
        startOrder: offset,
      );
    }
    return summaries;
  }

  /// 拉取用户歌单，并拆分“我喜欢的音乐”和用户创建歌单快照。
  Future<List<PlaylistSummaryData>> fetchUserPlaylists(String userId) async {
    final playlists = await _remoteDataSource.fetchUserPlaylists(userId);
    final summaries = playlists.map(PlaylistSummaryData.fromEntity).toList();
    final likedCollection = summaries.take(1).toList();
    final ownPlaylists =
        summaries.length > 1 ? summaries.sublist(1) : <PlaylistSummaryData>[];
    await _userScopedDataSource.replacePlaylistItems(
      userId,
      UserPlaylistListKind.likedCollection,
      likedCollection,
    );
    await _userScopedDataSource.replacePlaylistItems(
      userId,
      UserPlaylistListKind.userPlaylists,
      ownPlaylists,
    );
    return summaries;
  }

  /// 拉取每日推荐歌曲，保存曲库缓存后转换为播放队列项。
  Future<List<PlaybackQueueItem>> fetchTodayRecommendSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    final tracks = await _remoteDataSource.fetchTodayRecommendSongs();
    await _libraryRepository.saveTracks(tracks);
    await _userScopedDataSource.replaceTrackList(
      userId,
      UserTrackListKind.dailyRecommend,
      tracks.map((track) => track.id).toList(),
    );
    return _queueItemsFromSavedTracks(tracks, likedSongIds: likedSongIds);
  }

  /// 拉取私人 FM 歌曲，保存曲库缓存后转换为 FM 播放队列项。
  Future<List<PlaybackQueueItem>> fetchFmSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    final tracks = await _remoteDataSource.fetchFmSongs();
    await _libraryRepository.saveTracks(tracks);
    await _userScopedDataSource.replaceTrackList(
      userId,
      UserTrackListKind.fm,
      tracks.map((track) => track.id).toList(),
    );
    return _queueItemsFromSavedTracks(
      tracks,
      likedSongIds: likedSongIds,
      mediaType: MediaType.fm,
    );
  }

  /// 拉取心动模式歌曲并转换为播放队列项。
  Future<List<PlaybackQueueItem>> fetchHeartBeatSongs({
    required String startSongId,
    required String randomLikedSongId,
    required bool fromPlayAll,
    required List<int> likedSongIds,
  }) async {
    final tracks = await _remoteDataSource.fetchHeartBeatSongs(
      startSongId: startSongId,
      randomLikedSongId: randomLikedSongId,
      fromPlayAll: fromPlayAll,
    );
    await _libraryRepository.saveTracks(tracks);
    return _queueItemsFromSavedTracks(tracks, likedSongIds: likedSongIds);
  }

  /// 按网易云歌曲 id 拉取歌曲详情并转换为播放队列项。
  Future<List<PlaybackQueueItem>> fetchSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final tracks = await _remoteDataSource.fetchSongsByIds(
      ids: ids,
    );
    await _libraryRepository.saveTracks(tracks);
    return _queueItemsFromSavedTracks(tracks, likedSongIds: likedSongIds);
  }

  /// 从本地曲库按 id 读取歌曲并转换为播放队列项。
  Future<List<PlaybackQueueItem>> loadCachedSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final normalizedIds = ids.map(_toTrackId).toList();
    final tracks =
        await _libraryRepository.getTracksWithResources(normalizedIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = {
      for (final track in tracks) track.track.id: track,
    };
    final orderedTracks = normalizedIds
        .map((trackId) => tracksById[trackId])
        .whereType<TrackWithResources>()
        .toList();
    if (orderedTracks.isEmpty) {
      return const [];
    }
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      orderedTracks,
      likedSongIds: likedSongIds,
    );
  }

  /// 从本地曲库读取歌曲封面地址。
  Future<String> loadCachedSongAlbumUrl(String songId) async {
    final artworkSource = await _libraryRepository.getArtworkSource(
      _toTrackId(songId),
    );
    if (artworkSource.isEmpty) {
      return '';
    }
    return ImageUrlNormalizer.normalize(artworkSource);
  }

  /// 拉取歌曲封面并回写曲库缓存。
  Future<String> fetchSongAlbumUrl(String songId) async {
    final artworkUrl = await _remoteDataSource.fetchSongAlbumUrl(songId);
    if (artworkUrl.isEmpty) {
      return '';
    }
    final result = await _remoteDataSource.fetchSongsByIds(
      ids: [songId],
    );
    await _libraryRepository.saveTracks(result);
    return loadCachedSongAlbumUrl(songId);
  }

  /// 切换歌曲喜欢状态，并同步本地喜欢歌曲索引。
  Future<OperationResult> toggleLikeSong(
    String userId,
    String songId,
    bool like,
  ) async {
    final result = await _remoteDataSource.toggleLikeSong(songId, like);
    if (result.success) {
      final trackId = _toTrackId(songId);
      if (like) {
        await _userScopedDataSource.upsertTrackRef(
          userId,
          UserTrackListKind.liked,
          trackId,
        );
      } else {
        await _userScopedDataSource.deleteTrackRef(
          userId,
          UserTrackListKind.liked,
          trackId,
        );
      }
    }
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  /// 执行远程登出。
  Future<OperationResult> logout() async {
    final result = await _remoteDataSource.logout();
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  String _toTrackId(String songId) {
    if (songId.startsWith('netease:') || songId.startsWith('local:')) {
      return songId;
    }
    return 'netease:$songId';
  }

  Future<List<PlaybackQueueItem>> _queueItemsFromSavedTracks(
    List<Track> tracks, {
    required List<int> likedSongIds,
    MediaType? mediaType,
  }) async {
    if (tracks.isEmpty) {
      return const [];
    }
    final mergedTracks = await _libraryRepository.getTracksByIds(
      tracks.map((track) => track.id),
    );
    return PlaybackQueueItemMapper.fromTrackList(
      mergedTracks.isEmpty ? tracks : mergedTracks,
      likedSongIds: likedSongIds,
      mediaType: mediaType,
    );
  }

  int? _toSongSourceId(String trackId) {
    final sourceId = trackId.startsWith('netease:')
        ? trackId.substring('netease:'.length)
        : trackId;
    return int.tryParse(sourceId);
  }
}
