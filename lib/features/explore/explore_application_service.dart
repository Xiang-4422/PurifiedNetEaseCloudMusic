import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';

/// 探索页应用服务，集中组合探索接口、歌单详情和播放入口。
class ExploreApplicationService {
  /// 创建探索页应用服务。
  ExploreApplicationService({
    required ExploreRepository exploreRepository,
    required PlaylistRepository playlistRepository,
    required List<int> Function() likedSongIds,
    required String Function() currentUserId,
    required Future<void> Function(
      List<PlaybackQueueItem> playlist,
      int index, {
      required String playListName,
      String playListNameHeader,
    }) playPlaylist,
  })  : _exploreRepository = exploreRepository,
        _playlistRepository = playlistRepository,
        _likedSongIds = likedSongIds,
        _currentUserId = currentUserId,
        _playPlaylist = playPlaylist;

  final ExploreRepository _exploreRepository;
  final PlaylistRepository _playlistRepository;
  final List<int> Function() _likedSongIds;
  final String Function() _currentUserId;
  final Future<void> Function(
    List<PlaybackQueueItem> playlist,
    int index, {
    required String playListName,
    String playListNameHeader,
  }) _playPlaylist;

  /// 读取缓存的歌单分类目录。
  Future<ExplorePlaylistCatalogueData?> loadCachedPlaylistCatalogue() {
    return _exploreRepository.loadCachedPlaylistCatalogue();
  }

  /// 判断歌单分类目录缓存是否仍在 TTL 内。
  Future<bool> isPlaylistCatalogueFresh({required Duration ttl}) {
    return _exploreRepository.isPlaylistCatalogueFresh(ttl: ttl);
  }

  /// 拉取最新歌单分类目录。
  Future<ExplorePlaylistCatalogueData> fetchPlaylistCatalogue() {
    return _exploreRepository.fetchPlaylistCatalogue();
  }

  /// 读取指定分类下缓存的歌单列表。
  Future<List<PlaylistSummaryData>?> loadCachedCategoryPlaylists(String tag) {
    return _exploreRepository.loadCachedCategoryPlaylists(tag);
  }

  /// 判断指定分类歌单缓存是否仍在 TTL 内。
  Future<bool> isCategoryPlaylistsFresh(
    String tag, {
    required Duration ttl,
  }) {
    return _exploreRepository.isCategoryPlaylistsFresh(tag, ttl: ttl);
  }

  /// 拉取指定分类下的歌单列表。
  Future<List<PlaylistSummaryData>> fetchCategoryPlaylists(String tag) {
    return _exploreRepository.fetchCategoryPlaylists(tag);
  }

  /// 判断排行榜歌单缓存是否仍在 TTL 内。
  Future<bool> isRankingPlaylistFresh(
    String playlistId, {
    required Duration ttl,
  }) {
    return _playlistRepository.isCacheFresh(playlistId, ttl: ttl);
  }

  /// 读取缓存的排行榜歌曲队列。
  Future<List<PlaybackQueueItem>> loadCachedRankingSongs(
      String playlistId) async {
    final cachedDetail = await _playlistRepository.loadLocalPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
    );
    return cachedDetail?.songs ?? const <PlaybackQueueItem>[];
  }

  /// 拉取排行榜歌曲队列。
  Future<List<PlaybackQueueItem>> fetchRankingSongs(
    String playlistId, {
    int offset = 0,
    int limit = 10,
  }) {
    return _playlistRepository.fetchPlaylistSongs(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      offset: offset,
      limit: limit,
    );
  }

  /// 从首曲开始播放排行榜歌曲。
  Future<void> playRankingSongs(
    List<PlaybackQueueItem> songs, {
    required String playlistName,
  }) {
    return _playPlaylist(
      songs,
      0,
      playListName: playlistName,
    );
  }
}
