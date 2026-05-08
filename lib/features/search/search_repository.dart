import 'package:bujuan/data/music_data/sources/local/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_search_remote_data_source.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_mapper.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/search/search_cache_store.dart';

/// 搜索仓库，聚合本地曲库、网易云搜索和用户歌单缓存。
class SearchRepository {
  /// 创建搜索仓库。
  SearchRepository({
    required MusicDataRepository musicDataRepository,
    required NeteaseSearchRemoteDataSource remoteDataSource,
    required SearchCacheStore cacheStore,
    required UserScopedDataSource userScopedDataSource,
  })  : _musicDataRepository = musicDataRepository,
        _remoteDataSource = remoteDataSource,
        _cacheStore = cacheStore,
        _userScopedDataSource = userScopedDataSource;

  final MusicDataRepository _musicDataRepository;
  final NeteaseSearchRemoteDataSource _remoteDataSource;
  final SearchCacheStore _cacheStore;
  final UserScopedDataSource _userScopedDataSource;

  /// 加载缓存的热搜关键词。
  Future<List<String>?> loadCachedHotKeywords() {
    return _cacheStore.loadHotKeywords();
  }

  /// 判断热搜关键词缓存是否新鲜。
  Future<bool> isHotKeywordCacheFresh({
    required Duration ttl,
  }) {
    return _cacheStore.isHotKeywordsFresh(ttl: ttl);
  }

  /// 获取远程热搜关键词并写入缓存。
  Future<List<String>> fetchHotKeywords() async {
    final keywords = await _remoteDataSource.fetchHotKeywords();
    if (keywords.isNotEmpty) {
      await _cacheStore.saveHotKeywords(keywords);
    }
    return keywords;
  }

  /// 搜索曲目并转换为播放队列项。
  Future<List<PlaybackQueueItem>> searchTrackQueueItems(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    final localTracks = await _musicDataRepository.searchLocalTracks(keyword);
    final remoteTracks = await _musicDataRepository.searchTracks(
      sourceKey: 'netease',
      keyword: keyword,
    );
    final tracks = _mergeById(localTracks, remoteTracks, (track) => track.id);
    final trackItems = await _musicDataRepository.getTracksWithResources(
      tracks.map((track) => track.id),
    );
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      trackItems,
      likedSongIds: likedSongIds,
    );
  }

  /// 搜索歌单，合并本地歌单、用户歌单和远程歌单。
  Future<List<PlaylistEntity>> searchPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    final localPlaylists = await _musicDataRepository.searchLocalPlaylists(keyword);
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
    final remotePlaylists = await _musicDataRepository.searchPlaylists(
      sourceKey: 'netease',
      keyword: keyword,
    );
    return _mergeById(
      mergedLocalPlaylists,
      remotePlaylists,
      (playlist) => playlist.id,
    );
  }

  /// 搜索专辑。
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    final localAlbums = await _musicDataRepository.searchLocalAlbums(keyword);
    final remoteAlbums = await _musicDataRepository.searchAlbums(
      sourceKey: 'netease',
      keyword: keyword,
    );
    return _mergeById(localAlbums, remoteAlbums, (album) => album.id);
  }

  /// 搜索歌手。
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    final localArtists = await _musicDataRepository.searchLocalArtists(keyword);
    final remoteArtists = await _musicDataRepository.searchArtists(
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
