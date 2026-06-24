import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_artist_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_song_detail_batch_planner.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';

/// 网易云音乐来源门面。
class NeteaseMusicSource {
  /// 创建网易云音乐来源门面。
  NeteaseMusicSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 网易云音乐来源标识。
  String get sourceKey => 'netease';

  /// 搜索网易云曲目。
  Future<List<Track>> searchTracks(String keyword) async {
    final wrap = await _api.searchSong(keyword);
    return NeteaseTrackMapper.fromSongList(wrap.result.songs);
  }

  /// 搜索网易云歌单。
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async {
    final wrap = await _api.searchPlaylist(keyword);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.result.playlists);
  }

  /// 搜索网易云专辑。
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    final wrap = await _api.searchAlbum(keyword);
    return NeteaseAlbumMapper.fromAlbumList(wrap.result.albums ?? const []);
  }

  /// 搜索网易云歌手。
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    final wrap = await _api.searchArtists(keyword);
    return NeteaseArtistMapper.fromArtistList(wrap.result.artists);
  }

  /// 获取网易云曲目。
  Future<Track?> getTrack(String trackId) async {
    final normalizedTrackId = normalizeNeteaseSongId(trackId);
    if (normalizedTrackId.isEmpty) {
      return null;
    }
    final wrap = await _api.songDetail([normalizedTrackId]);
    final songs = wrap.songs;
    final song = songs == null || songs.isEmpty ? null : songs.first;
    if (song == null) {
      return null;
    }
    return NeteaseTrackMapper.fromSong2(song);
  }

  /// 获取网易云播放地址。
  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) async {
    final normalizedTrackId = normalizeNeteaseSongId(trackId);
    if (normalizedTrackId.isEmpty) {
      return null;
    }
    final wrap = await _api.songDownloadUrl(
      [normalizedTrackId],
      level: qualityLevel ?? 'exhigh',
    );
    final data = wrap.data;
    return data == null || data.isEmpty ? null : data.first.url;
  }

  /// 获取网易云歌词。
  Future<TrackLyrics?> getLyrics(String trackId) async {
    final normalizedTrackId = normalizeNeteaseSongId(trackId);
    if (normalizedTrackId.isEmpty) {
      return null;
    }
    final wrap = await _api.songLyric(normalizedTrackId);
    return TrackLyrics(
      main: wrap.lrc?.lyric ?? '',
      translated: wrap.tlyric?.lyric ?? '',
    );
  }

  /// 获取网易云歌单。
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final normalizedPlaylistId = _normalizePlaylistSourceId(playlistId);
    if (normalizedPlaylistId.isEmpty) {
      return null;
    }
    final wrap = await _api.playListDetail(normalizedPlaylistId);
    final playlist = wrap.playlist;
    if (playlist == null) {
      return null;
    }
    return NeteasePlaylistMapper.fromPlaylist(playlist);
  }

  String _normalizePlaylistSourceId(String playlistId) {
    final sourcePlaylistId = MusicResourceId.toNeteaseSourceId(playlistId).trim();
    if (sourcePlaylistId.isEmpty || MusicResourceId.hasKnownPrefix(sourcePlaylistId)) {
      return '';
    }
    return sourcePlaylistId;
  }
}
