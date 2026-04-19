import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/api/src/api/bean.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:get_it/get_it.dart';

class UserRepository {
  UserRepository({LibraryRepository? libraryRepository})
      : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<NeteaseUserDetail> fetchUserDetail(String userId) {
    return NeteaseMusicApi().userDetail(userId);
  }

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
    final playlists = wrap.result ?? [];
    await _libraryRepository.savePlaylists(
      NeteasePlaylistMapper.fromPlaylistList(playlists),
    );
    return playlists;
  }

  Future<List<PlayList>> fetchUserPlaylists(String userId) async {
    final wrap = await NeteaseMusicApi().userPlayLists(userId);
    final playlists = wrap.playlists ?? [];
    await _libraryRepository.savePlaylists(
      NeteasePlaylistMapper.fromPlaylistList(playlists),
    );
    return playlists;
  }

  Future<List<MediaItem>> fetchTodayRecommendSongs({
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().recommendSongList();
    if (wrap.code != 200) {
      return const [];
    }
    final tracks = NeteaseTrackMapper.fromSong2List(
      wrap.data.dailySongs ?? const [],
    );
    await _libraryRepository.saveTracks(tracks);
    return MediaItemMapper.fromTrackList(
      tracks,
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
    await _libraryRepository.saveTracks(
      NeteaseTrackMapper.fromSongList(wrap.data ?? const []),
    );

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
    final tracks = NeteaseTrackMapper.fromSong2List(validSongs);
    await _libraryRepository.saveTracks(tracks);
    return MediaItemMapper.fromTrackList(
      tracks,
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

  Future<String> fetchSongAlbumUrl(String songId) async {
    final songDetailWrap = await NeteaseMusicApi().songDetail([songId]);
    final songs = songDetailWrap.songs ?? [];
    if (songs.isEmpty) {
      return '';
    }
    final tracks = NeteaseTrackMapper.fromSong2List(songs);
    await _libraryRepository.saveTracks(tracks);
    if (tracks.isEmpty) {
      return '';
    }
    return '${tracks.first.artworkUrl ?? ''}?param=500y500';
  }

  Future<ServerStatusBean> toggleLikeSong(String songId, bool like) {
    return NeteaseMusicApi().likeSong(songId, like);
  }

  Future<ServerStatusBean> logout() {
    return NeteaseMusicApi().logout();
  }
}
