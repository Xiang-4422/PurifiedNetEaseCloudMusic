import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

/// 本地曲库数据源。
abstract class LocalLibraryDataSource {
  /// 搜索本地曲目。
  Future<List<Track>> searchTracks(String keyword);

  /// 搜索本地歌单。
  Future<List<PlaylistEntity>> searchPlaylists(String keyword);

  /// 搜索本地专辑。
  Future<List<AlbumEntity>> searchAlbums(String keyword);

  /// 搜索本地歌手。
  Future<List<ArtistEntity>> searchArtists(String keyword);

  /// 获取单首曲目。
  Future<Track?> getTrack(String trackId);

  /// 按 id 批量获取曲目。
  Future<List<Track>> getTracksByIds(Iterable<String> trackIds);

  /// 获取曲目歌词。
  Future<TrackLyrics?> getLyrics(String trackId);

  /// 获取歌单。
  Future<PlaylistEntity?> getPlaylist(String playlistId);

  /// 获取专辑。
  Future<AlbumEntity?> getAlbum(String albumId);

  /// 获取歌手。
  Future<ArtistEntity?> getArtist(String artistId);

  /// 按专辑来源 id 获取曲目。
  Future<List<Track>> getTracksByAlbumId(String albumSourceId);

  /// 按歌手来源 id 获取曲目。
  Future<List<Track>> getTracksByArtistId(String artistSourceId);

  /// 保存曲目列表。
  Future<void> saveTracks(List<Track> tracks);

  /// 保存歌单列表。
  Future<void> savePlaylists(List<PlaylistEntity> playlists);

  /// 保存专辑列表。
  Future<void> saveAlbums(List<AlbumEntity> albums);

  /// 保存歌手列表。
  Future<void> saveArtists(List<ArtistEntity> artists);

  /// 保存曲目歌词。
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics);

  /// 删除曲目。
  Future<void> removeTrack(String trackId);

  /// 删除曲目歌词。
  Future<void> removeLyrics(String trackId);

  /// 清空歌单曲目引用。
  Future<void> clearPlaylistTrackRefs(String playlistId);
}
