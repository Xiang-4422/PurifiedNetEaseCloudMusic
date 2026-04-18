import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/src/api/bean.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';

class UserRepository {
  Future<List<int>> fetchLikedSongIds(String userId) async {
    final likedList = await NeteaseMusicApi().likeSongList(userId);
    return likedList.ids;
  }

  Future<List<PlayList>> fetchRecommendedPlaylists({
    required int offset,
    int limit = 10,
  }) async {
    final wrap = await NeteaseMusicApi()
        .personalizedPlaylist(offset: offset, limit: limit);
    return wrap.result ?? [];
  }

  Future<List<PlayList>> fetchUserPlaylists(String userId) async {
    final wrap = await NeteaseMusicApi().userPlayLists(userId);
    return wrap.playlists ?? [];
  }

  Future<List<MediaItem>> fetchTodayRecommendSongs({
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().recommendSongList();
    if (wrap.code != 200) {
      return const [];
    }
    return MediaItemMapper.fromSong2List(
      wrap.data.dailySongs ?? const [],
      likedSongIds: likedSongIds,
    );
  }

  Future<List<MediaItem>> fetchFmSongs({
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().userRadio();
    if (wrap.code != 200) {
      return const [];
    }

    return (wrap.data ?? [])
        .map((song) => MediaItem(
              id: song.id,
              duration: Duration(milliseconds: song.duration ?? 0),
              artUri: Uri.parse('${song.album?.picUrl ?? ''}?param=200y200'),
              extras: {
                'image': song.album?.picUrl ?? '',
                'liked': likedSongIds.contains(int.tryParse(song.id)),
                'artist': (song.artists ?? [])
                    .map((artist) => jsonEncode(artist.toJson()))
                    .toList()
                    .join(' / '),
                'albumId': song.album?.id ?? '',
                'type': MediaType.fm.name,
                'size': '',
              },
              title: song.name ?? '',
              album: song.album?.name ?? '',
              artist:
                  (song.artists ?? []).map((artist) => artist.name).join(' / '),
            ))
        .toList();
  }

  Future<List<MediaItem>> fetchHeartBeatSongs({
    required String startSongId,
    required String randomLikedSongId,
    required bool fromPlayAll,
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().playmodeIntelligenceList(
      startSongId,
      randomLikedSongId,
      fromPlayAll,
      count: 20,
    );
    if (wrap.code != 200) {
      return const [];
    }

    final validSongs = (wrap.data ?? [])
        .where((song) => song.songInfo != null && song.songInfo!.id.isNotEmpty)
        .map((song) => song.songInfo!)
        .toList();
    return MediaItemMapper.fromSong2List(
      validSongs,
      likedSongIds: likedSongIds,
    );
  }

  Future<List<MediaItem>> fetchSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final songs = <MediaItem>[];
    var loadedSongCount = 0;
    while (loadedSongCount != ids.length) {
      final wrap = await NeteaseMusicApi().songDetail(
        ids.sublist(loadedSongCount, min(loadedSongCount + 1000, ids.length)),
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

  Future<String> fetchSongAlbumUrl(String songId) async {
    final songDetailWrap = await NeteaseMusicApi().songDetail([songId]);
    final songs = songDetailWrap.songs ?? [];
    if (songs.isEmpty) {
      return '';
    }

    final mediaItems = MediaItemMapper.fromSong2List(
      songs,
      likedSongIds: const [],
    );
    if (mediaItems.isEmpty) {
      return '';
    }
    return '${mediaItems.first.extras?['image'] ?? ''}?param=500y500';
  }

  Future<ServerStatusBean> toggleLikeSong(String songId, bool like) {
    return NeteaseMusicApi().likeSong(songId, like);
  }

  Future<ServerStatusBean> logout() {
    return NeteaseMusicApi().logout();
  }
}
