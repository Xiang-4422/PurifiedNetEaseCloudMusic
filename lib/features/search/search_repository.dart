import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/netease_search_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/features/search/search_cache_store.dart';

class SearchRepository {
  SearchRepository({
    required LibraryRepository libraryRepository,
    NeteaseSearchRemoteDataSource? remoteDataSource,
    required SearchCacheStore cacheStore,
    required UserScopedDataSource userScopedDataSource,
  })  : _libraryRepository = libraryRepository,
        _remoteDataSource =
            remoteDataSource ?? const NeteaseSearchRemoteDataSource(),
        _cacheStore = cacheStore,
        _userScopedDataSource = userScopedDataSource;

  final LibraryRepository _libraryRepository;
  final NeteaseSearchRemoteDataSource _remoteDataSource;
  final SearchCacheStore _cacheStore;
  final UserScopedDataSource _userScopedDataSource;

  Future<List<String>?> loadCachedHotKeywords() {
    return _cacheStore.loadHotKeywords();
  }

  Future<bool> isHotKeywordCacheFresh({
    required Duration ttl,
  }) {
    return _cacheStore.isHotKeywordsFresh(ttl: ttl);
  }

  Future<List<String>> fetchHotKeywords() async {
    final keywords = await _remoteDataSource.fetchHotKeywords();
    if (keywords.isNotEmpty) {
      await _cacheStore.saveHotKeywords(keywords);
    }
    return keywords;
  }

  Future<List<PlaybackQueueItem>> searchTrackQueueItems(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    final localTracks = await _libraryRepository.searchLocalTracks(keyword);
    if (_libraryRepository.isOfflineModeEnabled) {
      final localTrackItems = await _libraryRepository.getTracksWithResources(
        localTracks.map((track) => track.id),
      );
      return PlaybackQueueItemMapper.fromTrackWithResourcesList(
        localTrackItems,
        likedSongIds: likedSongIds,
      );
    }
    final remoteTracks = await _libraryRepository.searchTracks(
      sourceKey: 'netease',
      keyword: keyword,
    );
    final tracks = _mergeById(localTracks, remoteTracks, (track) => track.id);
    final trackItems = await _libraryRepository.getTracksWithResources(
      tracks.map((track) => track.id),
    );
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      trackItems,
      likedSongIds: likedSongIds,
    );
  }

  Future<List<PlaylistEntity>> searchPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    final localPlaylists =
        await _libraryRepository.searchLocalPlaylists(keyword);
    final userPlaylists = currentUserId.isEmpty
        ? const <PlaylistEntity>[]
        : (await _userScopedDataSource.searchPlaylistItems(
            currentUserId,
            keyword,
          ))
            .map(_playlistSummaryToEntity)
            .toList();
    final mergedLocalPlaylists = _mergeById(
      localPlaylists,
      userPlaylists,
      (playlist) => playlist.id,
    );
    if (_libraryRepository.isOfflineModeEnabled) {
      return mergedLocalPlaylists;
    }
    final remotePlaylists = await _libraryRepository.searchPlaylists(
      sourceKey: 'netease',
      keyword: keyword,
    );
    return _mergeById(
      mergedLocalPlaylists,
      remotePlaylists,
      (playlist) => playlist.id,
    );
  }

  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    final localAlbums = await _libraryRepository.searchLocalAlbums(keyword);
    if (_libraryRepository.isOfflineModeEnabled) {
      return localAlbums;
    }
    final remoteAlbums = await _libraryRepository.searchAlbums(
      sourceKey: 'netease',
      keyword: keyword,
    );
    return _mergeById(localAlbums, remoteAlbums, (album) => album.id);
  }

  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    final localArtists = await _libraryRepository.searchLocalArtists(keyword);
    if (_libraryRepository.isOfflineModeEnabled) {
      return localArtists;
    }
    final remoteArtists = await _libraryRepository.searchArtists(
      sourceKey: 'netease',
      keyword: keyword,
    );
    return _mergeById(localArtists, remoteArtists, (artist) => artist.id);
  }

  List<T> _mergeById<T>(
    List<T> localItems,
    List<T> remoteItems,
    String Function(T item) idOf,
  ) {
    final merged = <T>[];
    final seenIds = <String>{};
    for (final item in [...localItems, ...remoteItems]) {
      if (seenIds.add(idOf(item))) {
        merged.add(item);
      }
    }
    return merged;
  }

  PlaylistEntity _playlistSummaryToEntity(PlaylistSummaryData playlist) {
    return PlaylistEntity(
      id: 'netease:${playlist.id}',
      sourceType: SourceType.netease,
      sourceId: playlist.id,
      title: playlist.title,
      description: playlist.description,
      coverUrl: playlist.coverUrl,
      trackCount: playlist.trackCount,
    );
  }
}
