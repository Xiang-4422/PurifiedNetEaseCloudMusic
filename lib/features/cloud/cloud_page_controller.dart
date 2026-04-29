import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
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
  final ValueNotifier<PagedState<PlaybackQueueItem>> state =
      ValueNotifier(PagedState.initialLoading());

  int _offset = 0;

  /// 首次加载云盘歌曲，优先展示本地缓存。
  Future<void> loadInitial() async {
    if (_userId.isEmpty) {
      state.value = const PagedState(items: [], hasMore: false);
      return;
    }
    final cachedSongs = await _repository.loadCachedSongs(
      userId: _userId,
      likedSongIds: _likedSongIds,
    );
    if (cachedSongs.isNotEmpty) {
      _offset = cachedSongs.length;
      state.value = PagedState.data(
        cachedSongs,
        hasMore: true,
      );
      unawaited(refresh());
      return;
    }
    state.value = PagedState.initialLoading();
    await _reload();
  }

  /// 刷新云盘第一页数据。
  Future<bool> refresh() async {
    state.value = state.value.copyWith(
      refreshing: true,
      error: null,
    );
    return _reload();
  }

  /// 加载下一页云盘歌曲。
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
        userId: _userId,
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
        userId: _userId,
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

  /// 释放页面状态监听器。
  void dispose() {
    state.dispose();
  }
}
