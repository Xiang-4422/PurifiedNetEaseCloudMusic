import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

import 'dao/playlist_dao.dart';
import 'dao/track_dao.dart';
import 'local_library_data_source.dart';

/// Drift 实现的本地曲库数据源。
class DriftLocalLibraryDataSource implements LocalLibraryDataSource {
  /// 创建 Drift 本地曲库数据源。
  DriftLocalLibraryDataSource({
    required TrackDao trackDao,
    required PlaylistDao playlistDao,
  })  : _trackDao = trackDao,
        _playlistDao = playlistDao;

  final TrackDao _trackDao;
  final PlaylistDao _playlistDao;

  @override
  Future<List<Track>> searchTracks(String keyword) {
    return _trackDao.searchTracks(keyword);
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) {
    return _playlistDao.searchPlaylists(keyword);
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) {
    return _trackDao.searchAlbums(keyword);
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) {
    return _trackDao.searchArtists(keyword);
  }

  @override
  Future<Track?> getTrack(String trackId) {
    return _trackDao.getTrack(trackId);
  }

  @override
  Future<List<Track>> getTracksByIds(Iterable<String> trackIds) {
    return _trackDao.getTracksByIds(trackIds);
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) {
    return _trackDao.getLyrics(trackId);
  }

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) {
    return _playlistDao.getPlaylist(playlistId);
  }

  @override
  Future<AlbumEntity?> getAlbum(String albumId) {
    return _trackDao.getAlbum(albumId);
  }

  @override
  Future<ArtistEntity?> getArtist(String artistId) {
    return _trackDao.getArtist(artistId);
  }

  @override
  Future<List<Track>> getTracksByAlbumId(String albumSourceId) {
    return _trackDao.getTracksByAlbumId(albumSourceId);
  }

  @override
  Future<List<Track>> getTracksByArtistId(String artistSourceId) {
    return _trackDao.getTracksByArtistId(artistSourceId);
  }

  @override
  Future<void> saveTracks(List<Track> tracks) {
    return _trackDao.saveTracks(tracks);
  }

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) {
    return _playlistDao.savePlaylists(playlists);
  }

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) {
    return _trackDao.saveAlbums(albums);
  }

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) {
    return _trackDao.saveArtists(artists);
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) {
    return _trackDao.saveLyrics(trackId, lyrics);
  }

  @override
  Future<void> removeTrack(String trackId) {
    return _trackDao.removeTrack(trackId);
  }

  @override
  Future<void> removeLyrics(String trackId) {
    return _trackDao.removeLyrics(trackId);
  }

  @override
  Future<void> clearPlaylistTrackRefs(String playlistId) {
    return _playlistDao.clearPlaylistTrackRefs(playlistId);
  }
}
