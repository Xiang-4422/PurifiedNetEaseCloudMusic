import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/data/netease/netease_playlist_remote_data_source.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:get_it/get_it.dart';

import 'playlist_cache_store.dart';

class PlaylistDetailData {
  const PlaylistDetailData({
    required this.songs,
    required this.isSubscribed,
    required this.isMyPlayList,
  });

  final List<MediaItem> songs;
  final bool isSubscribed;
  final bool isMyPlayList;
}

class PlaylistSnapshotData {
  const PlaylistSnapshotData({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.isSubscribed,
    required this.creatorUserId,
  });

  final String id;
  final String name;
  final List<String> trackIds;
  final bool isSubscribed;
  final String? creatorUserId;
}

class PlaylistRepository {
  PlaylistRepository({
    PlaylistCacheStore? cacheStore,
    LibraryRepository? libraryRepository,
    NeteasePlaylistRemoteDataSource? remoteDataSource,
  })  : _cacheStore = cacheStore ?? const PlaylistCacheStore(),
        _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _remoteDataSource =
            remoteDataSource ?? const NeteasePlaylistRemoteDataSource();

  final PlaylistCacheStore _cacheStore;
  final LibraryRepository _libraryRepository;
  final NeteasePlaylistRemoteDataSource _remoteDataSource;

  Future<PlaylistSnapshotData> fetchPlaylistSnapshot(String playlistId) async {
    final snapshot = await _remoteDataSource.fetchPlaylistSnapshot(playlistId);
    if (snapshot.playlist != null) {
      await _libraryRepository.savePlaylists([snapshot.playlist!]);
    }
    return PlaylistSnapshotData(
      id: playlistId,
      name: snapshot.name,
      trackIds: snapshot.trackIds,
      isSubscribed: snapshot.isSubscribed,
      creatorUserId: snapshot.creatorUserId,
    );
  }

  Future<List<MediaItem>> fetchPlaylistSongs({
    required String playlistId,
    required List<int> likedSongIds,
    int offset = 0,
    int limit = -1,
    PlaylistSnapshotData? playlistSnapshot,
  }) async {
    playlistSnapshot ??= await fetchPlaylistSnapshot(playlistId);
    final songIds = playlistSnapshot.trackIds;
    if (offset >= songIds.length) {
      return const [];
    }
    final result = await _remoteDataSource.fetchPlaylistSongs(
      songIds: songIds,
      offset: offset,
      limit: limit,
      likedSongIds: likedSongIds,
    );
    await _libraryRepository.saveTracks(result.tracks);
    return result.mediaItems;
  }

  Future<List<MediaItem>?> loadCachedSongs(String playlistId) async {
    return _cacheStore.loadSongs(playlistId);
  }

  Future<PlaylistDetailData> fetchPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    final details = await fetchPlaylistSnapshot(playlistId);
    final remoteSongs = await fetchPlaylistSongs(
      playlistId: playlistId,
      likedSongIds: likedSongIds,
      playlistSnapshot: details,
    );

    if (remoteSongs.isEmpty) {
      return PlaylistDetailData(
        songs: const [],
        isSubscribed: details.isSubscribed,
        isMyPlayList: details.creatorUserId == currentUserId,
      );
    }

    await _cacheStore.saveSongs(playlistId, remoteSongs);

    return PlaylistDetailData(
      songs: remoteSongs,
      isSubscribed: details.isSubscribed,
      isMyPlayList: details.creatorUserId == currentUserId,
    );
  }

  Future<OperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) async {
    final result = await _remoteDataSource.toggleSubscription(
      playlistId,
      subscribe: subscribe,
    );
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  Future<OperationResult> manipulateTracks(
    String playlistId,
    String songId, {
    required bool add,
  }) async {
    final result = await _remoteDataSource.manipulateTracks(
      playlistId,
      songId,
      add: add,
    );
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }
}
