import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/search/application/search_application_service.dart';
import 'package:flutter/foundation.dart';

/// 顶部搜索面板只需要维护一次热搜加载状态，单独拆出来可以避免页面在
/// build 阶段继续构造请求描述，也能避免同一面板反复触发首屏请求。
class SearchPanelController {
  /// 创建 SearchPanelController。
  SearchPanelController({required SearchApplicationService service})
      : _service = service;

  final SearchApplicationService _service;

  /// hotKeywordState。
  final ValueNotifier<LoadState<List<String>>> hotKeywordState =
      ValueNotifier(const LoadState.loading());

  /// songState。
  final ValueNotifier<LoadState<List<PlaybackQueueItem>>> songState =
      ValueNotifier(const LoadState.empty());

  /// playlistState。
  final ValueNotifier<LoadState<List<PlaylistEntity>>> playlistState =
      ValueNotifier(const LoadState.empty());

  /// albumState。
  final ValueNotifier<LoadState<List<AlbumEntity>>> albumState =
      ValueNotifier(const LoadState.empty());

  /// artistState。
  final ValueNotifier<LoadState<List<ArtistEntity>>> artistState =
      ValueNotifier(const LoadState.empty());

  bool _loadedOnce = false;
  String _currentKeyword = '';

  /// loadInitial。
  Future<void> loadInitial({bool force = false}) async {
    if (_loadedOnce && !force) {
      return;
    }
    hotKeywordState.value = const LoadState.loading();
    hotKeywordState.value = await _service.loadInitialHotKeywords(force: force);
    _loadedOnce = hotKeywordState.value.hasData;
  }

  /// search。
  Future<void> search(
    String keyword, {
    required List<int> likedSongIds,
    required String currentUserId,
    bool force = false,
  }) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      _currentKeyword = '';
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
    songState.value = const LoadState.loading();
    playlistState.value = const LoadState.loading();
    albumState.value = const LoadState.loading();
    artistState.value = const LoadState.loading();
    _applySearchState(
      await _service.searchAll(
        normalizedKeyword,
        likedSongIds: likedSongIds,
        currentUserId: currentUserId,
      ),
    );
  }

  void _applySearchState(SearchResultState state) {
    songState.value = state.songs;
    playlistState.value = state.playlists;
    albumState.value = state.albums;
    artistState.value = state.artists;
  }

  /// dispose。
  void dispose() {
    hotKeywordState.dispose();
    songState.dispose();
    playlistState.dispose();
    albumState.dispose();
    artistState.dispose();
  }
}
