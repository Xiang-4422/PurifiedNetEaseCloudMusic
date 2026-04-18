import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

abstract class LocalLibraryDataSource {
  Future<List<Track>> searchTracks(String keyword);

  Future<Track?> getTrack(String trackId);

  Future<TrackLyrics?> getLyrics(String trackId);

  Future<PlaylistEntity?> getPlaylist(String playlistId);

  Future<void> saveTracks(List<Track> tracks);

  Future<void> saveLyrics(String trackId, TrackLyrics lyrics);

  Future<void> savePlaylist(PlaylistEntity playlist);
}
