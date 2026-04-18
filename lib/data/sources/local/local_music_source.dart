import 'package:bujuan/data/local/in_memory_local_library_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/sources/music_source.dart';
import 'package:get_it/get_it.dart';

class LocalMusicSource implements MusicSource {
  LocalMusicSource({LocalLibraryDataSource? localDataSource})
      : _localDataSource =
            localDataSource ??
            (GetIt.instance.isRegistered<LocalLibraryDataSource>()
                ? GetIt.instance<LocalLibraryDataSource>()
                : InMemoryLocalLibraryDataSource.shared);

  final LocalLibraryDataSource _localDataSource;

  @override
  String get sourceKey => 'local';

  @override
  Future<List<Track>> searchTracks(String keyword) {
    return _localDataSource.searchTracks(keyword);
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) {
    return _localDataSource.searchPlaylists(keyword);
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) {
    return _localDataSource.searchAlbums(keyword);
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) {
    return _localDataSource.searchArtists(keyword);
  }

  @override
  Future<Track?> getTrack(String trackId) {
    return _localDataSource.getTrack(trackId);
  }

  @override
  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) async {
    final track = await _localDataSource.getTrack(trackId);
    return track?.localPath;
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) {
    return _localDataSource.getLyrics(trackId);
  }

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) {
    return _localDataSource.getPlaylist(playlistId);
  }
}
