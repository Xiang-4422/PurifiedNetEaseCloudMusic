import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';

/// 探索页应用服务，集中组合探索接口、歌单详情和播放入口。
class ExploreApplicationService {
  /// 创建 ExploreApplicationService。
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

  /// loadCachedPlaylistCatalogue。
  Future<ExplorePlaylistCatalogueData?> loadCachedPlaylistCatalogue() {
    return _exploreRepository.loadCachedPlaylistCatalogue();
  }

  /// isPlaylistCatalogueFresh。
  Future<bool> isPlaylistCatalogueFresh({required Duration ttl}) {
    return _exploreRepository.isPlaylistCatalogueFresh(ttl: ttl);
  }

  /// fetchPlaylistCatalogue。
  Future<ExplorePlaylistCatalogueData> fetchPlaylistCatalogue() {
    return _exploreRepository.fetchPlaylistCatalogue();
  }

  /// loadCachedCategoryPlaylists。
  Future<List<PlaylistSummaryData>?> loadCachedCategoryPlaylists(String tag) {
    return _exploreRepository.loadCachedCategoryPlaylists(tag);
  }

  /// isCategoryPlaylistsFresh。
  Future<bool> isCategoryPlaylistsFresh(
    String tag, {
    required Duration ttl,
  }) {
    return _exploreRepository.isCategoryPlaylistsFresh(tag, ttl: ttl);
  }

  /// fetchCategoryPlaylists。
  Future<List<PlaylistSummaryData>> fetchCategoryPlaylists(String tag) {
    return _exploreRepository.fetchCategoryPlaylists(tag);
  }

  /// isRankingPlaylistFresh。
  Future<bool> isRankingPlaylistFresh(
    String playlistId, {
    required Duration ttl,
  }) {
    return _playlistRepository.isCacheFresh(playlistId, ttl: ttl);
  }

  /// loadCachedRankingSongs。
  Future<List<PlaybackQueueItem>> loadCachedRankingSongs(
      String playlistId) async {
    final cachedDetail = await _playlistRepository.loadLocalPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
    );
    return cachedDetail?.songs ?? const <PlaybackQueueItem>[];
  }

  /// fetchRankingSongs。
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

  /// playRankingSongs。
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
