import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:flutter/foundation.dart';

/// 顶部搜索面板只需要维护一次热搜加载状态，单独拆出来可以避免页面在
/// build 阶段继续构造请求描述，也能避免同一面板反复触发首屏请求。
class SearchPanelController {
  SearchPanelController({required SearchRepository repository})
      : _repository = repository;

  static const Duration _hotKeywordTtl = Duration(minutes: 30);

  final SearchRepository _repository;
  final ValueNotifier<LoadState<List<String>>> hotKeywordState =
      ValueNotifier(const LoadState.loading());
  final ValueNotifier<LoadState<List<PlaybackQueueItem>>> songState =
      ValueNotifier(const LoadState.empty());
  final ValueNotifier<LoadState<List<PlaylistEntity>>> playlistState =
      ValueNotifier(const LoadState.empty());
  final ValueNotifier<LoadState<List<AlbumEntity>>> albumState =
      ValueNotifier(const LoadState.empty());
  final ValueNotifier<LoadState<List<ArtistEntity>>> artistState =
      ValueNotifier(const LoadState.empty());

  bool _loadedOnce = false;
  String _currentKeyword = '';

  Future<void> loadInitial({bool force = false}) async {
    if (_loadedOnce && !force) {
      return;
    }
    final cachedKeywords = await _repository.loadCachedHotKeywords();
    final shouldRefresh = force ||
        !(await _repository.isHotKeywordCacheFresh(ttl: _hotKeywordTtl)) ||
        cachedKeywords == null ||
        cachedKeywords.isEmpty;
    if (cachedKeywords != null && cachedKeywords.isNotEmpty) {
      hotKeywordState.value = LoadState.data(cachedKeywords);
      _loadedOnce = true;
      if (!shouldRefresh) {
        return;
      }
    } else {
      hotKeywordState.value = const LoadState.loading();
    }
    try {
      final keywords = await _repository.fetchHotKeywords();
      hotKeywordState.value =
          keywords.isEmpty ? const LoadState.empty() : LoadState.data(keywords);
      _loadedOnce = true;
    } catch (error, stackTrace) {
      if (cachedKeywords == null || cachedKeywords.isEmpty) {
        hotKeywordState.value = LoadState.error(error, stackTrace: stackTrace);
      }
    }
  }

  Future<void> search(
    String keyword, {
    required List<int> likedSongIds,
    required String currentUserId,
    bool force = false,
  }) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      _currentKeyword = '';
      songState.value = const LoadState.empty();
      playlistState.value = const LoadState.empty();
      albumState.value = const LoadState.empty();
      artistState.value = const LoadState.empty();
      return;
    }
    if (!force && normalizedKeyword == _currentKeyword) {
      return;
    }
    _currentKeyword = normalizedKeyword;
    songState.value = const LoadState.loading();
    playlistState.value = const LoadState.loading();
    albumState.value = const LoadState.loading();
    artistState.value = const LoadState.loading();
    await Future.wait([
      _loadSongs(normalizedKeyword, likedSongIds: likedSongIds),
      _loadPlaylists(normalizedKeyword, currentUserId: currentUserId),
      _loadAlbums(normalizedKeyword),
      _loadArtists(normalizedKeyword),
    ]);
  }

  Future<void> _loadSongs(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    try {
      final songs = await _repository.searchTrackQueueItems(
        keyword,
        likedSongIds: likedSongIds,
      );
      songState.value =
          songs.isEmpty ? const LoadState.empty() : LoadState.data(songs);
    } catch (error, stackTrace) {
      songState.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<void> _loadPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    try {
      final playlists = await _repository.searchPlaylists(
        keyword,
        currentUserId: currentUserId,
      );
      playlistState.value = playlists.isEmpty
          ? const LoadState.empty()
          : LoadState.data(playlists);
    } catch (error, stackTrace) {
      playlistState.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<void> _loadAlbums(String keyword) async {
    try {
      final albums = await _repository.searchAlbums(keyword);
      albumState.value =
          albums.isEmpty ? const LoadState.empty() : LoadState.data(albums);
    } catch (error, stackTrace) {
      albumState.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<void> _loadArtists(String keyword) async {
    try {
      final artists = await _repository.searchArtists(keyword);
      artistState.value =
          artists.isEmpty ? const LoadState.empty() : LoadState.data(artists);
    } catch (error, stackTrace) {
      artistState.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  void dispose() {
    hotKeywordState.dispose();
    songState.dispose();
    playlistState.dispose();
    albumState.dispose();
    artistState.dispose();
  }
}
