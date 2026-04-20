import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
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
  })  : _cacheStore = cacheStore ?? const PlaylistCacheStore(),
        _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final PlaylistCacheStore _cacheStore;
  final LibraryRepository _libraryRepository;

  Future<PlaylistSnapshotData> fetchPlaylistSnapshot(String playlistId) async {
    final wrap = await NeteaseMusicApi().playListDetail(playlistId);
    final playlist = wrap.playlist;
    if (playlist != null) {
      await _libraryRepository.savePlaylists(
        [NeteasePlaylistMapper.fromPlaylist(playlist)],
      );
    }
    return PlaylistSnapshotData(
      id: playlistId,
      name: playlist?.name ?? '无名歌单',
      trackIds: playlist?.trackIds?.map((track) => track.id).toList() ?? const [],
      isSubscribed: playlist?.subscribed ?? false,
      creatorUserId: playlist?.creator?.userId,
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

    final targetIds = songIds.sublist(offset);
    final fetchCount =
        limit == -1 || targetIds.length < limit ? targetIds.length : limit;
    final resolvedIds = targetIds.take(fetchCount).toList();

    final songs = <MediaItem>[];
    var loadedSongCount = 0;
    while (loadedSongCount < resolvedIds.length) {
      final wrap = await NeteaseMusicApi().songDetail(
        resolvedIds.sublist(
          loadedSongCount,
          min(loadedSongCount + 1000, resolvedIds.length),
        ),
      );
      final tracks = NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []);
      songs.addAll(
        MediaItemMapper.fromTrackList(
          tracks,
          likedSongIds: likedSongIds,
        ),
      );
      await _libraryRepository.saveTracks(tracks);
      loadedSongCount = songs.length;
    }

    return songs;
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
    final result = await NeteaseMusicApi()
        .subscribePlayList(playlistId, subscribe: subscribe);
    return OperationResult(
      success: result.code == 200,
      message: result.message,
    );
  }

  Future<OperationResult> manipulateTracks(
    String playlistId,
    String songId, {
    required bool add,
  }) async {
    final result =
        await NeteaseMusicApi().playlistManipulateTracks(playlistId, songId, add);
    return OperationResult(
      success: result.code == 200,
      message: result.message,
    );
  }
}
