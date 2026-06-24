import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/state/operation_result.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_mapper.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';

/// 聚合用户远程数据、本地用户数据和曲库缓存的仓库。
class UserRepository {
  /// 创建用户仓库。
  UserRepository({
    required MusicDataRepository musicDataRepository,
    required UserRemoteDataSource remoteDataSource,
    required UserProfileDataSource userProfileDataSource,
    required UserTrackListDataSource userTrackListDataSource,
    required UserPlaylistListDataSource userPlaylistListDataSource,
    required UserSyncMarkerDataSource userSyncMarkerDataSource,
  })  : _musicDataRepository = musicDataRepository,
        _remoteDataSource = remoteDataSource,
        _userProfileDataSource = userProfileDataSource,
        _userTrackListDataSource = userTrackListDataSource,
        _userPlaylistListDataSource = userPlaylistListDataSource,
        _userSyncMarkerDataSource = userSyncMarkerDataSource;

  final MusicDataRepository _musicDataRepository;
  final UserRemoteDataSource _remoteDataSource;
  final UserProfileDataSource _userProfileDataSource;
  final UserTrackListDataSource _userTrackListDataSource;
  final UserPlaylistListDataSource _userPlaylistListDataSource;
  final UserSyncMarkerDataSource _userSyncMarkerDataSource;

  /// 从本地用户作用域缓存读取用户资料。
  Future<UserProfileData?> loadCachedUserDetail(String userId) {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return Future.value();
    }
    return _userProfileDataSource.loadProfile(normalizedUserId);
  }

  /// 从远程拉取用户资料并写入本地用户数据。
  Future<UserProfileData> fetchUserDetail(String userId) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return _emptyUserProfile;
    }
    final profile = await _remoteDataSource.fetchUserDetail(normalizedUserId);
    await _userProfileDataSource.saveProfile(profile);
    return profile;
  }

  /// 从本地用户作用域缓存读取喜欢歌曲的网易云数字 id。
  Future<List<int>> loadCachedLikedSongIds(String userId) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final trackIds = await _userTrackListDataSource.loadTrackIds(
      normalizedUserId,
      UserTrackListKind.liked,
    );
    return trackIds.map(_toSongSourceId).whereType<int>().toList(growable: false);
  }

  /// 从本地用户作用域缓存读取指定类型的歌单列表。
  Future<List<PlaylistSummaryData>> loadCachedPlaylistList(
    String userId,
    UserPlaylistListKind kind,
  ) {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return Future.value(const <PlaylistSummaryData>[]);
    }
    return _userPlaylistListDataSource.loadPlaylistItems(normalizedUserId, kind);
  }

  /// 从本地用户作用域缓存读取指定类型的曲目列表并转换为播放队列项。
  Future<List<PlaybackQueueItem>> loadCachedTrackList({
    required String userId,
    required UserTrackListKind kind,
    required List<int> likedSongIds,
  }) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final trackIds = await _userTrackListDataSource.loadTrackIds(normalizedUserId, kind);
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return false;
    }
    final updatedAt = await _userSyncMarkerDataSource.loadSyncMarker(
      normalizedUserId,
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return Future<void>.value();
    }
    return _userSyncMarkerDataSource.markSyncMarkerUpdated(normalizedUserId, markerKey);
  }

  /// 拉取用户喜欢歌曲 id，并替换本地喜欢歌曲索引。
  Future<List<int>> fetchLikedSongIds(String userId) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final likedSongIds = await _remoteDataSource.fetchLikedSongIds(normalizedUserId);
    await _userTrackListDataSource.replaceTrackList(
      normalizedUserId,
      UserTrackListKind.liked,
      likedSongIds.map((songId) => MusicResourceId.toNeteaseEntityId('$songId')).toList(),
    );
    return likedSongIds;
  }

  /// 拉取用户资料库启动快照，远程数据全部成功后再替换本地索引。
  Future<({List<int> likedSongIds, List<PlaylistSummaryData> playlists})> fetchUserLibrarySnapshot(
    String userId,
  ) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return (
        likedSongIds: const <int>[],
        playlists: const <PlaylistSummaryData>[],
      );
    }
    final results = await Future.wait<Object>([
      _remoteDataSource.fetchLikedSongIds(normalizedUserId),
      _remoteDataSource.fetchUserPlaylists(normalizedUserId),
    ]);
    final likedSongIds = List<int>.from(results[0] as List<int>);
    final summaries = (results[1] as List<PlaylistEntity>).map(PlaylistSummaryData.fromEntity).toList();
    final likedCollection = summaries.take(1).toList();
    final ownPlaylists = summaries.length > 1 ? summaries.sublist(1) : <PlaylistSummaryData>[];

    await _userTrackListDataSource.replaceTrackList(
      normalizedUserId,
      UserTrackListKind.liked,
      likedSongIds.map((songId) => MusicResourceId.toNeteaseEntityId('$songId')).toList(),
    );
    await _userPlaylistListDataSource.replacePlaylistItems(
      normalizedUserId,
      UserPlaylistListKind.likedCollection,
      likedCollection,
    );
    await _userPlaylistListDataSource.replacePlaylistItems(
      normalizedUserId,
      UserPlaylistListKind.userPlaylists,
      ownPlaylists,
    );
    return (
      likedSongIds: likedSongIds,
      playlists: summaries,
    );
  }

  /// 拉取推荐歌单，并按分页位置更新本地推荐歌单数据。
  Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists({
    required String userId,
    required int offset,
    int limit = 10,
  }) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final playlists = await _remoteDataSource.fetchRecommendedPlaylists(
      offset: offset,
      limit: limit,
    );
    final summaries = playlists.map(PlaylistSummaryData.fromEntity).toList();
    if (offset == 0) {
      await _userPlaylistListDataSource.replacePlaylistItems(
        normalizedUserId,
        UserPlaylistListKind.recommended,
        summaries,
      );
    } else {
      await _userPlaylistListDataSource.appendPlaylistItems(
        normalizedUserId,
        UserPlaylistListKind.recommended,
        summaries,
        startOrder: offset,
      );
    }
    return summaries;
  }

  /// 拉取用户歌单，并拆分“我喜欢的音乐”和用户创建歌单数据。
  Future<List<PlaylistSummaryData>> fetchUserPlaylists(String userId) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final playlists = await _remoteDataSource.fetchUserPlaylists(normalizedUserId);
    final summaries = playlists.map(PlaylistSummaryData.fromEntity).toList();
    final likedCollection = summaries.take(1).toList();
    final ownPlaylists = summaries.length > 1 ? summaries.sublist(1) : <PlaylistSummaryData>[];
    await _userPlaylistListDataSource.replacePlaylistItems(
      normalizedUserId,
      UserPlaylistListKind.likedCollection,
      likedCollection,
    );
    await _userPlaylistListDataSource.replacePlaylistItems(
      normalizedUserId,
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final tracks = await _remoteDataSource.fetchTodayRecommendSongs();
    await _musicDataRepository.saveTracks(
      tracks,
      precacheArtwork: true,
      awaitArtworkPrecache: false,
    );
    await _userTrackListDataSource.replaceTrackList(
      normalizedUserId,
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
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const [];
    }
    final tracks = await _remoteDataSource.fetchFmSongs();
    await _musicDataRepository.saveTracks(
      tracks,
      precacheArtwork: true,
      awaitArtworkPrecache: false,
    );
    await _userTrackListDataSource.replaceTrackList(
      normalizedUserId,
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
    await _musicDataRepository.saveTracks(
      tracks,
      precacheArtwork: true,
      awaitArtworkPrecache: false,
    );
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
    await _musicDataRepository.saveTracks(
      tracks,
      precacheArtwork: true,
      awaitArtworkPrecache: false,
    );
    return _queueItemsFromSavedTracks(tracks, likedSongIds: likedSongIds);
  }

  /// 从本地曲库按 id 读取歌曲并转换为播放队列项。
  Future<List<PlaybackQueueItem>> loadCachedSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final normalizedIds = ids.map(MusicResourceId.toNeteaseEntityId).toList();
    final tracks = await _musicDataRepository.getTracksWithResources(normalizedIds);
    if (tracks.isEmpty) {
      return const [];
    }
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      tracks,
      likedSongIds: likedSongIds,
    );
  }

  /// 从本地曲库读取歌曲封面地址。
  Future<String> loadCachedSongAlbumUrl(String songId) async {
    final artworkSource = await _musicDataRepository.getArtworkSource(
      MusicResourceId.toNeteaseEntityId(songId),
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
    await _musicDataRepository.saveTracks(result, precacheArtwork: true);
    return loadCachedSongAlbumUrl(songId);
  }

  /// 切换歌曲喜欢状态，并同步本地喜欢歌曲索引。
  Future<OperationResult> toggleLikeSong(
    String userId,
    String songId,
    bool like,
  ) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (_isBlankUserId(normalizedUserId)) {
      return const OperationResult(success: false);
    }
    final result = await _remoteDataSource.toggleLikeSong(songId, like);
    if (result.success) {
      final trackId = MusicResourceId.toNeteaseEntityId(songId);
      if (like) {
        await _userTrackListDataSource.upsertTrackRef(
          normalizedUserId,
          UserTrackListKind.liked,
          trackId,
        );
      } else {
        await _userTrackListDataSource.deleteTrackRef(
          normalizedUserId,
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

  Future<List<PlaybackQueueItem>> _queueItemsFromSavedTracks(
    List<Track> tracks, {
    required List<int> likedSongIds,
    MediaType? mediaType,
  }) async {
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksWithResources = await _musicDataRepository.getTracksWithResources(
      tracks.map((track) => track.id),
    );
    final resourcesByTrackId = {
      for (final item in tracksWithResources) item.track.id: item.resources,
    };
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      [
        for (final track in tracks)
          TrackWithResources(
            track: track,
            resources: resourcesByTrackId[track.id] ?? const TrackResourceBundle(),
          ),
      ],
      likedSongIds: likedSongIds,
      mediaType: mediaType,
    );
  }

  int? _toSongSourceId(String trackId) {
    return int.tryParse(MusicResourceId.toNeteaseSourceId(trackId));
  }

  bool _isBlankUserId(String userId) {
    return _normalizedUserId(userId).isEmpty;
  }

  String _normalizedUserId(String userId) {
    return userId.trim();
  }

  static const UserProfileData _emptyUserProfile = UserProfileData(
    userId: '',
    nickname: '',
    signature: '',
    follows: 0,
    followeds: 0,
    playlistCount: 0,
    avatarUrl: '',
  );
}
