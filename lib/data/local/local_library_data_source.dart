import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

abstract class LocalLibraryDataSource {
  Future<List<Track>> searchTracks(String keyword);

  Future<List<PlaylistEntity>> searchPlaylists(String keyword);

  Future<List<AlbumEntity>> searchAlbums(String keyword);

  Future<List<ArtistEntity>> searchArtists(String keyword);

  Future<Track?> getTrack(String trackId);

  Future<TrackLyrics?> getLyrics(String trackId);

  Future<PlaybackRestoreState?> getPlaybackRestoreState();

  Future<PlaylistEntity?> getPlaylist(String playlistId);

  Future<void> saveTracks(List<Track> tracks);

  Future<void> savePlaylists(List<PlaylistEntity> playlists);

  Future<void> saveAlbums(List<AlbumEntity> albums);

  Future<void> saveArtists(List<ArtistEntity> artists);

  Future<void> saveLyrics(String trackId, TrackLyrics lyrics);

  Future<void> savePlaybackRestoreState(PlaybackRestoreState state);
}
