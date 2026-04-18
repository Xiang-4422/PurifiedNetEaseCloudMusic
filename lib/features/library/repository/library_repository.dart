import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/in_memory_local_library_data_source.dart';
import 'package:bujuan/data/sources/music_source_registry_impl.dart';
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
      await _localDataSource?.savePlaylist(playlist);
    }
    return playlist;
  }
}
