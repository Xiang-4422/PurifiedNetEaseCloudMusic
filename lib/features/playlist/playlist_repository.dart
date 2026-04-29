import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/data/netease/netease_playlist_remote_data_source.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/library/library_repository.dart';

import 'playlist_cache_store.dart';

/// PlaylistDetailData。
class PlaylistDetailData {
  /// 创建 PlaylistDetailData。
  const PlaylistDetailData({
    required this.songs,
    required this.isSubscribed,
    required this.isMyPlayList,
  });

  /// songs。
  final List<PlaybackQueueItem> songs;

  /// isSubscribed。
  final bool isSubscribed;

  /// isMyPlayList。
  final bool isMyPlayList;
}

/// PlaylistSnapshotData。
class PlaylistSnapshotData {
  /// 创建 PlaylistSnapshotData。
  const PlaylistSnapshotData({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.creatorUserId,
    this.coverUrl,
    this.trackCount,
  });

  /// id。
  final String id;

  /// name。
  final String name;

  /// trackIds。
  final List<String> trackIds;

  /// creatorUserId。
  final String? creatorUserId;

  /// coverUrl。
  final String? coverUrl;

  /// trackCount。
  final int? trackCount;

  /// 创建 PlaylistSnapshotData。
  factory PlaylistSnapshotData.fromJson(Map<String, dynamic> json) {
    return PlaylistSnapshotData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      trackIds: (json['trackIds'] as List? ?? const [])
          .map((item) => '$item')
          .toList(),
      creatorUserId: json['creatorUserId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      trackCount: json['trackCount'] as int?,
    );
  }

  /// toJson。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trackIds': trackIds,
      'creatorUserId': creatorUserId,
      'coverUrl': coverUrl,
      'trackCount': trackCount,
    };
  }
}

/// PlaylistRepository。
class PlaylistRepository {
  /// 创建 PlaylistRepository。
  PlaylistRepository({
    required PlaylistCacheStore cacheStore,
    required LibraryRepository libraryRepository,
    required LocalLibraryDataSource localLibraryDataSource,
    NeteasePlaylistRemoteDataSource? remoteDataSource,
    required UserScopedDataSource userScopedDataSource,
  })  : _cacheStore = cacheStore,
        _libraryRepository = libraryRepository,
        _localLibraryDataSource = localLibraryDataSource,
        _remoteDataSource =
            remoteDataSource ?? const NeteasePlaylistRemoteDataSource(),
        _userScopedDataSource = userScopedDataSource;

  final PlaylistCacheStore _cacheStore;
  final LibraryRepository _libraryRepository;
  final LocalLibraryDataSource _localLibraryDataSource;
  final NeteasePlaylistRemoteDataSource _remoteDataSource;
  final UserScopedDataSource _userScopedDataSource;

  /// fetchPlaylistSnapshot。
  Future<PlaylistSnapshotData> fetchPlaylistSnapshot(
    String playlistId, {
    String? currentUserId,
  }) async {
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
      creatorUserId: snapshot.creatorUserId,
      coverUrl: snapshot.playlist?.coverUrl,
      trackCount: snapshot.playlist?.trackCount,
    );
    await _cacheStore.saveSnapshot(cachePlaylistId, playlistSnapshot);
    if (currentUserId?.isNotEmpty == true) {
      await _userScopedDataSource.savePlaylistSubscriptionState(
        currentUserId!,
        _toEntityPlaylistId(playlistId),
        snapshot.isSubscribed,
      );
    }
    return playlistSnapshot;
  }

  /// fetchPlaylistSongs。
  Future<List<PlaybackQueueItem>> fetchPlaylistSongs({
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
    final tracks = await _remoteDataSource.fetchPlaylistSongs(
      songIds: songIds,
      offset: offset,
      limit: limit,
    );
    await _libraryRepository.saveTracks(tracks);
    final queueItems = PlaybackQueueItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
    if (queueItems.isNotEmpty) {
      await _cacheStore.touchRefresh(_toCachePlaylistId(playlistId));
    }
    return queueItems;
  }

  /// loadCachedSongs。
  Future<List<PlaybackQueueItem>?> loadCachedSongs(String playlistId) async {
    return _cacheStore.loadSongs(_toCachePlaylistId(playlistId));
  }

  /// loadCachedSnapshot。
  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _cacheStore.loadSnapshot(_toCachePlaylistId(playlistId));
  }

  /// isCacheFresh。
  Future<bool> isCacheFresh(
    String playlistId, {
    required Duration ttl,
  }) {
    return _cacheStore.isFresh(_toCachePlaylistId(playlistId), ttl: ttl);
  }

  /// loadLocalPlaylistDetail。
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
        : (cachedSongs ?? const <PlaybackQueueItem>[]);

    final snapshotAvailable = localPlaylist != null || cachedSnapshot != null;
    if (!snapshotAvailable && songs.isEmpty) {
      return null;
    }

    return PlaylistDetailData(
      songs: songs,
      isSubscribed: await _loadSubscriptionState(
        currentUserId,
        entityPlaylistId,
      ),
      isMyPlayList: (cachedSnapshot?.creatorUserId ?? '') == currentUserId,
    );
  }

  /// fetchPlaylistDetail。
  Future<PlaylistDetailData> fetchPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    final cachePlaylistId = _toCachePlaylistId(playlistId);
    final entityPlaylistId = _toEntityPlaylistId(playlistId);
    final details = await fetchPlaylistSnapshot(
      playlistId,
      currentUserId: currentUserId,
    );
    final remoteSongs = await fetchPlaylistSongs(
      playlistId: playlistId,
      likedSongIds: likedSongIds,
      playlistSnapshot: details,
    );

    if (remoteSongs.isEmpty) {
      return PlaylistDetailData(
        songs: const [],
        isSubscribed: await _loadSubscriptionState(
          currentUserId,
          entityPlaylistId,
        ),
        isMyPlayList: details.creatorUserId == currentUserId,
      );
    }

    await _cacheStore.saveSongs(cachePlaylistId, remoteSongs);

    return PlaylistDetailData(
      songs: remoteSongs,
      isSubscribed: await _loadSubscriptionState(
        currentUserId,
        entityPlaylistId,
      ),
      isMyPlayList: details.creatorUserId == currentUserId,
    );
  }

  Future<List<PlaybackQueueItem>> _loadLocalSongs(
    List<String> trackIds, {
    required List<int> likedSongIds,
  }) async {
    if (trackIds.isEmpty) {
      return const [];
    }
    final tracks = await _libraryRepository.getTracksWithResources(trackIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = <String, TrackWithResources>{
      for (final track in tracks) track.track.id: track,
    };
    final orderedTracks = trackIds
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

  /// toggleSubscription。
  Future<OperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
    String? currentUserId,
  }) async {
    final result = await _remoteDataSource.toggleSubscription(
      playlistId,
      subscribe: subscribe,
    );
    if (result.success && currentUserId?.isNotEmpty == true) {
      await _userScopedDataSource.savePlaylistSubscriptionState(
        currentUserId!,
        _toEntityPlaylistId(playlistId),
        subscribe,
      );
    }
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  /// manipulateTracks。
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
    if (result.success) {
      final entityPlaylistId = _toEntityPlaylistId(playlistId);
      final cachePlaylistId = _toCachePlaylistId(playlistId);
      await _cacheStore.invalidate(cachePlaylistId);
      await _localLibraryDataSource.clearPlaylistTrackRefs(entityPlaylistId);
    }
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

  Future<bool> _loadSubscriptionState(
    String? currentUserId,
    String playlistId,
  ) async {
    if (currentUserId?.isNotEmpty != true) {
      return false;
    }
    return await _userScopedDataSource.loadPlaylistSubscriptionState(
          currentUserId!,
          playlistId,
        ) ??
        false;
  }
}
