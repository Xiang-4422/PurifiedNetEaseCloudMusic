import 'dart:io';

import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_music_source.dart';
import 'package:bujuan/data/netease/netease_music_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/local_song_entry.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:get_it/get_it.dart';

import 'library_preference_store.dart';
import 'local_artwork_cache_repository.dart';
import 'local_resource_index_repository.dart';

class LibraryRepository {
  LibraryRepository({
    LocalLibraryDataSource? localDataSource,
    NeteaseMusicSource? neteaseSource,
    LocalMusicSource? localMusicSource,
    LibraryPreferenceStore? preferenceStore,
    LocalResourceIndexRepository? resourceIndexRepository,
    LocalArtworkCacheRepository? artworkCacheRepository,
  })  : _localDataSource = localDataSource ??
            (GetIt.instance.isRegistered<LocalLibraryDataSource>()
                ? GetIt.instance<LocalLibraryDataSource>()
                : (throw StateError(
                    'LocalLibraryDataSource is not registered',
                  ))),
        _neteaseSource = neteaseSource ?? NeteaseMusicSource(),
        _localMusicSource = localMusicSource ??
            LocalMusicSource(localDataSource: localDataSource),
        _preferenceStore = preferenceStore ?? const LibraryPreferenceStore(),
        _resourceIndexRepository =
            resourceIndexRepository ?? LocalResourceIndexRepository(),
        _artworkCacheRepository =
            artworkCacheRepository ?? LocalArtworkCacheRepository();

  final LocalLibraryDataSource? _localDataSource;
  final NeteaseMusicSource _neteaseSource;
  final LocalMusicSource _localMusicSource;
  final LibraryPreferenceStore _preferenceStore;
  final LocalResourceIndexRepository _resourceIndexRepository;
  final LocalArtworkCacheRepository _artworkCacheRepository;

  bool get isOfflineModeEnabled => _preferenceStore.isOfflineModeEnabled;

  Future<void> saveTracks(List<Track> tracks) async {
    await _localDataSource?.saveTracks(tracks);
    if (isOfflineModeEnabled) {
      return;
    }
    await _artworkCacheRepository.cacheTrackArtwork(tracks);
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
    return localDataSource.searchTracks(keyword);
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
      return localTrack;
    }
    if (isOfflineModeEnabled) {
      return null;
    }
    final track = _isLocalTrackId(trackId)
        ? await _localMusicSource.getTrack(trackId)
        : await _neteaseSource.getTrack(trackId);
    if (track != null) {
      await _localDataSource?.saveTracks([track]);
    }
    return track;
  }

  Future<TrackWithResources?> getTrackWithResources(String trackId) async {
    final track = await getTrack(trackId);
    if (track == null) {
      return null;
    }
    return TrackWithResources(
      track: track,
      resources: await _resourceIndexRepository.getTrackResourceBundle(trackId),
    );
  }

  Future<List<Track>> getTracksByIds(Iterable<String> trackIds) async {
    final ids = trackIds.toSet().toList();
    if (ids.isEmpty) {
      return const [];
    }
    return await _localDataSource?.getTracksByIds(ids) ?? const [];
  }

  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    final ids = trackIds.toSet().toList();
    if (ids.isEmpty) {
      return const [];
    }
    final tracks = await getTracksByIds(ids);
    if (tracks.isEmpty) {
      return const [];
    }
    final resourcesByTrackId =
        await _resourceIndexRepository.getTrackResourceBundles(
      tracks.map((track) => track.id),
    );
    return tracks
        .map(
          (track) => TrackWithResources(
            track: track,
            resources:
                resourcesByTrackId[track.id] ?? const TrackResourceBundle(),
          ),
        )
        .toList();
  }

  Future<List<LocalSongEntry>> getLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) {
    return _resourceIndexRepository.listLocalSongs(origins: origins);
  }

  Future<String?> getPlaybackUrl(String trackId) async {
    final trackWithResources = await getTrackWithResources(trackId);
    final localAudio = trackWithResources?.resources.audio;
    if (localAudio != null && await _touchIfLocalFileExists(localAudio)) {
      return localAudio.path;
    }
    final track = trackWithResources?.track;
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isLocalTrack && track?.sourceId.isNotEmpty == true) {
      final localFile = File(track!.sourceId);
      if (localFile.existsSync()) {
        return localFile.path;
      }
    }
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
    final trackWithResources = await getTrackWithResources(trackId);
    final localAudio = trackWithResources?.resources.audio;
    if (localAudio != null && await _touchIfLocalFileExists(localAudio)) {
      return localAudio.path;
    }
    final track = trackWithResources?.track;
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isLocalTrack && track?.sourceId.isNotEmpty == true) {
      final localFile = File(track!.sourceId);
      if (localFile.existsSync()) {
        return localFile.path;
      }
    }
    if (isOfflineModeEnabled && !isLocalTrack) {
      return null;
    }
    return isLocalTrack
        ? _localMusicSource.getPlaybackUrl(trackId, qualityLevel: qualityLevel)
        : _neteaseSource.getPlaybackUrl(trackId, qualityLevel: qualityLevel);
  }

  Future<String> getArtworkSource(String trackId) async {
    final trackWithResources = await getTrackWithResources(trackId);
    if (trackWithResources == null) {
      return '';
    }
    final localArtwork = trackWithResources.resources.artwork;
    if (localArtwork != null && await _touchIfLocalFileExists(localArtwork)) {
      return localArtwork.path;
    }
    return trackWithResources.track.artworkUrl ?? '';
  }

  Future<TrackLyrics?> getLyrics(String trackId) async {
    final lyricsResource =
        (await _resourceIndexRepository.getTrackResourceBundle(trackId)).lyrics;
    if (lyricsResource != null && await _touchIfLocalFileExists(lyricsResource)) {
      return TrackLyrics(
        main: await File(lyricsResource.path).readAsString(),
      );
    }
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

  Future<AlbumEntity?> getAlbum(String albumId) async {
    return _localDataSource?.getAlbum(albumId);
  }

  Future<ArtistEntity?> getArtist(String artistId) async {
    return _localDataSource?.getArtist(artistId);
  }

  Future<List<Track>> getTracksByAlbumId(String albumSourceId) async {
    return await _localDataSource?.getTracksByAlbumId(albumSourceId) ??
        const [];
  }

  Future<List<Track>> getTracksByArtistId(String artistSourceId) async {
    return await _localDataSource?.getTracksByArtistId(artistSourceId) ??
        const [];
  }

  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) {
    return _resourceIndexRepository.getTrackResourceBundle(trackId);
  }

  Future<void> removeLocalTrackResources(
    String trackId, {
    required bool deleteSourceFiles,
  }) async {
    final trackWithResources = await getTrackWithResources(trackId);
    if (trackWithResources == null) {
      await _resourceIndexRepository.removeTrackResources(trackId);
      await _localDataSource?.removeLyrics(trackId);
      return;
    }
    final track = trackWithResources.track;
    final resources = trackWithResources.resources;
    await _deleteResourceFile(
      resources.audio,
      deleteFile: deleteSourceFiles,
    );
    await _deleteResourceFile(
      resources.artwork,
      deleteFile: deleteSourceFiles,
    );
    await _deleteResourceFile(
      resources.lyrics,
      deleteFile: deleteSourceFiles,
    );
    await _resourceIndexRepository.removeTrackResources(trackId);
    await _localDataSource?.removeLyrics(trackId);
    if (track.sourceType == SourceType.local) {
      await _localDataSource?.removeTrack(trackId);
    }
  }

  Future<void> removePlaybackCache() async {
    final entries = await getLocalSongs(
      origins: const {TrackResourceOrigin.playbackCache},
    );
    for (final entry in entries) {
      await removeLocalTrackResources(
        entry.track.id,
        deleteSourceFiles: true,
      );
    }
  }

  Future<void> _deleteResourceFile(
    LocalResourceEntry? resource, {
    required bool deleteFile,
  }) async {
    if (!deleteFile || resource == null) {
      return;
    }
    final file = File(resource.path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<bool> _touchIfLocalFileExists(LocalResourceEntry resource) async {
    final file = File(resource.path);
    if (!file.existsSync()) {
      return false;
    }
    await _resourceIndexRepository.touchResource(resource.trackId, resource.kind);
    return true;
  }

  bool _isLocalTrackId(String trackId) {
    return trackId.startsWith('${_localMusicSource.sourceKey}:');
  }

  bool _isLocalPlaylistId(String playlistId) {
    return playlistId.startsWith('${_localMusicSource.sourceKey}:');
  }
}
