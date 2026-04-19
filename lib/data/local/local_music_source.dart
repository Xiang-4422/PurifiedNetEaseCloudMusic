import 'package:bujuan/data/local/in_memory_local_library_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:get_it/get_it.dart';

class LocalMusicSource {
  LocalMusicSource({LocalLibraryDataSource? localDataSource})
      : _localDataSource =
            localDataSource ??
            (GetIt.instance.isRegistered<LocalLibraryDataSource>()
                ? GetIt.instance<LocalLibraryDataSource>()
                : InMemoryLocalLibraryDataSource.shared);

  final LocalLibraryDataSource _localDataSource;

  String get sourceKey => 'local';

  Future<List<Track>> searchTracks(String keyword) {
    return _localDataSource.searchTracks(keyword);
  }

  Future<List<PlaylistEntity>> searchPlaylists(String keyword) {
    return _localDataSource.searchPlaylists(keyword);
  }

  Future<List<AlbumEntity>> searchAlbums(String keyword) {
    return _localDataSource.searchAlbums(keyword);
  }

  Future<List<ArtistEntity>> searchArtists(String keyword) {
    return _localDataSource.searchArtists(keyword);
  }

  Future<Track?> getTrack(String trackId) {
    return _localDataSource.getTrack(trackId);
  }

  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) async {
    final track = await _localDataSource.getTrack(trackId);
    return track?.localPath;
  }

  Future<TrackLyrics?> getLyrics(String trackId) {
    return _localDataSource.getLyrics(trackId);
  }

  Future<PlaylistEntity?> getPlaylist(String playlistId) {
    return _localDataSource.getPlaylist(playlistId);
  }
}
