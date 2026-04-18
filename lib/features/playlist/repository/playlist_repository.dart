import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/common/netease_api/src/api/bean.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';

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
  Future<SinglePlayListWrap> fetchPlaylistWrap(String playlistId) {
    return NeteaseMusicApi().playListDetail(playlistId);
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
      loadedSongCount = songs.length;
    }

    return songs;
  }

  Future<List<MediaItem>?> loadCachedSongs(String playlistId) async {
    final cachedSongs = CacheBox.instance
        .get(_songsCacheKey(playlistId))
        ?.cast<String>();
    if (cachedSongs == null) {
      return null;
    }
    return stringToPlayList(cachedSongs);
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

    await CacheBox.instance.put(
      _songsCacheKey(playlistId),
      await playListToString(remoteSongs),
    );

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

  String _songsCacheKey(String playlistId) => 'PLAYLIST_SONGS_$playlistId';
}
