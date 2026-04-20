import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/netease_playlist_remote_data_source.dart';
import 'package:bujuan/domain/entities/track.dart';
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
    this.coverUrl,
    this.trackCount,
  });

  final String id;
  final String name;
  final List<String> trackIds;
  final bool isSubscribed;
  final String? creatorUserId;
  final String? coverUrl;
  final int? trackCount;

  factory PlaylistSnapshotData.fromJson(Map<String, dynamic> json) {
    return PlaylistSnapshotData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      trackIds: (json['trackIds'] as List? ?? const [])
          .map((item) => '$item')
          .toList(),
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      creatorUserId: json['creatorUserId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      trackCount: json['trackCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trackIds': trackIds,
      'isSubscribed': isSubscribed,
      'creatorUserId': creatorUserId,
      'coverUrl': coverUrl,
      'trackCount': trackCount,
    };
  }
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
    final playlistSnapshot = PlaylistSnapshotData(
      id: playlistId,
      name: snapshot.name,
      trackIds: snapshot.trackIds,
      isSubscribed: snapshot.isSubscribed,
      creatorUserId: snapshot.creatorUserId,
      coverUrl: snapshot.playlist?.coverUrl,
      trackCount: snapshot.playlist?.trackCount,
    );
    await _cacheStore.saveSnapshot(playlistId, playlistSnapshot);
    return playlistSnapshot;
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

  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _cacheStore.loadSnapshot(playlistId);
  }

  Future<PlaylistDetailData?> loadLocalPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    final localPlaylist = await _libraryRepository.getPlaylist(playlistId);
    final cachedSnapshot = await _cacheStore.loadSnapshot(playlistId);

    final trackIds =
        localPlaylist?.trackRefs.map((item) => item.trackId).toList() ??
            cachedSnapshot?.trackIds ??
            const <String>[];
    final localSongs =
        await _loadLocalSongs(trackIds, likedSongIds: likedSongIds);
    final cachedSongs =
        localSongs.isEmpty ? await _cacheStore.loadSongs(playlistId) : null;
    final songs = localSongs.isNotEmpty
        ? localSongs
        : (cachedSongs ?? const <MediaItem>[]);

    final snapshotAvailable = localPlaylist != null || cachedSnapshot != null;
    if (!snapshotAvailable && songs.isEmpty) {
      return null;
    }

    return PlaylistDetailData(
      songs: songs,
      isSubscribed: cachedSnapshot?.isSubscribed ?? false,
      isMyPlayList: (cachedSnapshot?.creatorUserId ?? '') == currentUserId,
    );
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

  Future<List<MediaItem>> _loadLocalSongs(
    List<String> trackIds, {
    required List<int> likedSongIds,
  }) async {
    if (trackIds.isEmpty) {
      return const [];
    }
    final tracks = await _libraryRepository.getTracksByIds(trackIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = <String, Track>{
      for (final track in tracks) track.id: track,
    };
    final orderedTracks = trackIds
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
