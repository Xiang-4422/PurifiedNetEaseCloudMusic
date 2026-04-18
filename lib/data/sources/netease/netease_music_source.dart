import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/data/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/sources/music_source.dart';

class NeteaseMusicSource implements MusicSource {
  NeteaseMusicSource({NeteaseMusicApi? api}) : _api = api ?? NeteaseMusicApi();

  final NeteaseMusicApi _api;

  @override
  String get sourceKey => 'netease';

  @override
  Future<List<Track>> searchTracks(String keyword) async {
    final wrap = await _api.searchSong(keyword);
    return NeteaseTrackMapper.fromSongList(wrap.result.songs);
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    final wrap = await _api.songDetail([_normalizeTrackId(trackId)]);
    final songs = wrap.songs;
    final song = songs == null || songs.isEmpty ? null : songs.first;
    if (song == null) {
      return null;
    }
    return NeteaseTrackMapper.fromSong2(song);
  }

  @override
  Future<String?> getPlaybackUrl(String trackId) async {
    final wrap = await _api.songUrl([_normalizeTrackId(trackId)]);
    final data = wrap.data;
    return data == null || data.isEmpty ? null : data.first.url;
  }

  @override
  Future<String?> getLyric(String trackId) async {
    final wrap = await _api.songLyric(_normalizeTrackId(trackId));
    return wrap.lrc.lyric;
  }

  @override
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
