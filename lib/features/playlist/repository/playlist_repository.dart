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
    final details = await NeteaseMusicApi().playListDetail(playlistId);
    final ids =
        details.playlist?.trackIds?.map((track) => track.id).toList() ?? [];

    if (ids.isEmpty) {
      return PlaylistDetailData(
        songs: const [],
        isSubscribed: details.playlist?.subscribed ?? false,
        isMyPlayList: details.playlist?.creator?.userId == currentUserId,
      );
    }

    final remoteSongs = <MediaItem>[];
    var loadedSongCount = 0;
    while (loadedSongCount < ids.length) {
      final wrap = await NeteaseMusicApi().songDetail(
        ids.sublist(loadedSongCount, min(loadedSongCount + 1000, ids.length)),
      );
      remoteSongs.addAll(
        MediaItemMapper.fromSong2List(
          wrap.songs ?? const [],
          likedSongIds: likedSongIds,
        ),
      );
      loadedSongCount = remoteSongs.length;
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

  String _songsCacheKey(String playlistId) => 'PLAYLIST_SONGS_$playlistId';
}
