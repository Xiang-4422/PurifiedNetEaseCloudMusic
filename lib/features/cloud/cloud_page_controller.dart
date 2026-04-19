import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:flutter/foundation.dart';

class CloudPageController {
  CloudPageController({
    CloudRepository? repository,
    required List<int> likedSongIds,
    this.pageSize = 30,
  })  : _repository = repository ?? CloudRepository(),
        _likedSongIds = likedSongIds;

  final CloudRepository _repository;
  final List<int> _likedSongIds;
  final int pageSize;
  final ValueNotifier<PagedState<MediaItem>> state =
      ValueNotifier(PagedState.initialLoading());

  int _offset = 0;

  Future<void> loadInitial() async {
    state.value = PagedState.initialLoading();
    await _reload();
  }

  Future<bool> refresh() async {
    state.value = state.value.copyWith(
      refreshing: true,
      error: null,
    );
    return _reload();
  }

  Future<bool> loadMore() async {
    final currentState = state.value;
    if (currentState.loadingMore || !currentState.hasMore) {
      return true;
    }
    state.value = currentState.copyWith(
      loadingMore: true,
      error: null,
    );
    try {
      final page = await _repository.fetchCloudSongs(
        offset: _offset,
        limit: pageSize,
        likedSongIds: _likedSongIds,
      );
      _offset = page.nextOffset;
      state.value = PagedState(
        items: [...currentState.items, ...page.items],
        hasMore: page.hasMore,
      );
      return true;
    } catch (error, stackTrace) {
      state.value = currentState.copyWith(
        loadingMore: false,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _reload() async {
    try {
      final page = await _repository.fetchCloudSongs(
        offset: 0,
        limit: pageSize,
        likedSongIds: _likedSongIds,
      );
      _offset = page.nextOffset;
      state.value = PagedState.data(
        page.items,
        hasMore: page.hasMore,
      );
      return true;
    } catch (error, stackTrace) {
      state.value = PagedState.error(
        error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void dispose() {
    state.dispose();
  }
}
