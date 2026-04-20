import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_media_item_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/user/user_profile_data.dart';

class NeteaseUserRemoteDataSource {
  const NeteaseUserRemoteDataSource();

  Future<UserProfileData> fetchUserDetail(String userId) async {
    final detail = await NeteaseMusicApi().userDetail(userId);
    final profile = detail.profile;
    return UserProfileData(
      userId: profile.userId,
      nickname: profile.nickname ?? '',
      signature: profile.signature ?? '',
      follows: profile.follows ?? 0,
      followeds: profile.followeds ?? 0,
      playlistCount: profile.playlistCount ?? 0,
      avatarUrl: profile.avatarUrl ?? '',
    );
  }

  Future<List<int>> fetchLikedSongIds(String userId) async {
    final likedList = await NeteaseMusicApi().likeSongList(userId);
    return likedList.ids;
  }

  Future<List<PlaylistEntity>> fetchRecommendedPlaylists({
    required int offset,
    required int limit,
  }) async {
    final wrap = await NeteaseMusicApi()
        .personalizedPlaylist(offset: offset, limit: limit);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.result ?? const []);
  }

  Future<List<PlaylistEntity>> fetchUserPlaylists(String userId) async {
    final wrap = await NeteaseMusicApi().userPlayLists(userId);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.playlists ?? const []);
  }

  Future<({List<Track> tracks, List<MediaItem> mediaItems})>
      fetchTodayRecommendSongs({
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().recommendSongList();
    if (wrap.code != 200) {
      return (tracks: <Track>[], mediaItems: <MediaItem>[]);
    }
    final tracks = NeteaseTrackMapper.fromSong2List(
      wrap.data.dailySongs ?? const [],
    );
    return (
      tracks: tracks,
      mediaItems: MediaItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }

  Future<({List<Track> tracks, List<MediaItem> mediaItems})> fetchFmSongs({
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().userRadio();
    if (wrap.code != 200) {
      return (tracks: <Track>[], mediaItems: <MediaItem>[]);
    }
    final fmSongs = wrap.data ?? const [];
    return (
      tracks: NeteaseTrackMapper.fromSongList(fmSongs),
      mediaItems: NeteaseMediaItemMapper.fromFmSongs(
        fmSongs,
        likedSongIds: likedSongIds,
      ),
    );
  }

  Future<({List<Track> tracks, List<MediaItem> mediaItems})> fetchHeartBeatSongs({
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
      return (tracks: <Track>[], mediaItems: <MediaItem>[]);
    }

    final validSongs = (wrap.data ?? [])
        .where((song) => song.songInfo != null && song.songInfo!.id.isNotEmpty)
        .map((song) => song.songInfo!)
        .toList();
    final tracks = NeteaseTrackMapper.fromSong2List(validSongs);
    return (
      tracks: tracks,
      mediaItems: MediaItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }

  Future<({List<Track> tracks, List<MediaItem> mediaItems})> fetchSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final tracks = <Track>[];
    while (tracks.length != ids.length) {
      final wrap = await NeteaseMusicApi().songDetail(
        ids.sublist(tracks.length, min(tracks.length + 1000, ids.length)),
      );
      tracks.addAll(
        NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []),
      );
    }
    return (
      tracks: tracks,
      mediaItems: MediaItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }

  Future<String> fetchSongAlbumUrl(String songId) async {
    final songDetailWrap = await NeteaseMusicApi().songDetail([songId]);
    final songs = songDetailWrap.songs ?? [];
    if (songs.isEmpty) {
      return '';
    }
    final tracks = NeteaseTrackMapper.fromSong2List(songs);
    if (tracks.isEmpty) {
      return '';
    }
    return '${tracks.first.artworkUrl ?? ''}?param=500y500';
  }

  Future<({bool success, String? message})> toggleLikeSong(
    String songId,
    bool like,
  ) async {
    final result = await NeteaseMusicApi().likeSong(songId, like);
    return (
      success: result.code == 200,
      message: result.message,
    );
  }

  Future<({bool success, String? message})> logout() async {
    final result = await NeteaseMusicApi().logout();
    return (
      success: result.code == 200,
      message: result.message,
    );
  }
}
