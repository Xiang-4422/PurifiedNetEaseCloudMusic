import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/in_memory_local_library_data_source.dart';
import 'package:bujuan/data/sources/music_source_registry_impl.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/sources/music_source_registry.dart';

class LibraryRepository {
  LibraryRepository({
    LocalLibraryDataSource? localDataSource,
    MusicSourceRegistry? sourceRegistry,
  })  : _localDataSource =
            localDataSource ?? InMemoryLocalLibraryDataSource.shared,
        _sourceRegistry = sourceRegistry ?? MusicSourceRegistryImpl();

  final LocalLibraryDataSource? _localDataSource;
  final MusicSourceRegistry _sourceRegistry;

  Future<List<Track>> searchTracks({
    required String sourceKey,
    required String keyword,
  }) async {
    final source = _sourceRegistry.getBySourceKey(sourceKey);
    if (source == null) {
      return const [];
    }
    final tracks = await source.searchTracks(keyword);
    await _localDataSource?.saveTracks(tracks);
    return tracks;
  }

  Future<List<Track>> searchLocalTracks(String keyword) async {
    final localDataSource = _localDataSource;
    if (localDataSource == null) {
      return const [];
    }
    return localDataSource.searchTracks(keyword);
  }

  Future<List<PlaylistEntity>> searchPlaylists({
    required String sourceKey,
    required String keyword,
  }) async {
    final source = _sourceRegistry.getBySourceKey(sourceKey);
    if (source == null) {
      return const [];
    }
    final playlists = await source.searchPlaylists(keyword);
    await _localDataSource?.savePlaylists(playlists);
    return playlists;
  }

  Future<List<PlaylistEntity>> searchLocalPlaylists(String keyword) async {
    final localDataSource = _localDataSource;
    if (localDataSource == null) {
      return const [];
    }
    return localDataSource.searchPlaylists(keyword);
  }

  Future<List<AlbumEntity>> searchAlbums({
    required String sourceKey,
    required String keyword,
  }) async {
    final source = _sourceRegistry.getBySourceKey(sourceKey);
    if (source == null) {
      return const [];
    }
    final albums = await source.searchAlbums(keyword);
    await _localDataSource?.saveAlbums(albums);
    return albums;
  }

  Future<List<AlbumEntity>> searchLocalAlbums(String keyword) async {
    final localDataSource = _localDataSource;
    if (localDataSource == null) {
      return const [];
    }
    return localDataSource.searchAlbums(keyword);
  }

  Future<List<ArtistEntity>> searchArtists({
    required String sourceKey,
    required String keyword,
  }) async {
    final source = _sourceRegistry.getBySourceKey(sourceKey);
    if (source == null) {
      return const [];
    }
    final artists = await source.searchArtists(keyword);
    await _localDataSource?.saveArtists(artists);
    return artists;
  }

  Future<List<ArtistEntity>> searchLocalArtists(String keyword) async {
    final localDataSource = _localDataSource;
    if (localDataSource == null) {
      return const [];
    }
    return localDataSource.searchArtists(keyword);
  }

  Future<Track?> getTrack(String trackId) async {
    final localTrack = await _localDataSource?.getTrack(trackId);
    if (localTrack != null) {
      return localTrack;
    }
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    final track = await source.getTrack(trackId);
    if (track != null) {
      await _localDataSource?.saveTracks([track]);
    }
    return track;
  }

  Future<String?> getPlaybackUrl(String trackId) async {
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    return source.getPlaybackUrl(trackId);
  }

  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
  }) async {
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    return source.getPlaybackUrl(trackId, qualityLevel: qualityLevel);
  }

  Future<TrackLyrics?> getLyrics(String trackId) async {
    final localLyrics = await _localDataSource?.getLyrics(trackId);
    if (localLyrics != null) {
      return localLyrics;
    }
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    final lyrics = await source.getLyrics(trackId);
    if (lyrics != null) {
      await _localDataSource?.saveLyrics(trackId, lyrics);
    }
    return lyrics;
  }

  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final localPlaylist = await _localDataSource?.getPlaylist(playlistId);
    if (localPlaylist != null) {
      return localPlaylist;
    }
    final source = _sourceRegistry.getByPlaylistId(playlistId);
    if (source == null) {
      return null;
    }
    final playlist = await source.getPlaylist(playlistId);
    if (playlist != null) {
      await _localDataSource?.savePlaylists([playlist]);
    }
    return playlist;
  }
}
