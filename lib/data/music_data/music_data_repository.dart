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

import 'sources/local/resources/local_artwork_cache_repository.dart';
import 'sources/local/resources/local_resource_index_repository.dart';

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
  final Map<String, Future<String?>> _playbackUrlLoads = {};
  final Map<String, _CachedPlaybackUrl> _playbackUrlCache = {};
  final Map<String, Future<TrackLyrics?>> _lyricsLoads = {};

  static const Duration _playbackUrlCacheTtl = Duration(minutes: 2);

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
    final ids = trackIds.toSet().toList();
    if (ids.isEmpty) {
      return const [];
    }
    return _localDataSource.getTracksByIds(ids);
  }

  /// 按曲目 id 批量读取本地曲目及资源索引。
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
    final resourcesByTrackId = await _resourceIndexRepository.getTrackResourceBundles(
      tracks.map((track) => track.id),
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
    return _coalescePlaybackUrl(
      trackId,
      qualityLevel: null,
      forceRefresh: forceRefresh,
      load: () => _resolvePlaybackUrl(trackId),
    );
  }

  String _localFilePathCandidate(String rawPath) {
    final trimmedPath = rawPath.trim();
    if (trimmedPath.isEmpty) {
      return '';
    }
    final uri = Uri.tryParse(trimmedPath);
    final scheme = uri?.scheme.toLowerCase();
    if (uri != null && scheme == 'file') {
      final host = uri.host.toLowerCase();
      if (!Platform.isWindows && host.isNotEmpty && host != 'localhost') {
        return '';
      }
      return Uri(
        scheme: 'file',
        host: Platform.isWindows && host.isNotEmpty && host != 'localhost' ? uri.host : null,
        path: uri.path,
      ).toFilePath(windows: Platform.isWindows);
    }
    if (scheme == 'http' || scheme == 'https') {
      return '';
    }
    return File(trimmedPath.split('?').first).path;
  }

  Future<String?> _resolveLocalTrackSourceUrl(Track? track) async {
    if (track?.sourceId.isNotEmpty != true) {
      return null;
    }
    final sourcePath = _localFilePathCandidate(track!.sourceId);
    if (sourcePath.isEmpty) {
      return null;
    }
    final localFile = File(sourcePath);
    if (localFile.existsSync()) {
      return localFile.path;
    }
    return null;
  }

  Future<String?> _resolvePlaybackUrl(String trackId) async {
    final trackWithResources = await getTrackWithResources(trackId);
    final localAudio = trackWithResources?.resources.audio;
    if (localAudio != null && await _touchIfLocalFileExists(localAudio)) {
      return localAudio.path;
    }
    final track = trackWithResources?.track;
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isLocalTrack) {
      final localUrl = await _resolveLocalTrackSourceUrl(track);
      if (localUrl != null) {
        return localUrl;
      }
    }
    return isLocalTrack ? _localMusicSource.getPlaybackUrl(trackId) : _neteaseSource.getPlaybackUrl(trackId);
  }

  /// 按音质偏好解析播放地址，优先返回仍存在的本地音频资源。
  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
    bool forceRefresh = false,
  }) async {
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
    if (localAudio != null && await _touchIfLocalFileExists(localAudio)) {
      return localAudio.path;
    }
    final track = trackWithResources?.track;
    final isLocalTrack = _isLocalTrackId(trackId);
    if (isLocalTrack) {
      final localUrl = await _resolveLocalTrackSourceUrl(track);
      if (localUrl != null) {
        return localUrl;
      }
    }
    return isLocalTrack ? _localMusicSource.getPlaybackUrl(trackId, qualityLevel: qualityLevel) : _neteaseSource.getPlaybackUrl(trackId, qualityLevel: qualityLevel);
  }

  /// 解析封面来源，优先返回仍存在的本地封面资源。
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

  /// 读取歌词，优先使用本地歌词资源和缓存。
  Future<TrackLyrics?> getLyrics(String trackId) async {
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
        main: await File(lyricsResource.path).readAsString(),
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
    final cacheKey = '$trackId|${qualityLevel ?? ''}';
    final cachedUrl = _playbackUrlCache[cacheKey];
    final now = DateTime.now();
    if (!forceRefresh && cachedUrl != null && now.difference(cachedUrl.createdAt) < _playbackUrlCacheTtl) {
      final localUrl = await _resolveIndexedAudioResourceUrl(trackId);
      if (localUrl != null) {
        return localUrl;
      }
      return cachedUrl.url;
    }
    final loadingUrl = _playbackUrlLoads[cacheKey];
    if (!forceRefresh && loadingUrl != null) {
      final localUrl = await _resolveIndexedAudioResourceUrl(trackId);
      if (localUrl != null) {
        return localUrl;
      }
      return loadingUrl;
    }
    late final Future<String?> loadFuture;
    loadFuture = load().then((url) {
      if (identical(_playbackUrlLoads[cacheKey], loadFuture)) {
        _cachePlaybackUrl(cacheKey, url);
      }
      return url;
    }).whenComplete(() {
      if (identical(_playbackUrlLoads[cacheKey], loadFuture)) {
        _playbackUrlLoads.remove(cacheKey);
      }
    });
    _playbackUrlLoads[cacheKey] = loadFuture;
    return loadFuture;
  }

  void _cachePlaybackUrl(String cacheKey, String? url) {
    if (url != null && _isRemoteUrl(url)) {
      _playbackUrlCache[cacheKey] = _CachedPlaybackUrl(
        url: url,
        createdAt: DateTime.now(),
      );
    }
  }

  bool _isRemoteUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Future<String?> _resolveIndexedAudioResourceUrl(String trackId) async {
    final localAudio = (await _resourceIndexRepository.getTrackResourceBundle(trackId)).audio;
    if (localAudio != null && await _touchIfLocalFileExists(localAudio)) {
      return localAudio.path;
    }
    return null;
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
    return {
      for (final resource in indexedResources)
        if (!shouldRemove(resource)) resource.path,
    };
  }

  bool _shouldDeleteResourceFile(
    LocalResourceEntry? resource,
    Set<String> retainedPaths, {
    required bool deleteSourceFiles,
  }) {
    if (!deleteSourceFiles || resource == null) {
      return false;
    }
    return !retainedPaths.contains(resource.path);
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

class _CachedPlaybackUrl {
  const _CachedPlaybackUrl({
    required this.url,
    required this.createdAt,
  });

  final String url;
  final DateTime createdAt;
}
