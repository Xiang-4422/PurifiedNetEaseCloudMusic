import 'dart:async';

import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:flutter/foundation.dart';

/// 云盘歌曲分页页面控制器。
class CloudPageController {
  /// 创建云盘页面控制器。
  CloudPageController({
    required CloudRepository repository,
    required String userId,
    required List<int> likedSongIds,
    this.pageSize = 30,
  })  : _repository = repository,
        _userId = userId,
        _likedSongIds = likedSongIds;

  final CloudRepository _repository;
  final String _userId;
  final List<int> _likedSongIds;

  /// 每次请求的云盘歌曲数量。
  final int pageSize;

  /// 云盘歌曲分页加载状态。
  final ValueNotifier<PagedState<PlaybackQueueItem>> state = ValueNotifier(PagedState.initialLoading());

  int _offset = 0;
  int _requestGeneration = 0;
  bool _disposed = false;

  /// 首次加载云盘歌曲，优先展示本地缓存。
  Future<void> loadInitial() async {
    if (_disposed) {
      return;
    }
    final generation = ++_requestGeneration;
    if (_userId.isEmpty) {
      _setStateIfCurrent(generation, const PagedState(items: [], hasMore: false));
      return;
    }
    final cachedSongs = await _repository.loadCachedSongs(
      userId: _userId,
      likedSongIds: _likedSongIds,
    );
    if (!_isCurrentRequest(generation)) {
      return;
    }
    if (cachedSongs.isNotEmpty) {
      _offset = cachedSongs.length;
      _setStateIfCurrent(
        generation,
        PagedState.data(
          cachedSongs,
          hasMore: true,
        ),
      );
      unawaited(refresh());
      return;
    }
    _setStateIfCurrent(generation, PagedState.initialLoading());
    await _reload(generation);
  }

  /// 刷新云盘第一页数据。
  Future<bool> refresh() async {
    if (_disposed) {
      return true;
    }
    final generation = ++_requestGeneration;
    _setStateIfCurrent(
      generation,
      state.value.copyWith(
        refreshing: true,
        error: null,
      ),
    );
    return _reload(generation);
  }

  /// 加载下一页云盘歌曲。
  Future<bool> loadMore() async {
    if (_disposed) {
      return true;
    }
    final currentState = state.value;
    if (currentState.initialLoading || currentState.refreshing || currentState.loadingMore || !currentState.hasMore) {
      return true;
    }
    final generation = _requestGeneration;
    _setStateIfCurrent(
      generation,
      currentState.copyWith(
        loadingMore: true,
        error: null,
      ),
    );
    try {
      final page = await _repository.fetchCloudSongs(
        userId: _userId,
        offset: _offset,
        limit: pageSize,
        likedSongIds: _likedSongIds,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _offset = page.nextOffset;
      _setStateIfCurrent(
        generation,
        PagedState(
          items: [...currentState.items, ...page.items],
          hasMore: page.hasMore,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _setStateIfCurrent(
        generation,
        currentState.copyWith(
          loadingMore: false,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  Future<bool> _reload(int generation) async {
    final currentState = state.value;
    try {
      final page = await _repository.fetchCloudSongs(
        userId: _userId,
        offset: 0,
        limit: pageSize,
        likedSongIds: _likedSongIds,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _offset = page.nextOffset;
      _setStateIfCurrent(
        generation,
        PagedState.data(
          page.items,
          hasMore: page.hasMore,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      if (currentState.items.isNotEmpty) {
        _setStateIfCurrent(
          generation,
          currentState.copyWith(
            initialLoading: false,
            refreshing: false,
            loadingMore: false,
            error: error,
            stackTrace: stackTrace,
          ),
        );
        return false;
      }
      _setStateIfCurrent(
        generation,
        PagedState.error(
          error,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  /// 释放页面状态监听器。
  void dispose() {
    _disposed = true;
    _requestGeneration++;
    state.dispose();
  }

  bool _isCurrentRequest(int generation) {
    return !_disposed && generation == _requestGeneration;
  }

  void _setStateIfCurrent(
    int generation,
    PagedState<PlaybackQueueItem> nextState,
  ) {
    if (_isCurrentRequest(generation)) {
      state.value = nextState;
    }
  }
}
