import '../entities/playlist_entity.dart';
import '../entities/track.dart';

abstract class MusicSource {
  String get sourceKey;

  Future<List<Track>> searchTracks(String keyword);

  Future<Track?> getTrack(String trackId);

  Future<String?> getPlaybackUrl(String trackId);

  Future<PlaylistEntity?> getPlaylist(String playlistId);
}
