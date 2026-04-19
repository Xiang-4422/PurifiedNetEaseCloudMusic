import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/in_memory_local_library_data_source.dart';
import 'package:bujuan/data/sources/local/local_music_source.dart';
import 'package:bujuan/data/sources/netease/netease_music_source.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:get_it/get_it.dart';

import 'library_preference_store.dart';
import 'local_resource_index_repository.dart';

class LibraryRepository {
  LibraryRepository({
    LocalLibraryDataSource? localDataSource,
    NeteaseMusicSource? neteaseSource,
    LocalMusicSource? localMusicSource,
    LibraryPreferenceStore? preferenceStore,
    LocalResourceIndexRepository? resourceIndexRepository,
  })  : _localDataSource = localDataSource ??
            (GetIt.instance.isRegistered<LocalLibraryDataSource>()
                ? GetIt.instance<LocalLibraryDataSource>()
                : InMemoryLocalLibraryDataSource.shared),
        _neteaseSource = neteaseSource ?? NeteaseMusicSource(),
        _localMusicSource = localMusicSource ??
            LocalMusicSource(localDataSource: localDataSource),
        _preferenceStore = preferenceStore ?? const LibraryPreferenceStore(),
        _resourceIndexRepository =
            resourceIndexRepository ?? LocalResourceIndexRepository();

  final LocalLibraryDataSource? _localDataSource;
  final NeteaseMusicSource _neteaseSource;
  final LocalMusicSource _localMusicSource;
  final LibraryPreferenceStore _preferenceStore;
  final LocalResourceIndexRepository _resourceIndexRepository;

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
    final tracks = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchTracks(keyword)
        : await _neteaseSource.searchTracks(keyword);
    await _localDataSource?.saveTracks(tracks);
    return tracks;
  }

  Future<List<Track>> searchLocalTracks(String keyword) async {
    final localDataSource = _localDataSource;
    if (localDataSource == null) {
      return const [];
    }
    final tracks = await localDataSource.searchTracks(keyword);
    return Future.wait(tracks.map(_mergeTrackWithResources));
  }

  Future<List<PlaylistEntity>> searchPlaylists({
    required String sourceKey,
    required String keyword,
  }) async {
    if (isOfflineModeEnabled) {
      return searchLocalPlaylists(keyword);
    }
    final playlists = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchPlaylists(keyword)
        : await _neteaseSource.searchPlaylists(keyword);
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
    final albums = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchAlbums(keyword)
        : await _neteaseSource.searchAlbums(keyword);
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
    final artists = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchArtists(keyword)
        : await _neteaseSource.searchArtists(keyword);
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
      return _mergeTrackWithResources(localTrack);
    }
    if (isOfflineModeEnabled) {
      return null;
    }
    final track = _isLocalTrackId(trackId)
        ? await _localMusicSource.getTrack(trackId)
        : await _neteaseSource.getTrack(trackId);
    if (track != null) {
      await _localDataSource?.saveTracks([track]);
      return _mergeTrackWithResources(track);
    }
    return null;
  }

  Future<String?> getPlaybackUrl(String trackId) async {
    final localTrack = await getTrack(trackId);
    if (localTrack?.localPath?.isNotEmpty == true) {
      return localTrack!.localPath;
    }
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isOfflineModeEnabled && !isLocalTrack) {
      return null;
    }
    return isLocalTrack
        ? _localMusicSource.getPlaybackUrl(trackId)
        : _neteaseSource.getPlaybackUrl(trackId);
  }

  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
  }) async {
    final localTrack = await getTrack(trackId);
    if (localTrack?.localPath?.isNotEmpty == true) {
      return localTrack!.localPath;
    }
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isOfflineModeEnabled && !isLocalTrack) {
      return null;
    }
    return isLocalTrack
        ? _localMusicSource.getPlaybackUrl(trackId, qualityLevel: qualityLevel)
        : _neteaseSource.getPlaybackUrl(trackId, qualityLevel: qualityLevel);
  }

  Future<TrackLyrics?> getLyrics(String trackId) async {
    final localLyrics = await _localDataSource?.getLyrics(trackId);
    if (localLyrics != null) {
      return localLyrics;
    }
    if (isOfflineModeEnabled) {
      return null;
    }
    final lyrics = _isLocalTrackId(trackId)
        ? await _localMusicSource.getLyrics(trackId)
        : await _neteaseSource.getLyrics(trackId);
    if (lyrics != null) {
      await _localDataSource?.saveLyrics(trackId, lyrics);
    }
    return lyrics;
  }

  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    await _localDataSource?.saveLyrics(trackId, lyrics);
  }

  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final localPlaylist = await _localDataSource?.getPlaylist(playlistId);
    if (localPlaylist != null) {
      return localPlaylist;
    }
    if (isOfflineModeEnabled) {
      return null;
    }
    final playlist = _isLocalPlaylistId(playlistId)
        ? await _localMusicSource.getPlaylist(playlistId)
        : await _neteaseSource.getPlaylist(playlistId);
    if (playlist != null) {
      await _localDataSource?.savePlaylists([playlist]);
    }
    return playlist;
  }

  Future<List<LocalResourceEntry>> getTrackResources(String trackId) {
    return _resourceIndexRepository.getTrackResources(trackId);
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

  Future<Track> _mergeTrackWithResources(Track track) async {
    final resources =
        await _resourceIndexRepository.getTrackResources(track.id);
    if (resources.isEmpty) {
      return track;
    }
    String? localPath = track.localPath;
    String? localArtworkPath = track.localArtworkPath;
    String? localLyricsPath = track.localLyricsPath;
    var resourceOrigin = track.resourceOrigin;
    for (final resource in resources) {
      switch (resource.kind) {
        case LocalResourceKind.audio:
          localPath ??= resource.path;
          if (resourceOrigin == TrackResourceOrigin.none) {
            resourceOrigin = resource.origin;
          }
          break;
        case LocalResourceKind.artwork:
          localArtworkPath ??= resource.path;
          break;
        case LocalResourceKind.lyrics:
          localLyricsPath ??= resource.path;
          break;
      }
    }
    return track.copyWith(
      localPath: localPath,
      localArtworkPath: localArtworkPath,
      localLyricsPath: localLyricsPath,
      resourceOrigin: resourceOrigin,
    );
  }

  bool _isLocalTrackId(String trackId) {
    return trackId.startsWith('${_localMusicSource.sourceKey}:');
  }

  bool _isLocalPlaylistId(String playlistId) {
    return playlistId.startsWith('${_localMusicSource.sourceKey}:');
  }
}
