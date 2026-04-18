import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/in_memory_local_library_data_source.dart';
import 'package:bujuan/data/sources/music_source_registry_impl.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/sources/music_source_registry.dart';
import 'package:get_it/get_it.dart';

import 'library_preference_store.dart';

class LibraryRepository {
  LibraryRepository({
    LocalLibraryDataSource? localDataSource,
    MusicSourceRegistry? sourceRegistry,
    LibraryPreferenceStore? preferenceStore,
  })  : _localDataSource = localDataSource ??
            (GetIt.instance.isRegistered<LocalLibraryDataSource>()
                ? GetIt.instance<LocalLibraryDataSource>()
                : InMemoryLocalLibraryDataSource.shared),
        _sourceRegistry = sourceRegistry ??
            (GetIt.instance.isRegistered<MusicSourceRegistry>()
                ? GetIt.instance<MusicSourceRegistry>()
                : MusicSourceRegistryImpl()),
        _preferenceStore = preferenceStore ?? const LibraryPreferenceStore();

  final LocalLibraryDataSource? _localDataSource;
  final MusicSourceRegistry _sourceRegistry;
  final LibraryPreferenceStore _preferenceStore;

  bool get isOfflineModeEnabled => _preferenceStore.isOfflineModeEnabled;

  Future<void> saveTracks(List<Track> tracks) async {
    await _localDataSource?.saveTracks(tracks);
  }

  Future<void> saveTrack(Track track) async {
    await saveTracks([track]);
  }

  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    await _localDataSource?.savePlaylists(playlists);
  }

  Future<void> saveAlbums(List<AlbumEntity> albums) async {
    await _localDataSource?.saveAlbums(albums);
  }

  Future<void> saveArtists(List<ArtistEntity> artists) async {
    await _localDataSource?.saveArtists(artists);
  }

  Future<List<Track>> searchTracks({
    required String sourceKey,
    required String keyword,
  }) async {
    if (isOfflineModeEnabled) {
      return searchLocalTracks(keyword);
    }
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
    if (isOfflineModeEnabled) {
      return searchLocalPlaylists(keyword);
    }
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
    if (isOfflineModeEnabled) {
      return searchLocalAlbums(keyword);
    }
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
    if (isOfflineModeEnabled) {
      return searchLocalArtists(keyword);
    }
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
    if (isOfflineModeEnabled) {
      return null;
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
    final localTrack = await _localDataSource?.getTrack(trackId);
    if (localTrack?.localPath?.isNotEmpty == true) {
      return localTrack!.localPath;
    }
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    if (isOfflineModeEnabled && source.sourceKey != 'local') {
      return null;
    }
    return source.getPlaybackUrl(trackId);
  }

  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
  }) async {
    final localTrack = await _localDataSource?.getTrack(trackId);
    if (localTrack?.localPath?.isNotEmpty == true) {
      return localTrack!.localPath;
    }
    final source = _sourceRegistry.getByTrackId(trackId);
    if (source == null) {
      return null;
    }
    if (isOfflineModeEnabled && source.sourceKey != 'local') {
      return null;
    }
    return source.getPlaybackUrl(trackId, qualityLevel: qualityLevel);
  }

  Future<TrackLyrics?> getLyrics(String trackId) async {
    final localLyrics = await _localDataSource?.getLyrics(trackId);
    if (localLyrics != null) {
      return localLyrics;
    }
    if (isOfflineModeEnabled) {
      return null;
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
    if (isOfflineModeEnabled) {
      return null;
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

  Future<Track?> updateTrackLocalState(
    String trackId, {
    String? localPath,
    String? localArtworkPath,
    String? localLyricsPath,
    DownloadState? downloadState,
    TrackResourceOrigin? resourceOrigin,
    double? downloadProgress,
    String? downloadFailureReason,
    TrackAvailability? availability,
    Map<String, Object?>? metadata,
  }) async {
    final track = await getTrack(trackId);
    if (track == null) {
      return null;
    }
    final nextTrack = track.copyWith(
      localPath: localPath ?? track.localPath,
      localArtworkPath: localArtworkPath ?? track.localArtworkPath,
      localLyricsPath: localLyricsPath ?? track.localLyricsPath,
      downloadState: downloadState ?? track.downloadState,
      resourceOrigin: resourceOrigin ?? track.resourceOrigin,
      downloadProgress: downloadProgress ?? track.downloadProgress,
      downloadFailureReason:
          downloadFailureReason ?? track.downloadFailureReason,
      availability: availability ?? track.availability,
      metadata: metadata == null
          ? track.metadata
          : {
              ...track.metadata,
              ...metadata,
            },
    );
    await saveTrack(nextTrack);
    return nextTrack;
  }
}
