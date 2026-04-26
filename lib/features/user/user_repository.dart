import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/netease_user_remote_data_source.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
import 'package:bujuan/features/user/user_profile_cache_store.dart';
import 'package:bujuan/features/user/user_profile_data.dart';
import 'package:get_it/get_it.dart';

class UserRepository {
  UserRepository({
    LibraryRepository? libraryRepository,
    NeteaseUserRemoteDataSource? remoteDataSource,
    UserProfileCacheStore? profileCacheStore,
  })  : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _remoteDataSource =
            remoteDataSource ?? const NeteaseUserRemoteDataSource(),
        _profileCacheStore = profileCacheStore ?? const UserProfileCacheStore();

  final LibraryRepository _libraryRepository;
  final NeteaseUserRemoteDataSource _remoteDataSource;
  final UserProfileCacheStore _profileCacheStore;

  Future<UserProfileData?> loadCachedUserDetail(String userId) {
    return _profileCacheStore.loadProfile(userId);
  }

  Future<UserProfileData> fetchUserDetail(String userId) async {
    final profile = await _remoteDataSource.fetchUserDetail(userId);
    await _profileCacheStore.saveProfile(profile);
    return profile;
  }

  Future<List<int>> fetchLikedSongIds(String userId) async {
    return _remoteDataSource.fetchLikedSongIds(userId);
  }

  Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists({
    required int offset,
    int limit = 10,
  }) async {
    final playlists = await _remoteDataSource.fetchRecommendedPlaylists(
      offset: offset,
      limit: limit,
    );
    await _libraryRepository.savePlaylists(playlists);
    return playlists.map(PlaylistSummaryData.fromEntity).toList();
  }

  Future<List<PlaylistSummaryData>> fetchUserPlaylists(String userId) async {
    final playlists = await _remoteDataSource.fetchUserPlaylists(userId);
    await _libraryRepository.savePlaylists(playlists);
    return playlists.map(PlaylistSummaryData.fromEntity).toList();
  }

  Future<List<MediaItem>> fetchTodayRecommendSongs({
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchTodayRecommendSongs(
      likedSongIds: likedSongIds,
    );
    final tracks = result.tracks;
    await _libraryRepository.saveTracks(tracks);
    return _mediaItemsFromSavedTracks(tracks, likedSongIds: likedSongIds);
  }

  Future<List<MediaItem>> fetchFmSongs({
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchFmSongs(
      likedSongIds: likedSongIds,
    );
    await _libraryRepository.saveTracks(result.tracks);
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

  Future<OperationResult> toggleLikeSong(String songId, bool like) async {
    final result = await _remoteDataSource.toggleLikeSong(songId, like);
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

  Future<void> clearCachedProfiles() {
    return _profileCacheStore.clearAllProfiles();
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
}
