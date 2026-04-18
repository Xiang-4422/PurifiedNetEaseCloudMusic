import '../entities/album_entity.dart';
import '../entities/artist_entity.dart';
import '../entities/playlist_entity.dart';
import '../entities/track.dart';
import '../entities/track_lyrics.dart';

abstract class MusicSource {
  String get sourceKey;

  Future<List<Track>> searchTracks(String keyword);

  Future<List<PlaylistEntity>> searchPlaylists(String keyword);

  Future<List<AlbumEntity>> searchAlbums(String keyword);

  Future<List<ArtistEntity>> searchArtists(String keyword);

  Future<Track?> getTrack(String trackId);

  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  });

  Future<TrackLyrics?> getLyrics(String trackId);

  Future<PlaylistEntity?> getPlaylist(String playlistId);
}
