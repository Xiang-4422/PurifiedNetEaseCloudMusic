import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/common/netease_api/src/api/bean.dart';
import 'package:bujuan/data/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/mappers/netease_track_mapper.dart';
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

  Future<SinglePlayListWrap> fetchPlaylistWrap(String playlistId) async {
    final wrap = await NeteaseMusicApi().playListDetail(playlistId);
    final playlist = wrap.playlist;
    if (playlist != null) {
      await _libraryRepository.savePlaylists(
        [NeteasePlaylistMapper.fromPlaylist(playlist)],
      );
    }
    return wrap;
  }

  Future<List<MediaItem>> fetchPlaylistSongs({
    required String playlistId,
    required List<int> likedSongIds,
    int offset = 0,
    int limit = -1,
    SinglePlayListWrap? playlistWrap,
  }) async {
    playlistWrap ??= await fetchPlaylistWrap(playlistId);
    final songIds =
        playlistWrap.playlist?.trackIds?.map((track) => track.id).toList() ??
            [];

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
      songs.addAll(
        MediaItemMapper.fromSong2List(
          wrap.songs ?? const [],
          likedSongIds: likedSongIds,
        ),
      );
      await _libraryRepository.saveTracks(
        NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []),
      );
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
    final details = await fetchPlaylistWrap(playlistId);
    final remoteSongs = await fetchPlaylistSongs(
      playlistId: playlistId,
      likedSongIds: likedSongIds,
      playlistWrap: details,
    );

    if (remoteSongs.isEmpty) {
      return PlaylistDetailData(
        songs: const [],
        isSubscribed: details.playlist?.subscribed ?? false,
        isMyPlayList: details.playlist?.creator?.userId == currentUserId,
      );
    }

    await _cacheStore.saveSongs(playlistId, remoteSongs);

    return PlaylistDetailData(
      songs: remoteSongs,
      isSubscribed: details.playlist?.subscribed ?? false,
      isMyPlayList: details.playlist?.creator?.userId == currentUserId,
    );
  }

  Future<ServerStatusBean> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) {
    return NeteaseMusicApi()
        .subscribePlayList(playlistId, subscribe: subscribe);
  }

  Future<ServerStatusBean> manipulateTracks(
    String playlistId,
    String songId, {
    required bool add,
  }) {
    return NeteaseMusicApi().playlistManipulateTracks(playlistId, songId, add);
  }
}
