import 'package:bujuan/data/sources/music_source_registry_impl.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/sources/music_source_registry.dart';

class LibraryRepository {
  LibraryRepository({MusicSourceRegistry? sourceRegistry})
      : _sourceRegistry = sourceRegistry ?? MusicSourceRegistryImpl();

  final MusicSourceRegistry _sourceRegistry;

  Future<List<Track>> searchTracks({
    required String sourceKey,
    required String keyword,
  }) async {
    final source = _sourceRegistry.getBySourceKey(sourceKey);
    if (source == null) {
      return const [];
    }
    return source.searchTracks(keyword);
  }

  Future<Track?> getTrack(String trackId) async {
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    return source.getTrack(trackId);
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
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    return source.getLyrics(trackId);
  }

  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final source = _sourceRegistry.getByPlaylistId(playlistId);
    if (source == null) {
      return null;
    }
    return source.getPlaylist(playlistId);
  }
}
