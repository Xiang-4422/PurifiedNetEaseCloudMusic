import 'music_source.dart';

abstract class MusicSourceRegistry {
  MusicSource? getBySourceKey(String sourceKey);

  MusicSource? getByTrackId(String trackId);

  MusicSource? getByPlaylistId(String playlistId);

  List<MusicSource> getAll();
}
