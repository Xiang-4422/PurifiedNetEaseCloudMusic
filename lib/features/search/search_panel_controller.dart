import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
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
  String _currentKeyword = '';
  int _searchGeneration = 0;

  /// 首次加载热搜关键词，可通过 `force` 强制刷新。
  Future<void> loadInitial({bool force = false}) async {
    if (_loadedOnce && !force) {
      return;
    }
    hotKeywordState.value = const LoadState.loading();
    hotKeywordState.value = await _loadInitialHotKeywords(force: force);
    _loadedOnce = hotKeywordState.value.hasData;
  }

  /// 搜索所有结果类型，空关键词会重置结果状态。
  Future<void> search(
    String keyword, {
    required List<int> likedSongIds,
    required String currentUserId,
    bool force = false,
  }) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      _currentKeyword = '';
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
    if (!force && normalizedKeyword == _currentKeyword) {
      return;
    }
    _currentKeyword = normalizedKeyword;
    final generation = ++_searchGeneration;
    songState.value = const LoadState.loading();
    playlistState.value = const LoadState.loading();
    albumState.value = const LoadState.loading();
    artistState.value = const LoadState.loading();
    final nextState = await _searchAll(
      normalizedKeyword,
      likedSongIds: likedSongIds,
      currentUserId: currentUserId,
    );
    if (generation != _searchGeneration || normalizedKeyword != _currentKeyword) {
      return;
    }
    _applySearchState(nextState);
  }

  Future<LoadState<List<String>>> _loadInitialHotKeywords({
    bool force = false,
  }) async {
    final cachedKeywords = await _repository.loadCachedHotKeywords();
    final shouldRefresh = force || !(await _repository.isHotKeywordCacheFresh(ttl: hotKeywordTtl)) || cachedKeywords == null || cachedKeywords.isEmpty;
    if (cachedKeywords != null && cachedKeywords.isNotEmpty && !shouldRefresh) {
      return LoadState.data(cachedKeywords);
    }
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

  Future<SearchResultState> _searchAll(
    String keyword, {
    required List<int> likedSongIds,
    required String currentUserId,
  }) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      return const SearchResultState(
        songs: LoadState.empty(),
        playlists: LoadState.empty(),
        albums: LoadState.empty(),
        artists: LoadState.empty(),
      );
    }
    final results = await Future.wait<LoadState<dynamic>>([
      _loadSongs(normalizedKeyword, likedSongIds: likedSongIds),
      _loadPlaylists(normalizedKeyword, currentUserId: currentUserId),
      _loadAlbums(normalizedKeyword),
      _loadArtists(normalizedKeyword),
    ]);
    return SearchResultState(
      songs: results[0] as LoadState<List<PlaybackQueueItem>>,
      playlists: results[1] as LoadState<List<PlaylistEntity>>,
      albums: results[2] as LoadState<List<AlbumEntity>>,
      artists: results[3] as LoadState<List<ArtistEntity>>,
    );
  }

  Future<LoadState<List<PlaybackQueueItem>>> _loadSongs(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    try {
      final songs = await _repository.searchTrackQueueItems(
        keyword,
        likedSongIds: likedSongIds,
      );
      return songs.isEmpty ? const LoadState.empty() : LoadState.data(songs);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<LoadState<List<PlaylistEntity>>> _loadPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    try {
      final playlists = await _repository.searchPlaylists(
        keyword,
        currentUserId: currentUserId,
      );
      return playlists.isEmpty ? const LoadState.empty() : LoadState.data(playlists);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<LoadState<List<AlbumEntity>>> _loadAlbums(String keyword) async {
    try {
      final albums = await _repository.searchAlbums(keyword);
      return albums.isEmpty ? const LoadState.empty() : LoadState.data(albums);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<LoadState<List<ArtistEntity>>> _loadArtists(String keyword) async {
    try {
      final artists = await _repository.searchArtists(keyword);
      return artists.isEmpty ? const LoadState.empty() : LoadState.data(artists);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  void _applySearchState(SearchResultState state) {
    songState.value = state.songs;
    playlistState.value = state.playlists;
    albumState.value = state.albums;
    artistState.value = state.artists;
  }

  /// 释放搜索面板状态监听器。
  void dispose() {
    hotKeywordState.dispose();
    songState.dispose();
    playlistState.dispose();
    albumState.dispose();
    artistState.dispose();
  }
}
