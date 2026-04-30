import 'dart:math';

import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';

/// 网易云用户远程数据源。
class NeteaseUserRemoteDataSource {
  /// 创建网易云用户远程数据源。
  NeteaseUserRemoteDataSource({NeteaseMusicApi? api})
      : _api = api ?? NeteaseMusicApi();

  final NeteaseMusicApi _api;

  /// 获取用户资料。
  Future<UserProfileData> fetchUserDetail(String userId) async {
    final detail = await _api.userDetail(userId);
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

  /// 获取用户喜欢歌曲 id 列表。
  Future<List<int>> fetchLikedSongIds(String userId) async {
    final likedList = await _api.likeSongList(userId);
    return likedList.ids;
  }

  /// 获取推荐歌单。
  Future<List<PlaylistEntity>> fetchRecommendedPlaylists({
    required int offset,
    required int limit,
  }) async {
    final wrap = await _api.personalizedPlaylist(offset: offset, limit: limit);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.result ?? const []);
  }

  /// 获取用户歌单。
  Future<List<PlaylistEntity>> fetchUserPlaylists(String userId) async {
    final wrap = await _api.userPlayLists(userId);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.playlists ?? const []);
  }

  /// 获取每日推荐歌曲。
  Future<List<Track>> fetchTodayRecommendSongs() async {
    final wrap = await _api.recommendSongList();
    if (wrap.code != 200) {
      return const [];
    }
    return NeteaseTrackMapper.fromSong2List(
      wrap.data.dailySongs ?? const [],
    );
  }

  /// 获取私人 FM 歌曲。
  Future<List<Track>> fetchFmSongs() async {
    final wrap = await _api.userRadio();
    if (wrap.code != 200) {
      return const [];
    }
    final fmSongs = wrap.data ?? const [];
    return NeteaseTrackMapper.fromSongList(fmSongs);
  }

  /// 获取心动模式歌曲。
  Future<List<Track>> fetchHeartBeatSongs({
    required String startSongId,
    required String randomLikedSongId,
    required bool fromPlayAll,
  }) async {
    final wrap = await _api.playmodeIntelligenceList(
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
    return NeteaseTrackMapper.fromSong2List(validSongs);
  }

  /// 按 id 批量获取歌曲。
  Future<List<Track>> fetchSongsByIds({
    required List<String> ids,
  }) async {
    final tracks = <Track>[];
    while (tracks.length != ids.length) {
      final wrap = await _api.songDetail(
        ids.sublist(tracks.length, min(tracks.length + 1000, ids.length)),
      );
      tracks.addAll(
        NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []),
      );
    }
    return tracks;
  }

  /// 获取歌曲专辑封面地址。
  Future<String> fetchSongAlbumUrl(String songId) async {
    final songDetailWrap = await _api.songDetail([songId]);
    final songs = songDetailWrap.songs ?? [];
    if (songs.isEmpty) {
      return '';
    }
    final tracks = NeteaseTrackMapper.fromSong2List(songs);
    if (tracks.isEmpty) {
      return '';
    }
    return ImageUrlNormalizer.normalize(tracks.first.artworkUrl);
  }

  /// 切换歌曲喜欢状态。
  Future<({bool success, String? message})> toggleLikeSong(
    String songId,
    bool like,
  ) async {
    final result = await _api.likeSong(songId, like);
    return (
      success: result.code == 200,
      message: result.message,
    );
  }

  /// 退出网易云登录。
  Future<({bool success, String? message})> logout() async {
    final result = await _api.logout();
    return (
      success: result.code == 200,
      message: result.message,
    );
  }
}
