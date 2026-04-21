import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/netease_playlist_remote_data_source.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
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
    final sourcePlaylistId = _toSourcePlaylistId(playlistId);
    final cachePlaylistId = _toCachePlaylistId(playlistId);
    final snapshot = await _remoteDataSource.fetchPlaylistSnapshot(
      sourcePlaylistId,
    );
    final trackIds =
        (snapshot.playlist?.trackRefs ?? const <PlaylistTrackRef>[])
            .map((item) => item.trackId)
            .toList();
    if (trackIds.isEmpty && snapshot.trackIds.isNotEmpty) {
      trackIds.addAll(
        snapshot.trackIds.map(
          (id) => id.startsWith('netease:') ? id : 'netease:$id',
        ),
      );
    }
    if (snapshot.playlist != null) {
      await _libraryRepository.savePlaylists([snapshot.playlist!]);
    }
    final playlistSnapshot = PlaylistSnapshotData(
      id: cachePlaylistId,
      name: snapshot.name,
      trackIds: trackIds,
      isSubscribed: snapshot.isSubscribed,
      creatorUserId: snapshot.creatorUserId,
      coverUrl: snapshot.playlist?.coverUrl,
      trackCount: snapshot.playlist?.trackCount,
    );
    await _cacheStore.saveSnapshot(cachePlaylistId, playlistSnapshot);
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
    final songIds = playlistSnapshot.trackIds
        .map(_toSourceTrackId)
        .where((id) => id.isNotEmpty)
        .toList();
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
    if (result.mediaItems.isNotEmpty) {
      await _cacheStore.touchRefresh(_toCachePlaylistId(playlistId));
    }
    return result.mediaItems;
  }

  Future<List<MediaItem>?> loadCachedSongs(String playlistId) async {
    return _cacheStore.loadSongs(_toCachePlaylistId(playlistId));
  }

  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _cacheStore.loadSnapshot(_toCachePlaylistId(playlistId));
  }

  bool isCacheFresh(
    String playlistId, {
    required Duration ttl,
  }) {
    return _cacheStore.isFresh(_toCachePlaylistId(playlistId), ttl: ttl);
  }

  Future<PlaylistDetailData?> loadLocalPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    final entityPlaylistId = _toEntityPlaylistId(playlistId);
    final cachePlaylistId = _toCachePlaylistId(playlistId);
    final localPlaylist =
        await _libraryRepository.getPlaylist(entityPlaylistId);
    final cachedSnapshot = await _cacheStore.loadSnapshot(cachePlaylistId);

    final trackIds =
        localPlaylist?.trackRefs.map((item) => item.trackId).toList() ??
            cachedSnapshot?.trackIds ??
            const <String>[];
    final localSongs =
        await _loadLocalSongs(trackIds, likedSongIds: likedSongIds);
    final cachedSongs = localSongs.isEmpty
        ? await _cacheStore.loadSongs(cachePlaylistId)
        : null;
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
    final cachePlaylistId = _toCachePlaylistId(playlistId);
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

    await _cacheStore.saveSongs(cachePlaylistId, remoteSongs);

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

  String _toEntityPlaylistId(String playlistId) {
    if (playlistId.startsWith('netease:') || playlistId.startsWith('local:')) {
      return playlistId;
    }
    return 'netease:$playlistId';
  }

  String _toSourcePlaylistId(String playlistId) {
    if (playlistId.startsWith('netease:')) {
      return playlistId.substring('netease:'.length);
    }
    return playlistId;
  }

  String _toCachePlaylistId(String playlistId) {
    return _toSourcePlaylistId(playlistId);
  }

  String _toSourceTrackId(String trackId) {
    if (trackId.startsWith('netease:')) {
      return trackId.substring('netease:'.length);
    }
    return trackId;
  }
}
