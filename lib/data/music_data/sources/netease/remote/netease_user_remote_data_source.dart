import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_song_detail_batch_planner.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';

/// 网易云用户远程数据源。
class NeteaseUserRemoteDataSource implements UserRemoteDataSource {
  /// 创建网易云用户远程数据源。
  NeteaseUserRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 获取用户资料。
  @override
  Future<UserProfileData> fetchUserDetail(String userId) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (normalizedUserId.isEmpty) {
      return _emptyUserProfile;
    }
    final detail = await _api.userDetail(normalizedUserId);
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
  @override
  Future<List<int>> fetchLikedSongIds(String userId) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (normalizedUserId.isEmpty) {
      return const [];
    }
    final likedList = await _api.likeSongList(normalizedUserId);
    return likedList.ids;
  }

  /// 获取推荐歌单。
  @override
  Future<List<PlaylistEntity>> fetchRecommendedPlaylists({
    required int offset,
    required int limit,
  }) async {
    final wrap = await _api.personalizedPlaylist(offset: offset, limit: limit);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.result ?? const []);
  }

  /// 获取用户歌单。
  @override
  Future<List<PlaylistEntity>> fetchUserPlaylists(String userId) async {
    final normalizedUserId = _normalizedUserId(userId);
    if (normalizedUserId.isEmpty) {
      return const [];
    }
    final wrap = await _api.userPlayLists(normalizedUserId);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.playlists ?? const []);
  }

  /// 获取每日推荐歌曲。
  @override
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
  @override
  Future<List<Track>> fetchFmSongs() async {
    final wrap = await _api.userRadio();
    if (wrap.code != 200) {
      return const [];
    }
    final fmSongs = wrap.data ?? const [];
    return NeteaseTrackMapper.fromSongList(fmSongs);
  }

  /// 获取心动模式歌曲。
  @override
  Future<List<Track>> fetchHeartBeatSongs({
    required String startSongId,
    required String randomLikedSongId,
    required bool fromPlayAll,
  }) async {
    final normalizedStartSongId = normalizeNeteaseSongId(startSongId);
    final normalizedRandomLikedSongId = normalizeNeteaseSongId(randomLikedSongId);
    if (normalizedStartSongId.isEmpty || normalizedRandomLikedSongId.isEmpty) {
      return const [];
    }
    final wrap = await _api.playmodeIntelligenceList(
      normalizedStartSongId,
      normalizedRandomLikedSongId,
      fromPlayAll,
      count: 20,
    );
    if (wrap.code != 200) {
      return const [];
    }

    final songs = (wrap.data ?? const []).map((song) => song.songInfo).whereType<Song2>().toList();
    return NeteaseTrackMapper.fromSong2List(songs);
  }

  /// 按 id 批量获取歌曲。
  @override
  Future<List<Track>> fetchSongsByIds({
    required List<String> ids,
  }) async {
    final tracks = <Track>[];
    for (final batch in planNeteaseSongDetailBatches(ids: ids)) {
      final wrap = await _api.songDetail(batch);
      tracks.addAll(
        NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []),
      );
    }
    return tracks;
  }

  /// 获取歌曲专辑封面地址。
  @override
  Future<String> fetchSongAlbumUrl(String songId) async {
    final normalizedSongId = normalizeNeteaseSongId(songId);
    if (normalizedSongId.isEmpty) {
      return '';
    }
    final songDetailWrap = await _api.songDetail([normalizedSongId]);
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
  @override
  Future<({bool success, String? message})> toggleLikeSong(
    String songId,
    bool like,
  ) async {
    final normalizedSongId = normalizeNeteaseSongId(songId);
    if (normalizedSongId.isEmpty) {
      return (
        success: false,
        message: 'Expected a non-empty netease song id',
      );
    }
    final result = await _api.likeSong(normalizedSongId, like);
    return (
      success: result.code == 200,
      message: result.message,
    );
  }

  /// 退出网易云登录。
  @override
  Future<({bool success, String? message})> logout() async {
    final result = await _api.logout();
    return (
      success: result.code == 200,
      message: result.message,
    );
  }

  String _normalizedUserId(String userId) {
    return userId.trim();
  }

  static const UserProfileData _emptyUserProfile = UserProfileData(
    userId: '',
    nickname: '',
    signature: '',
    follows: 0,
    followeds: 0,
    playlistCount: 0,
    avatarUrl: '',
  );
}
