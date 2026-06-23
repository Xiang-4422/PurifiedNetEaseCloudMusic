import 'dart:async';

import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/features/radio/radio_playback_queue_item_mapper.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:flutter/foundation.dart';

/// 电台节目分页控制器。
class RadioDetailController {
  /// 创建电台详情控制器。
  RadioDetailController({
    required this.radioId,
    required String userId,
    required RadioRepository repository,
    List<int> Function()? likedSongIds,
    this.pageSize = 30,
    this.asc = true,
  })  : _userId = userId,
        _repository = repository,
        _likedSongIds = likedSongIds ?? _currentLikedSongIds;

  /// 电台 id。
  final String radioId;
  final String _userId;
  final RadioRepository _repository;
  final List<int> Function() _likedSongIds;

  /// 每页节目数量。
  final int pageSize;

  /// 节目排序是否为升序。
  final bool asc;

  /// 电台节目分页状态。
  final ValueNotifier<PagedState<RadioProgramData>> state = ValueNotifier(PagedState.initialLoading());

  /// 当前节目列表对应的播放队列项。
  List<PlaybackQueueItem> get queueItems {
    return RadioPlaybackQueueItemMapper.fromPrograms(
      state.value.items,
      likedSongIds: _likedSongIds(),
    );
  }

  int _offset = 0;
  int _requestGeneration = 0;
  bool _disposed = false;

  /// 首次加载节目列表，优先展示缓存。
  Future<void> loadInitial() async {
    if (_disposed) {
      return;
    }
    final generation = ++_requestGeneration;
    if (_userId.isEmpty) {
      state.value = const PagedState(items: [], hasMore: false);
      return;
    }
    final List<RadioProgramData> cachedItems;
    try {
      cachedItems = await _repository.loadCachedPrograms(
        _userId,
        radioId,
        asc: asc,
      );
    } catch (_) {
      if (!_isCurrentRequest(generation)) {
        return;
      }
      state.value = PagedState.initialLoading();
      await _reload();
      return;
    }
    if (!_isCurrentRequest(generation)) {
      return;
    }
    if (cachedItems.isNotEmpty) {
      _offset = cachedItems.length;
      state.value = PagedState.data(
        cachedItems,
        hasMore: true,
      );
      unawaited(refresh());
      return;
    }
    state.value = PagedState.initialLoading();
    await _reload();
  }

  /// 刷新节目第一页。
  Future<bool> refresh() async {
    if (_disposed) {
      return true;
    }
    state.value = state.value.copyWith(
      refreshing: true,
      error: null,
    );
    return _reload();
  }

  /// 加载下一页节目。
  Future<bool> loadMore() async {
    if (_disposed) {
      return true;
    }
    final currentState = state.value;
    if (currentState.initialLoading || currentState.refreshing || currentState.loadingMore || !currentState.hasMore) {
      return true;
    }
    final generation = _requestGeneration;
    state.value = currentState.copyWith(
      loadingMore: true,
      error: null,
    );
    try {
      final page = await _repository.fetchPrograms(
        _userId,
        radioId,
        offset: _offset,
        limit: pageSize,
        asc: asc,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _offset = page.nextOffset;
      state.value = PagedState(
        items: [...currentState.items, ...page.items],
        hasMore: page.hasMore,
      );
      return true;
    } catch (error, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      state.value = currentState.copyWith(
        loadingMore: false,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _reload() async {
    if (_disposed) {
      return true;
    }
    final generation = ++_requestGeneration;
    final currentState = state.value;
    try {
      final page = await _repository.fetchPrograms(
        _userId,
        radioId,
        offset: 0,
        limit: pageSize,
        asc: asc,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _offset = page.nextOffset;
      state.value = PagedState.data(
        page.items,
        hasMore: page.hasMore,
      );
      return true;
    } catch (error, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      if (currentState.items.isNotEmpty) {
        state.value = currentState.copyWith(
          initialLoading: false,
          refreshing: false,
          loadingMore: false,
          error: error,
          stackTrace: stackTrace,
        );
        return false;
      }
      state.value = PagedState.error(
        error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 释放节目列表状态监听器。
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _requestGeneration++;
    state.dispose();
  }

  bool _isCurrentRequest(int generation) {
    return !_disposed && generation == _requestGeneration;
  }

  static List<int> _currentLikedSongIds() {
    return UserLibraryController.to.likedSongIds.toList();
  }
}
