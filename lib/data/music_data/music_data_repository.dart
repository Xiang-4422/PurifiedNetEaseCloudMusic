import 'dart:io';

import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_library_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/local_music_source.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_music_source.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';

import 'sources/local/resources/local_artwork_cache_repository.dart';
import 'sources/local/resources/local_resource_index_repository.dart';
import 'sources/local/resources/playback_url_cache_coordinator.dart';

/// 聚合本地曲库、网易云曲库和本地资源索引的音乐数据仓库。
class MusicDataRepository {
  /// 创建音乐数据仓库。
  MusicDataRepository({
    required LocalLibraryDataSource localDataSource,
    required NeteaseMusicSource neteaseSource,
    required LocalMusicSource localMusicSource,
    required LocalResourceIndexRepository resourceIndexRepository,
    required LocalArtworkCacheRepository artworkCacheRepository,
  })  : _localDataSource = localDataSource,
        _neteaseSource = neteaseSource,
        _localMusicSource = localMusicSource,
        _resourceIndexRepository = resourceIndexRepository,
        _artworkCacheRepository = artworkCacheRepository;

  final LocalLibraryDataSource _localDataSource;
  final NeteaseMusicSource _neteaseSource;
  final LocalMusicSource _localMusicSource;
  final LocalResourceIndexRepository _resourceIndexRepository;
  final LocalArtworkCacheRepository _artworkCacheRepository;
  final Map<String, Future<TrackLyrics?>> _lyricsLoads = {};
  late final PlaybackUrlCacheCoordinator _playbackUrlCoordinator = PlaybackUrlCacheCoordinator(
    resolveLocalResourceUrl: _resolveIndexedAudioResourceUrl,
  );

  /// 保存曲目并预缓存封面。
  Future<void> saveTracks(
    List<Track> tracks, {
    bool precacheArtwork = true,
  }) async {
    await _localDataSource.saveTracks(tracks);
    if (precacheArtwork) {
      await _artworkCacheRepository.cacheTrackArtwork(tracks);
    }
  }

  /// 保存单首曲目。
  Future<void> saveTrack(
    Track track, {
    bool precacheArtwork = true,
  }) async {
    await saveTracks([track], precacheArtwork: precacheArtwork);
  }

  /// 保存歌单摘要或详情。
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    await _localDataSource.savePlaylists(playlists);
  }

  /// 保存专辑数据。
  Future<void> saveAlbums(List<AlbumEntity> albums) async {
    await _localDataSource.saveAlbums(albums);
  }

  /// 保存歌手数据。
  Future<void> saveArtists(List<ArtistEntity> artists) async {
    await _localDataSource.saveArtists(artists);
  }

  /// 按来源搜索曲目，并把在线结果写入本地曲库缓存。
  Future<List<Track>> searchTracks({
    required String sourceKey,
    required String keyword,
  }) async {
    final tracks = sourceKey == _localMusicSource.sourceKey ? await _localMusicSource.searchTracks(keyword) : await _neteaseSource.searchTracks(keyword);
    await _localDataSource.saveTracks(tracks);
    return tracks;
  }

  /// 仅在本地曲库中搜索曲目。
  Future<List<Track>> searchLocalTracks(String keyword) async {
    return _localDataSource.searchTracks(keyword);
  }

  /// 按来源搜索歌单，并把在线结果写入本地曲库缓存。
  Future<List<PlaylistEntity>> searchPlaylists({
    required String sourceKey,
    required String keyword,
  }) async {
    final playlists = sourceKey == _localMusicSource.sourceKey ? await _localMusicSource.searchPlaylists(keyword) : await _neteaseSource.searchPlaylists(keyword);
    await _localDataSource.savePlaylists(playlists);
    return playlists;
  }

  /// 仅在本地曲库中搜索歌单。
  Future<List<PlaylistEntity>> searchLocalPlaylists(String keyword) async {
    return _localDataSource.searchPlaylists(keyword);
  }

  /// 按来源搜索专辑，并把在线结果写入本地曲库缓存。
  Future<List<AlbumEntity>> searchAlbums({
    required String sourceKey,
    required String keyword,
  }) async {
    final albums = sourceKey == _localMusicSource.sourceKey ? await _localMusicSource.searchAlbums(keyword) : await _neteaseSource.searchAlbums(keyword);
    await _localDataSource.saveAlbums(albums);
    return albums;
  }

  /// 仅在本地曲库中搜索专辑。
  Future<List<AlbumEntity>> searchLocalAlbums(String keyword) async {
    return _localDataSource.searchAlbums(keyword);
  }

  /// 按来源搜索歌手，并把在线结果写入本地曲库缓存。
  Future<List<ArtistEntity>> searchArtists({
    required String sourceKey,
    required String keyword,
  }) async {
    final artists = sourceKey == _localMusicSource.sourceKey ? await _localMusicSource.searchArtists(keyword) : await _neteaseSource.searchArtists(keyword);
    await _localDataSource.saveArtists(artists);
    return artists;
  }

  /// 仅在本地曲库中搜索歌手。
  Future<List<ArtistEntity>> searchLocalArtists(String keyword) async {
    return _localDataSource.searchArtists(keyword);
  }

  /// 读取曲目；本地没有时回源远程或本地扫描来源。
  Future<Track?> getTrack(String trackId) async {
    if (_isBlankTrackId(trackId)) {
      return null;
    }
    final localTrack = await _localDataSource.getTrack(trackId);
    if (localTrack != null) {
      return localTrack;
    }
    final track = _isLocalTrackId(trackId) ? await _localMusicSource.getTrack(trackId) : await _neteaseSource.getTrack(trackId);
    if (track != null) {
      await _localDataSource.saveTracks([track]);
    }
    return track;
  }

  /// 读取曲目及其本地音频、封面和歌词资源索引。
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

  /// 按曲目 id 批量读取本地曲目。
  Future<List<Track>> getTracksByIds(Iterable<String> trackIds) async {
    final ids = _candidateTrackIds(trackIds);
    if (ids.isEmpty) {
      return const [];
    }
    return _localDataSource.getTracksByIds(ids);
  }

  /// 按曲目 id 批量读取本地曲目及资源索引。
  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    final ids = _candidateTrackIds(trackIds);
    if (ids.isEmpty) {
      return const [];
    }
    final tracks = await getTracksByIds(ids);
    if (tracks.isEmpty) {
      return const [];
    }
    final resourcesByTrackId = await _resourceIndexRepository.getTrackResourceBundles(
      ids,
    );
    final tracksById = {
      for (final track in tracks) track.id: track,
    };
    return ids
        .map((trackId) {
          final track = tracksById[trackId];
          if (track == null) {
            return null;
          }
          return TrackWithResources(
            track: track,
            resources: resourcesByTrackId[track.id] ?? const TrackResourceBundle(),
          );
        })
        .whereType<TrackWithResources>()
        .toList();
  }

  /// 列出已登记的本地歌曲资源，可按资源来源过滤。
  Future<List<LocalSongEntry>> getLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) {
    return _resourceIndexRepository.listLocalSongs(origins: origins);
  }

  /// 解析曲目播放地址，优先返回仍存在的本地音频资源。
  Future<String?> getPlaybackUrl(
    String trackId, {
    bool forceRefresh = false,
  }) async {
    if (_isBlankTrackId(trackId)) {
      return null;
    }
    return _coalescePlaybackUrl(
      trackId,
      qualityLevel: null,
      forceRefresh: forceRefresh,
      load: () => _resolvePlaybackUrl(trackId),
    );
  }

  Future<String?> _resolvePlaybackUrl(String trackId) async {
    final trackWithResources = await getTrackWithResources(trackId);
    final localAudio = trackWithResources?.resources.audio;
    final localAudioPath = localAudio == null ? null : await _localResourcePathIfExists(localAudio);
    if (localAudioPath != null) {
      return localAudioPath;
    }
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isLocalTrack) {
      return null;
    }
    return _neteaseSource.getPlaybackUrl(trackId);
  }

  /// 按音质偏好解析播放地址，优先返回仍存在的本地音频资源。
  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
    bool forceRefresh = false,
  }) async {
    if (_isBlankTrackId(trackId)) {
      return null;
    }
    return _coalescePlaybackUrl(
      trackId,
      qualityLevel: qualityLevel,
      forceRefresh: forceRefresh,
      load: () => _resolvePlaybackUrlWithQuality(
        trackId,
        qualityLevel: qualityLevel,
      ),
    );
  }

  Future<String?> _resolvePlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
  }) async {
    final trackWithResources = await getTrackWithResources(trackId);
    final localAudio = trackWithResources?.resources.audio;
    final localAudioPath = localAudio == null ? null : await _localResourcePathIfExists(localAudio);
    if (localAudioPath != null) {
      return localAudioPath;
    }
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isLocalTrack) {
      return null;
    }
    return _neteaseSource.getPlaybackUrl(trackId, qualityLevel: qualityLevel);
  }

  /// 解析封面来源，优先返回仍存在的本地封面资源。
  Future<String> getArtworkSource(String trackId) async {
    if (_isBlankTrackId(trackId)) {
      return '';
    }
    final trackWithResources = await getTrackWithResources(trackId);
    if (trackWithResources == null) {
      return '';
    }
    final localArtwork = trackWithResources.resources.artwork;
    final localArtworkPath = localArtwork == null ? null : await _localResourcePathIfExists(localArtwork);
    if (localArtworkPath != null) {
      return localArtworkPath;
    }
    return trackWithResources.track.artworkUrl ?? '';
  }

  /// 读取歌词，优先使用本地歌词资源和缓存。
  Future<TrackLyrics?> getLyrics(String trackId) async {
    if (_isBlankTrackId(trackId)) {
      return null;
    }
    final loadingLyrics = _lyricsLoads[trackId];
    if (loadingLyrics != null) {
      return loadingLyrics;
    }
    final loadFuture = _loadLyrics(trackId);
    _lyricsLoads[trackId] = loadFuture;
    try {
      return await loadFuture;
    } finally {
      _lyricsLoads.remove(trackId);
    }
  }

  Future<TrackLyrics?> _loadLyrics(String trackId) async {
    final lyricsResource = (await _resourceIndexRepository.getTrackResourceBundle(trackId)).lyrics;
    if (lyricsResource != null && await _touchIfLocalFileExists(lyricsResource)) {
      return TrackLyrics(
        main: await File(_resourceFilePath(lyricsResource)).readAsString(),
      );
    }
    final localLyrics = await _localDataSource.getLyrics(trackId);
    if (localLyrics != null) {
      return localLyrics;
    }
    final lyrics = _isLocalTrackId(trackId) ? await _localMusicSource.getLyrics(trackId) : await _neteaseSource.getLyrics(trackId);
    if (lyrics != null) {
      await _localDataSource.saveLyrics(trackId, lyrics);
    }
    return lyrics;
  }

  Future<String?> _coalescePlaybackUrl(
    String trackId, {
    required String? qualityLevel,
    required bool forceRefresh,
    required Future<String?> Function() load,
  }) async {
    return _playbackUrlCoordinator.resolve(
      trackId,
      qualityLevel: qualityLevel,
      forceRefresh: forceRefresh,
      load: load,
    );
  }

  Future<String?> _resolveIndexedAudioResourceUrl(String trackId) async {
    final localAudio = (await _resourceIndexRepository.getTrackResourceBundle(trackId)).audio;
    return localAudio == null ? null : _localResourcePathIfExists(localAudio);
  }

  /// 保存曲目歌词缓存。
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    await _localDataSource.saveLyrics(trackId, lyrics);
  }

  /// 读取歌单；本地没有时回源远程或本地扫描来源。
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final localPlaylist = await _localDataSource.getPlaylist(playlistId);
    if (localPlaylist != null) {
      return localPlaylist;
    }
    final playlist = _isLocalPlaylistId(playlistId) ? await _localMusicSource.getPlaylist(playlistId) : await _neteaseSource.getPlaylist(playlistId);
    if (playlist != null) {
      await _localDataSource.savePlaylists([playlist]);
    }
    return playlist;
  }

  /// 从本地曲库读取专辑。
  Future<AlbumEntity?> getAlbum(String albumId) async {
    return _localDataSource.getAlbum(albumId);
  }

  /// 从本地曲库读取歌手。
  Future<ArtistEntity?> getArtist(String artistId) async {
    return _localDataSource.getArtist(artistId);
  }

  /// 读取指定专辑下已缓存的曲目。
  Future<List<Track>> getTracksByAlbumId(String albumSourceId) async {
    return _localDataSource.getTracksByAlbumId(albumSourceId);
  }

  /// 读取指定歌手下已缓存的曲目。
  Future<List<Track>> getTracksByArtistId(String artistSourceId) async {
    return _localDataSource.getTracksByArtistId(artistSourceId);
  }

  /// 读取曲目的本地资源索引。
  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) {
    if (_isBlankTrackId(trackId)) {
      return Future.value(const TrackResourceBundle());
    }
    return _resourceIndexRepository.getTrackResourceBundle(trackId);
  }

  /// 删除曲目的本地资源索引，并按需删除真实文件。
  Future<void> removeLocalTrackResources(
    String trackId, {
    required bool deleteSourceFiles,
  }) async {
    final trackWithResources = await getTrackWithResources(trackId);
    if (trackWithResources == null) {
      await _resourceIndexRepository.removeTrackResources(trackId);
      await _localDataSource.removeLyrics(trackId);
      return;
    }
    final track = trackWithResources.track;
    final resources = trackWithResources.resources;
    final retainedPaths = _retainedResourcePathsAfterRemoving(
      await _resourceIndexRepository.listResources(),
      shouldRemove: (resource) => resource.trackId == trackId,
    );
    await _deleteResourceFile(
      resources.audio,
      deleteFile: _shouldDeleteResourceFile(
        resources.audio,
        retainedPaths,
        deleteSourceFiles: deleteSourceFiles,
      ),
    );
    await _deleteResourceFile(
      resources.artwork,
      deleteFile: _shouldDeleteResourceFile(
        resources.artwork,
        retainedPaths,
        deleteSourceFiles: deleteSourceFiles,
      ),
    );
    await _deleteResourceFile(
      resources.lyrics,
      deleteFile: _shouldDeleteResourceFile(
        resources.lyrics,
        retainedPaths,
        deleteSourceFiles: deleteSourceFiles,
      ),
    );
    await _resourceIndexRepository.removeTrackResources(trackId);
    await _localDataSource.removeLyrics(trackId);
    if (track.sourceType == SourceType.local) {
      await _localDataSource.removeTrack(trackId);
    }
  }

  /// 清理播放缓存来源的本地资源。
  Future<void> removePlaybackCache() async {
    final resources = await _resourceIndexRepository.listResources(
      origins: const {TrackResourceOrigin.playbackCache},
    );
    final retainedPaths = _retainedResourcePathsAfterRemoving(
      await _resourceIndexRepository.listResources(),
      shouldRemove: (resource) => resource.origin == TrackResourceOrigin.playbackCache,
    );
    for (final resource in resources) {
      await _deleteResourceFile(
        resource,
        deleteFile: _shouldDeleteResourceFile(
          resource,
          retainedPaths,
          deleteSourceFiles: true,
        ),
      );
      await _resourceIndexRepository.removeResource(
        resource.trackId,
        resource.kind,
      );
    }
  }

  Set<String> _retainedResourcePathsAfterRemoving(
    List<LocalResourceEntry> indexedResources, {
    required bool Function(LocalResourceEntry resource) shouldRemove,
  }) {
    final retainedPaths = <String>{};
    for (final resource in indexedResources) {
      if (shouldRemove(resource)) {
        continue;
      }
      final path = _resourceFilePath(resource);
      if (path.isNotEmpty) {
        retainedPaths.add(path);
      }
    }
    return retainedPaths;
  }

  bool _shouldDeleteResourceFile(
    LocalResourceEntry? resource,
    Set<String> retainedPaths, {
    required bool deleteSourceFiles,
  }) {
    if (!deleteSourceFiles || resource == null) {
      return false;
    }
    final path = _resourceFilePath(resource);
    return path.isNotEmpty && !retainedPaths.contains(path);
  }

  Future<void> _deleteResourceFile(
    LocalResourceEntry? resource, {
    required bool deleteFile,
  }) async {
    if (!deleteFile || resource == null) {
      return;
    }
    final path = _resourceFilePath(resource);
    if (path.isEmpty) {
      return;
    }
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<bool> _touchIfLocalFileExists(LocalResourceEntry resource) async {
    return await _localResourcePathIfExists(resource) != null;
  }

  Future<String?> _localResourcePathIfExists(LocalResourceEntry resource) async {
    final path = _resourceFilePath(resource);
    final file = path.isEmpty ? null : File(path);
    if (file == null || !file.existsSync()) {
      await _resourceIndexRepository.removeResource(resource.trackId, resource.kind);
      return null;
    }
    await _resourceIndexRepository.touchResource(resource.trackId, resource.kind);
    return path;
  }

  String _resourceFilePath(LocalResourceEntry resource) {
    return LocalFilePathNormalizer.normalize(resource.path);
  }

  bool _isLocalTrackId(String trackId) {
    return trackId.startsWith('${_localMusicSource.sourceKey}:');
  }

  bool _isBlankTrackId(String trackId) {
    return trackId.trim().isEmpty;
  }

  List<String> _candidateTrackIds(Iterable<String> trackIds) {
    final ids = <String>[];
    final seen = <String>{};
    for (final trackId in trackIds) {
      if (_isBlankTrackId(trackId) || !seen.add(trackId)) {
        continue;
      }
      ids.add(trackId);
    }
    return ids;
  }

  bool _isLocalPlaylistId(String playlistId) {
    return playlistId.startsWith('${_localMusicSource.sourceKey}:');
  }
}
