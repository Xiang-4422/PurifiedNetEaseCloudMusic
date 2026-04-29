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

import 'library_preference_store.dart';
import 'local_artwork_cache_repository.dart';
import 'local_resource_index_repository.dart';

/// 聚合本地曲库、网易云曲库和本地资源索引的资料库仓库。
class LibraryRepository {
  /// 创建资料库仓库。
  LibraryRepository({
    required LocalLibraryDataSource localDataSource,
    required NeteaseMusicSource neteaseSource,
    required LocalMusicSource localMusicSource,
    required LibraryPreferenceStore preferenceStore,
    required LocalResourceIndexRepository resourceIndexRepository,
    required LocalArtworkCacheRepository artworkCacheRepository,
  })  : _localDataSource = localDataSource,
        _neteaseSource = neteaseSource,
        _localMusicSource = localMusicSource,
        _preferenceStore = preferenceStore,
        _resourceIndexRepository = resourceIndexRepository,
        _artworkCacheRepository = artworkCacheRepository;

  final LocalLibraryDataSource _localDataSource;
  final NeteaseMusicSource _neteaseSource;
  final LocalMusicSource _localMusicSource;
  final LibraryPreferenceStore _preferenceStore;
  final LocalResourceIndexRepository _resourceIndexRepository;
  final LocalArtworkCacheRepository _artworkCacheRepository;

  /// 当前资料库是否只允许读取本地缓存和本地资源。
  bool get isOfflineModeEnabled => _preferenceStore.isOfflineModeEnabled;

  /// 保存曲目并在非离线模式下预缓存封面。
  Future<void> saveTracks(List<Track> tracks) async {
    await _localDataSource.saveTracks(tracks);
    if (isOfflineModeEnabled) {
      return;
    }
    await _artworkCacheRepository.cacheTrackArtwork(tracks);
  }

  /// 保存单首曲目。
  Future<void> saveTrack(Track track) async {
    await saveTracks([track]);
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
    if (isOfflineModeEnabled) {
      return searchLocalTracks(keyword);
    }
    final tracks = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchTracks(keyword)
        : await _neteaseSource.searchTracks(keyword);
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
    if (isOfflineModeEnabled) {
      return searchLocalPlaylists(keyword);
    }
    final playlists = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchPlaylists(keyword)
        : await _neteaseSource.searchPlaylists(keyword);
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
    if (isOfflineModeEnabled) {
      return searchLocalAlbums(keyword);
    }
    final albums = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchAlbums(keyword)
        : await _neteaseSource.searchAlbums(keyword);
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
    if (isOfflineModeEnabled) {
      return searchLocalArtists(keyword);
    }
    final artists = sourceKey == _localMusicSource.sourceKey
        ? await _localMusicSource.searchArtists(keyword)
        : await _neteaseSource.searchArtists(keyword);
    await _localDataSource.saveArtists(artists);
    return artists;
  }

  /// 仅在本地曲库中搜索歌手。
  Future<List<ArtistEntity>> searchLocalArtists(String keyword) async {
    return _localDataSource.searchArtists(keyword);
  }

  /// 读取曲目；本地没有且未离线时才回源远程或本地扫描来源。
  Future<Track?> getTrack(String trackId) async {
    final localTrack = await _localDataSource.getTrack(trackId);
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

  /// 列出已登记的本地歌曲资源，可按资源来源过滤。
  Future<List<LocalSongEntry>> getLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) {
    return _resourceIndexRepository.listLocalSongs(origins: origins);
  }

  /// 解析曲目播放地址，优先返回仍存在的本地音频资源。
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

  /// 按音质偏好解析播放地址，优先返回仍存在的本地音频资源。
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
    final lyricsResource =
        (await _resourceIndexRepository.getTrackResourceBundle(trackId)).lyrics;
    if (lyricsResource != null &&
        await _touchIfLocalFileExists(lyricsResource)) {
      return TrackLyrics(
        main: await File(lyricsResource.path).readAsString(),
      );
    }
    final localLyrics = await _localDataSource.getLyrics(trackId);
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
      await _localDataSource.saveLyrics(trackId, lyrics);
    }
    return lyrics;
  }

  /// 保存曲目歌词缓存。
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    await _localDataSource.saveLyrics(trackId, lyrics);
  }

  /// 读取歌单；本地没有且未离线时才回源远程或本地扫描来源。
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final localPlaylist = await _localDataSource.getPlaylist(playlistId);
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
    await _localDataSource.removeLyrics(trackId);
    if (track.sourceType == SourceType.local) {
      await _localDataSource.removeTrack(trackId);
    }
  }

  /// 清理播放缓存来源的本地资源。
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
    await _resourceIndexRepository.touchResource(
        resource.trackId, resource.kind);
    return true;
  }

  bool _isLocalTrackId(String trackId) {
    return trackId.startsWith('${_localMusicSource.sourceKey}:');
  }

  bool _isLocalPlaylistId(String playlistId) {
    return playlistId.startsWith('${_localMusicSource.sourceKey}:');
  }
}
