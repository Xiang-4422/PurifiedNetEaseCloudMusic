import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

abstract class LocalLibraryDataSource {
  Future<List<Track>> searchTracks(String keyword);

  Future<List<PlaylistEntity>> searchPlaylists(String keyword);

  Future<List<AlbumEntity>> searchAlbums(String keyword);

  Future<List<ArtistEntity>> searchArtists(String keyword);

  Future<Track?> getTrack(String trackId);

  Future<List<Track>> getTracksByIds(Iterable<String> trackIds);

  Future<TrackLyrics?> getLyrics(String trackId);

  Future<PlaylistEntity?> getPlaylist(String playlistId);

  Future<AlbumEntity?> getAlbum(String albumId);

  Future<ArtistEntity?> getArtist(String artistId);

  Future<List<Track>> getTracksByAlbumId(String albumSourceId);

  Future<List<Track>> getTracksByArtistId(String artistSourceId);

  Future<void> saveTracks(List<Track> tracks);

  Future<void> savePlaylists(List<PlaylistEntity> playlists);

  Future<void> saveAlbums(List<AlbumEntity> albums);

  Future<void> saveArtists(List<ArtistEntity> artists);

  Future<void> saveLyrics(String trackId, TrackLyrics lyrics);
}
