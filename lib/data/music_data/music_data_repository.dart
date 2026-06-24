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
import 'sources/local/resources/local_resource_retention_policy.dart';
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final localTrack = await _localDataSource.getTrack(normalizedTrackId);
    if (localTrack != null) {
      return localTrack;
    }
    final track = _isLocalTrackId(normalizedTrackId) ? await _localMusicSource.getTrack(normalizedTrackId) : await _neteaseSource.getTrack(normalizedTrackId);
    if (track != null) {
      await _localDataSource.saveTracks([track]);
    }
    return track;
  }

  /// 读取曲目及其本地音频、封面和歌词资源索引。
  Future<TrackWithResources?> getTrackWithResources(String trackId) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    final track = await getTrack(normalizedTrackId);
    if (track == null) {
      return null;
    }
    return TrackWithResources(
      track: track,
      resources: await _resourceIndexRepository.getTrackResourceBundle(normalizedTrackId),
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    return _coalescePlaybackUrl(
      normalizedTrackId,
      qualityLevel: null,
      forceRefresh: forceRefresh,
      load: () => _resolvePlaybackUrl(normalizedTrackId),
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    return _coalescePlaybackUrl(
      normalizedTrackId,
      qualityLevel: qualityLevel,
      forceRefresh: forceRefresh,
      load: () => _resolvePlaybackUrlWithQuality(
        normalizedTrackId,
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return '';
    }
    final trackWithResources = await getTrackWithResources(normalizedTrackId);
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return null;
    }
    final loadingLyrics = _lyricsLoads[normalizedTrackId];
    if (loadingLyrics != null) {
      return loadingLyrics;
    }
    final loadFuture = _loadLyrics(normalizedTrackId);
    _lyricsLoads[normalizedTrackId] = loadFuture;
    try {
      return await loadFuture;
    } finally {
      _lyricsLoads.remove(normalizedTrackId);
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
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return;
    }
    await _localDataSource.saveLyrics(normalizedTrackId, lyrics);
  }

  /// 读取歌单；本地没有时回源远程或本地扫描来源。
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final normalizedPlaylistId = _normalizedPlaylistId(playlistId);
    if (_isBlankPlaylistId(normalizedPlaylistId)) {
      return null;
    }
    final localPlaylist = await _localDataSource.getPlaylist(normalizedPlaylistId);
    if (localPlaylist != null) {
      return localPlaylist;
    }
    final playlist = _isLocalPlaylistId(normalizedPlaylistId) ? await _localMusicSource.getPlaylist(normalizedPlaylistId) : await _neteaseSource.getPlaylist(normalizedPlaylistId);
    if (playlist != null) {
      await _localDataSource.savePlaylists([playlist]);
    }
    return playlist;
  }

  /// 从本地曲库读取专辑。
  Future<AlbumEntity?> getAlbum(String albumId) async {
    final normalizedAlbumId = _normalizedAlbumId(albumId);
    if (_isBlankAlbumId(normalizedAlbumId)) {
      return null;
    }
    return _localDataSource.getAlbum(normalizedAlbumId);
  }

  /// 从本地曲库读取歌手。
  Future<ArtistEntity?> getArtist(String artistId) async {
    final normalizedArtistId = _normalizedArtistId(artistId);
    if (_isBlankArtistId(normalizedArtistId)) {
      return null;
    }
    return _localDataSource.getArtist(normalizedArtistId);
  }

  /// 读取指定专辑下已缓存的曲目。
  Future<List<Track>> getTracksByAlbumId(String albumSourceId) async {
    final normalizedAlbumSourceId = _normalizedAlbumId(albumSourceId);
    if (_isBlankAlbumId(normalizedAlbumSourceId)) {
      return const [];
    }
    return _localDataSource.getTracksByAlbumId(normalizedAlbumSourceId);
  }

  /// 读取指定歌手下已缓存的曲目。
  Future<List<Track>> getTracksByArtistId(String artistSourceId) async {
    final normalizedArtistSourceId = _normalizedArtistId(artistSourceId);
    if (_isBlankArtistId(normalizedArtistSourceId)) {
      return const [];
    }
    return _localDataSource.getTracksByArtistId(normalizedArtistSourceId);
  }

  /// 读取曲目的本地资源索引。
  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future.value(const TrackResourceBundle());
    }
    return _resourceIndexRepository.getTrackResourceBundle(normalizedTrackId);
  }

  /// 删除曲目的本地资源索引，并按需删除真实文件。
  Future<void> removeLocalTrackResources(
    String trackId, {
    required bool deleteSourceFiles,
  }) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return;
    }
    final trackWithResources = await getTrackWithResources(normalizedTrackId);
    if (trackWithResources == null) {
      await _resourceIndexRepository.removeTrackResources(normalizedTrackId);
      await _localDataSource.removeLyrics(normalizedTrackId);
      return;
    }
    final track = trackWithResources.track;
    final resources = trackWithResources.resources;
    final retainedPaths = LocalResourceRetentionPolicy.retainedPathsAfterRemoving(
      await _resourceIndexRepository.listResources(),
      shouldRemove: (resource) => resource.trackId == normalizedTrackId,
    );
    await _deleteResourceFile(
      resources.audio,
      deleteFile: LocalResourceRetentionPolicy.shouldDeleteResourceFile(
        resources.audio,
        retainedPaths,
        deleteSourceFiles: deleteSourceFiles,
      ),
    );
    await _deleteResourceFile(
      resources.artwork,
      deleteFile: LocalResourceRetentionPolicy.shouldDeleteResourceFile(
        resources.artwork,
        retainedPaths,
        deleteSourceFiles: deleteSourceFiles,
      ),
    );
    await _deleteResourceFile(
      resources.lyrics,
      deleteFile: LocalResourceRetentionPolicy.shouldDeleteResourceFile(
        resources.lyrics,
        retainedPaths,
        deleteSourceFiles: deleteSourceFiles,
      ),
    );
    await _resourceIndexRepository.removeTrackResources(normalizedTrackId);
    await _localDataSource.removeLyrics(normalizedTrackId);
    if (track.sourceType == SourceType.local) {
      await _localDataSource.removeTrack(normalizedTrackId);
    }
  }

  /// 清理播放缓存来源的本地资源。
  Future<void> removePlaybackCache() async {
    final resources = await _resourceIndexRepository.listResources(
      origins: const {TrackResourceOrigin.playbackCache},
    );
    final retainedPaths = LocalResourceRetentionPolicy.retainedPathsAfterRemoving(
      await _resourceIndexRepository.listResources(),
      shouldRemove: (resource) => resource.origin == TrackResourceOrigin.playbackCache,
    );
    for (final resource in resources) {
      await _deleteResourceFile(
        resource,
        deleteFile: LocalResourceRetentionPolicy.shouldDeleteResourceFile(
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
    return _normalizedTrackId(trackId).isEmpty;
  }

  bool _isBlankPlaylistId(String playlistId) {
    return _normalizedPlaylistId(playlistId).isEmpty;
  }

  bool _isBlankAlbumId(String albumId) {
    return _normalizedAlbumId(albumId).isEmpty;
  }

  bool _isBlankArtistId(String artistId) {
    return _normalizedArtistId(artistId).isEmpty;
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }

  String _normalizedPlaylistId(String playlistId) {
    return playlistId.trim();
  }

  String _normalizedAlbumId(String albumId) {
    return albumId.trim();
  }

  String _normalizedArtistId(String artistId) {
    return artistId.trim();
  }

  List<String> _candidateTrackIds(Iterable<String> trackIds) {
    final ids = <String>[];
    final seen = <String>{};
    for (final trackId in trackIds) {
      final normalizedTrackId = _normalizedTrackId(trackId);
      if (_isBlankTrackId(normalizedTrackId) || !seen.add(normalizedTrackId)) {
        continue;
      }
      ids.add(normalizedTrackId);
    }
    return ids;
  }

  bool _isLocalPlaylistId(String playlistId) {
    return _normalizedPlaylistId(playlistId).startsWith('${_localMusicSource.sourceKey}:');
  }
}
