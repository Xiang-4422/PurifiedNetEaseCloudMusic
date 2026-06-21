import 'package:bujuan/core/diagnostics/performance_logger.dart';
import 'package:bujuan/core/diagnostics/performance_metric.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:flutter/foundation.dart';

/// 搜索结果状态。
class SearchResultState {
  /// 创建搜索结果状态。
  const SearchResultState({
    required this.songs,
    required this.playlists,
    required this.albums,
    required this.artists,
  });

  /// 歌曲搜索状态。
  final LoadState<List<PlaybackQueueItem>> songs;

  /// 歌单搜索状态。
  final LoadState<List<PlaylistEntity>> playlists;

  /// 专辑搜索状态。
  final LoadState<List<AlbumEntity>> albums;

  /// 歌手搜索状态。
  final LoadState<List<ArtistEntity>> artists;
}

/// 顶部搜索面板只需要维护一次热搜加载状态，单独拆出来可以避免页面在
/// build 阶段继续构造请求描述，也能避免同一面板反复触发首屏请求。
class SearchPanelController {
  /// 创建搜索面板控制器。
  SearchPanelController({required SearchRepository repository}) : _repository = repository;

  final SearchRepository _repository;

  /// 热搜关键词缓存 TTL。
  static const Duration hotKeywordTtl = Duration(minutes: 30);

  /// 热搜关键词加载状态。
  final ValueNotifier<LoadState<List<String>>> hotKeywordState = ValueNotifier(const LoadState.loading());

  /// 歌曲搜索结果加载状态。
  final ValueNotifier<LoadState<List<PlaybackQueueItem>>> songState = ValueNotifier(const LoadState.empty());

  /// 歌单搜索结果加载状态。
  final ValueNotifier<LoadState<List<PlaylistEntity>>> playlistState = ValueNotifier(const LoadState.empty());

  /// 专辑搜索结果加载状态。
  final ValueNotifier<LoadState<List<AlbumEntity>>> albumState = ValueNotifier(const LoadState.empty());

  /// 歌手搜索结果加载状态。
  final ValueNotifier<LoadState<List<ArtistEntity>>> artistState = ValueNotifier(const LoadState.empty());

  bool _loadedOnce = false;
  bool _disposed = false;
  String _currentKeyword = '';
  String _currentUserId = '';
  String _currentLikedSongIdsSignature = '';
  int _hotKeywordGeneration = 0;
  int _searchGeneration = 0;

  /// 首次加载热搜关键词，可通过 `force` 强制刷新。
  Future<void> loadInitial({bool force = false}) async {
    if (_disposed || (_loadedOnce && !force)) {
      return;
    }
    final generation = ++_hotKeywordGeneration;
    final cachedKeywords = await _repository.loadCachedHotKeywords();
    if (!_isCurrentHotKeywordLoad(generation)) {
      return;
    }
    final hasCachedKeywords = cachedKeywords != null && cachedKeywords.isNotEmpty;
    if (hasCachedKeywords) {
      hotKeywordState.value = LoadState.data(cachedKeywords);
      _loadedOnce = true;
    } else {
      hotKeywordState.value = const LoadState.loading();
    }
    final cacheFresh = hasCachedKeywords && await _repository.isHotKeywordCacheFresh(ttl: hotKeywordTtl);
    if (!_isCurrentHotKeywordLoad(generation)) {
      return;
    }
    final shouldRefresh = force || !cacheFresh || !hasCachedKeywords;
    if (!shouldRefresh) {
      return;
    }
    final state = await _fetchHotKeywords(cachedKeywords: cachedKeywords);
    if (!_isCurrentHotKeywordLoad(generation)) {
      return;
    }
    hotKeywordState.value = state;
    _loadedOnce = state.hasData;
  }

  /// 搜索所有结果类型，空关键词会重置结果状态。
  Future<void> search(
    String keyword, {
    required List<int> likedSongIds,
    required String currentUserId,
    bool force = false,
  }) async {
    if (_disposed) {
      return;
    }
    final normalizedKeyword = keyword.trim();
    final likedSongIdsSignature = _likedSongIdsSignature(likedSongIds);
    if (normalizedKeyword.isEmpty) {
      _currentKeyword = '';
      _currentUserId = '';
      _currentLikedSongIdsSignature = '';
      _searchGeneration++;
      _applySearchState(
        const SearchResultState(
          songs: LoadState.empty(),
          playlists: LoadState.empty(),
          albums: LoadState.empty(),
          artists: LoadState.empty(),
        ),
      );
      return;
    }
    final sameKeyword = normalizedKeyword == _currentKeyword;
    final sameUser = currentUserId == _currentUserId;
    final sameSearchContext = sameKeyword && sameUser && likedSongIdsSignature == _currentLikedSongIdsSignature;
    if (!force && sameSearchContext) {
      return;
    }
    final canReusePreviousItems = sameKeyword && sameUser;
    final previousSongs = canReusePreviousItems ? songState.value.data : null;
    final previousPlaylists = canReusePreviousItems ? playlistState.value.data : null;
    final previousAlbums = canReusePreviousItems ? albumState.value.data : null;
    final previousArtists = canReusePreviousItems ? artistState.value.data : null;
    _currentKeyword = normalizedKeyword;
    _currentUserId = currentUserId;
    _currentLikedSongIdsSignature = likedSongIdsSignature;
    final generation = ++_searchGeneration;
    songState.value = _loadingState(previousSongs);
    playlistState.value = _loadingState(previousPlaylists);
    albumState.value = _loadingState(previousAlbums);
    artistState.value = _loadingState(previousArtists);
    final stopwatch = PerformanceLogger.start();

    var loggedFirstResult = false;
    void applyIfCurrent({
      required VoidCallback apply,
      required String category,
      required int count,
      required bool logAsFirstResult,
    }) {
      if (!_isCurrentSearch(
        generation,
        normalizedKeyword,
        currentUserId,
        likedSongIdsSignature,
      )) {
        return;
      }
      apply();
      if (loggedFirstResult || !logAsFirstResult) {
        return;
      }
      loggedFirstResult = true;
      PerformanceLogger.elapsedMetric(
        AppPerformanceMetrics.searchFirstResults,
        stopwatch,
        details: 'category=$category keywordLength=${normalizedKeyword.length} count=$count',
      );
    }

    await Future.wait<void>([
      _loadSongs(
        normalizedKeyword,
        likedSongIds: likedSongIds,
        previousItems: previousSongs,
      ).then((state) {
        applyIfCurrent(
          apply: () => songState.value = state,
          category: 'songs',
          count: state.data?.length ?? 0,
          logAsFirstResult: state.status == LoadStatus.data,
        );
      }),
      _loadPlaylists(
        normalizedKeyword,
        currentUserId: currentUserId,
        previousItems: previousPlaylists,
      ).then((state) {
        applyIfCurrent(
          apply: () => playlistState.value = state,
          category: 'playlists',
          count: state.data?.length ?? 0,
          logAsFirstResult: state.status == LoadStatus.data,
        );
      }),
      _loadAlbums(
        normalizedKeyword,
        previousItems: previousAlbums,
      ).then((state) {
        applyIfCurrent(
          apply: () => albumState.value = state,
          category: 'albums',
          count: state.data?.length ?? 0,
          logAsFirstResult: state.status == LoadStatus.data,
        );
      }),
      _loadArtists(
        normalizedKeyword,
        previousItems: previousArtists,
      ).then((state) {
        applyIfCurrent(
          apply: () => artistState.value = state,
          category: 'artists',
          count: state.data?.length ?? 0,
          logAsFirstResult: state.status == LoadStatus.data,
        );
      }),
    ]);
  }

  Future<LoadState<List<String>>> _fetchHotKeywords({
    required List<String>? cachedKeywords,
  }) async {
    try {
      final keywords = await _repository.fetchHotKeywords();
      if (keywords.isEmpty) {
        return const LoadState.empty();
      }
      return LoadState.data(keywords);
    } catch (error, stackTrace) {
      if (cachedKeywords != null && cachedKeywords.isNotEmpty) {
        return LoadState.data(cachedKeywords);
      }
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<LoadState<List<PlaybackQueueItem>>> _loadSongs(
    String keyword, {
    required List<int> likedSongIds,
    required List<PlaybackQueueItem>? previousItems,
  }) async {
    try {
      final songs = await _repository.searchTrackQueueItems(
        keyword,
        likedSongIds: likedSongIds,
      );
      return songs.isEmpty ? const LoadState.empty() : LoadState.data(songs);
    } catch (error, stackTrace) {
      return _errorState(error, stackTrace, previousItems);
    }
  }

  Future<LoadState<List<PlaylistEntity>>> _loadPlaylists(
    String keyword, {
    required String currentUserId,
    required List<PlaylistEntity>? previousItems,
  }) async {
    try {
      final playlists = await _repository.searchPlaylists(
        keyword,
        currentUserId: currentUserId,
      );
      return playlists.isEmpty ? const LoadState.empty() : LoadState.data(playlists);
    } catch (error, stackTrace) {
      return _errorState(error, stackTrace, previousItems);
    }
  }

  Future<LoadState<List<AlbumEntity>>> _loadAlbums(
    String keyword, {
    required List<AlbumEntity>? previousItems,
  }) async {
    try {
      final albums = await _repository.searchAlbums(keyword);
      return albums.isEmpty ? const LoadState.empty() : LoadState.data(albums);
    } catch (error, stackTrace) {
      return _errorState(error, stackTrace, previousItems);
    }
  }

  Future<LoadState<List<ArtistEntity>>> _loadArtists(
    String keyword, {
    required List<ArtistEntity>? previousItems,
  }) async {
    try {
      final artists = await _repository.searchArtists(keyword);
      return artists.isEmpty ? const LoadState.empty() : LoadState.data(artists);
    } catch (error, stackTrace) {
      return _errorState(error, stackTrace, previousItems);
    }
  }

  LoadState<List<T>> _loadingState<T>(List<T>? previousItems) {
    return previousItems == null || previousItems.isEmpty ? const LoadState.loading() : LoadState.loading(data: previousItems);
  }

  LoadState<List<T>> _errorState<T>(
    Object error,
    StackTrace stackTrace,
    List<T>? previousItems,
  ) {
    return previousItems == null || previousItems.isEmpty
        ? LoadState.error(error, stackTrace: stackTrace)
        : LoadState.error(
            error,
            stackTrace: stackTrace,
            data: previousItems,
          );
  }

  bool _isCurrentHotKeywordLoad(int generation) {
    return !_disposed && generation == _hotKeywordGeneration;
  }

  bool _isCurrentSearch(
    int generation,
    String keyword,
    String userId,
    String likedSongIdsSignature,
  ) {
    return !_disposed && generation == _searchGeneration && keyword == _currentKeyword && userId == _currentUserId && likedSongIdsSignature == _currentLikedSongIdsSignature;
  }

  void _applySearchState(SearchResultState state) {
    songState.value = state.songs;
    playlistState.value = state.playlists;
    albumState.value = state.albums;
    artistState.value = state.artists;
  }

  /// 取消当前面板生命周期内仍在等待的热词和搜索请求。
  void cancelPendingRequests() {
    if (_disposed) {
      return;
    }
    _hotKeywordGeneration++;
    _searchGeneration++;
    _currentKeyword = '';
    _currentUserId = '';
    _currentLikedSongIdsSignature = '';
  }

  /// 释放搜索面板状态监听器。
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _hotKeywordGeneration++;
    _searchGeneration++;
    hotKeywordState.dispose();
    songState.dispose();
    playlistState.dispose();
    albumState.dispose();
    artistState.dispose();
  }
}

String _likedSongIdsSignature(List<int> likedSongIds) {
  final normalizedIds = likedSongIds.toSet().toList()..sort();
  return normalizedIds.join(',');
}
