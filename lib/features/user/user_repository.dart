import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/netease_user_remote_data_source.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
import 'package:bujuan/features/user/user_profile_data.dart';
import 'package:get_it/get_it.dart';

class UserRepository {
  UserRepository({
    LibraryRepository? libraryRepository,
    NeteaseUserRemoteDataSource? remoteDataSource,
    UserScopedDataSource? userScopedDataSource,
  })  : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _remoteDataSource =
            remoteDataSource ?? const NeteaseUserRemoteDataSource(),
        _userScopedDataSource = userScopedDataSource ??
            (GetIt.instance.isRegistered<UserScopedDataSource>()
                ? GetIt.instance<UserScopedDataSource>()
                : (throw StateError('UserScopedDataSource is not registered')));

  final LibraryRepository _libraryRepository;
  final NeteaseUserRemoteDataSource _remoteDataSource;
  final UserScopedDataSource _userScopedDataSource;

  Future<UserProfileData?> loadCachedUserDetail(String userId) {
    return _userScopedDataSource.loadProfile(userId);
  }

  Future<UserProfileData> fetchUserDetail(String userId) async {
    final profile = await _remoteDataSource.fetchUserDetail(userId);
    await _userScopedDataSource.saveProfile(profile);
    return profile;
  }

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

  Future<List<PlaylistSummaryData>> loadCachedPlaylistList(
    String userId,
    UserPlaylistListKind kind,
  ) {
    return _userScopedDataSource.loadPlaylistItems(userId, kind);
  }

  Future<List<MediaItem>> loadCachedTrackList({
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

  Future<void> markSyncMarkerUpdated({
    required String userId,
    required String markerKey,
  }) {
    return _userScopedDataSource.markSyncMarkerUpdated(userId, markerKey);
  }

  Future<List<int>> fetchLikedSongIds(String userId) async {
    final likedSongIds = await _remoteDataSource.fetchLikedSongIds(userId);
    await _userScopedDataSource.replaceTrackList(
      userId,
      UserTrackListKind.liked,
      likedSongIds.map((songId) => 'netease:$songId').toList(),
    );
    return likedSongIds;
  }

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

  Future<List<MediaItem>> fetchTodayRecommendSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchTodayRecommendSongs(
      likedSongIds: likedSongIds,
    );
    final tracks = result.tracks;
    await _libraryRepository.saveTracks(tracks);
    await _userScopedDataSource.replaceTrackList(
      userId,
      UserTrackListKind.dailyRecommend,
      tracks.map((track) => track.id).toList(),
    );
    return _mediaItemsFromSavedTracks(tracks, likedSongIds: likedSongIds);
  }

  Future<List<MediaItem>> fetchFmSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchFmSongs(
      likedSongIds: likedSongIds,
    );
    await _libraryRepository.saveTracks(result.tracks);
    await _userScopedDataSource.replaceTrackList(
      userId,
      UserTrackListKind.fm,
      result.tracks.map((track) => track.id).toList(),
    );
    return _mediaItemsFromSavedTracks(result.tracks,
        likedSongIds: likedSongIds);
  }

  Future<List<MediaItem>> fetchHeartBeatSongs({
    required String startSongId,
    required String randomLikedSongId,
    required bool fromPlayAll,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchHeartBeatSongs(
      startSongId: startSongId,
      randomLikedSongId: randomLikedSongId,
      fromPlayAll: fromPlayAll,
      likedSongIds: likedSongIds,
    );
    await _libraryRepository.saveTracks(result.tracks);
    return _mediaItemsFromSavedTracks(result.tracks,
        likedSongIds: likedSongIds);
  }

  Future<List<MediaItem>> fetchSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchSongsByIds(
      ids: ids,
      likedSongIds: likedSongIds,
    );
    await _libraryRepository.saveTracks(result.tracks);
    return _mediaItemsFromSavedTracks(result.tracks,
        likedSongIds: likedSongIds);
  }

  Future<List<MediaItem>> loadCachedSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final normalizedIds = ids.map(_toTrackId).toList();
    final tracks = await _libraryRepository.getTracksByIds(normalizedIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = {
      for (final track in tracks) track.id: track,
    };
    final orderedTracks = normalizedIds
        .map((trackId) => tracksById[trackId])
        .whereType<Track>()
        .toList();
    if (orderedTracks.isEmpty) {
      return const [];
    }
    return MediaItemMapper.fromTrackList(
      orderedTracks,
      likedSongIds: likedSongIds,
    );
  }

  Future<String> loadCachedSongAlbumUrl(String songId) async {
    final tracks =
        await _libraryRepository.getTracksByIds([_toTrackId(songId)]);
    if (tracks.isEmpty) {
      return '';
    }
    final track = tracks.first;
    final localArtworkPath = track.localArtworkPath ?? '';
    if (localArtworkPath.isNotEmpty) {
      return localArtworkPath;
    }
    return '';
  }

  Future<String> fetchSongAlbumUrl(String songId) async {
    final artworkUrl = await _remoteDataSource.fetchSongAlbumUrl(songId);
    if (artworkUrl.isEmpty) {
      return '';
    }
    final result = await _remoteDataSource.fetchSongsByIds(
      ids: [songId],
      likedSongIds: const [],
    );
    await _libraryRepository.saveTracks(result.tracks);
    return loadCachedSongAlbumUrl(songId);
  }

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

  Future<List<MediaItem>> _mediaItemsFromSavedTracks(
    List<Track> tracks, {
    required List<int> likedSongIds,
  }) async {
    if (tracks.isEmpty) {
      return const [];
    }
    final mergedTracks = await _libraryRepository.getTracksByIds(
      tracks.map((track) => track.id),
    );
    return MediaItemMapper.fromTrackList(
      mergedTracks.isEmpty ? tracks : mergedTracks,
      likedSongIds: likedSongIds,
    );
  }

  int? _toSongSourceId(String trackId) {
    final sourceId = trackId.startsWith('netease:')
        ? trackId.substring('netease:'.length)
        : trackId;
    return int.tryParse(sourceId);
  }
}
