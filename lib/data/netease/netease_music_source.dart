import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_artist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

class NeteaseMusicSource {
  NeteaseMusicSource({NeteaseMusicApi? api}) : _api = api ?? NeteaseMusicApi();

  final NeteaseMusicApi _api;

  String get sourceKey => 'netease';

  Future<List<Track>> searchTracks(String keyword) async {
    final wrap = await _api.searchSong(keyword);
    return NeteaseTrackMapper.fromSongList(wrap.result.songs);
  }

  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async {
    final wrap = await _api.searchPlaylist(keyword);
    return NeteasePlaylistMapper.fromPlaylistList(wrap.result.playlists);
  }

  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    final wrap = await _api.searchAlbum(keyword);
    return NeteaseAlbumMapper.fromAlbumList(wrap.result.albums ?? const []);
  }

  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    final wrap = await _api.searchArtists(keyword);
    return NeteaseArtistMapper.fromArtistList(wrap.result.artists);
  }

  Future<Track?> getTrack(String trackId) async {
    final wrap = await _api.songDetail([_normalizeTrackId(trackId)]);
    final songs = wrap.songs;
    final song = songs == null || songs.isEmpty ? null : songs.first;
    if (song == null) {
      return null;
    }
    return NeteaseTrackMapper.fromSong2(song);
  }

  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) async {
    final wrap = await _api.songDownloadUrl(
      [_normalizeTrackId(trackId)],
      level: qualityLevel ?? 'exhigh',
    );
    final data = wrap.data;
    return data == null || data.isEmpty ? null : data.first.url;
  }

  Future<TrackLyrics?> getLyrics(String trackId) async {
    final wrap = await _api.songLyric(_normalizeTrackId(trackId));
    return TrackLyrics(
      main: wrap.lrc.lyric ?? '',
      translated: wrap.tlyric.lyric ?? '',
    );
  }

  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final wrap = await _api.playListDetail(_normalizePlaylistId(playlistId));
    final playlist = wrap.playlist;
    if (playlist == null) {
      return null;
    }
    return NeteasePlaylistMapper.fromPlaylist(playlist);
  }

  String _normalizeTrackId(String trackId) {
    return trackId.startsWith('netease:')
        ? trackId.substring('netease:'.length)
        : trackId;
  }

  String _normalizePlaylistId(String playlistId) {
    return playlistId.startsWith('netease:')
        ? playlistId.substring('netease:'.length)
        : playlistId;
  }
}
