import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

/// 本地音乐来源门面。
class LocalMusicSource {
  /// 创建本地音乐来源门面。
  LocalMusicSource({required LocalLibraryDataSource localDataSource})
      : _localDataSource = localDataSource;

  final LocalLibraryDataSource _localDataSource;

  /// 本地音乐来源标识。
  String get sourceKey => 'local';

  /// 搜索本地曲目。
  Future<List<Track>> searchTracks(String keyword) {
    return _localDataSource.searchTracks(keyword);
  }

  /// 搜索本地歌单。
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) {
    return _localDataSource.searchPlaylists(keyword);
  }

  /// 搜索本地专辑。
  Future<List<AlbumEntity>> searchAlbums(String keyword) {
    return _localDataSource.searchAlbums(keyword);
  }

  /// 搜索本地歌手。
  Future<List<ArtistEntity>> searchArtists(String keyword) {
    return _localDataSource.searchArtists(keyword);
  }

  /// 获取本地曲目。
  Future<Track?> getTrack(String trackId) {
    return _localDataSource.getTrack(trackId);
  }

  /// 获取本地播放地址。
  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) async {
    final track = await _localDataSource.getTrack(trackId);
    return track?.sourceId;
  }

  /// 获取本地歌词。
  Future<TrackLyrics?> getLyrics(String trackId) {
    return _localDataSource.getLyrics(trackId);
  }

  /// 获取本地歌单。
  Future<PlaylistEntity?> getPlaylist(String playlistId) {
    return _localDataSource.getPlaylist(playlistId);
  }
}
