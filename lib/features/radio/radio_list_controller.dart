import 'dart:async';

import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:flutter/foundation.dart';

/// 用户订阅电台分页控制器。
class RadioListController {
  /// 创建电台列表控制器。
  RadioListController({
    required String userId,
    required RadioRepository repository,
    this.pageSize = 30,
  })  : _userId = _normalizedUserId(userId),
        _repository = repository;

  final String _userId;
  final RadioRepository _repository;

  /// 每页电台数量。
  final int pageSize;

  /// 订阅电台分页状态。
  final ValueNotifier<PagedState<RadioSummaryData>> state = ValueNotifier(PagedState.initialLoading());

  int _offset = 0;
  int _requestGeneration = 0;
  bool _disposed = false;

  /// 首次加载订阅电台，优先展示缓存。
  Future<void> loadInitial() async {
    if (_disposed) {
      return;
    }
    final generation = ++_requestGeneration;
    if (!_hasUserId) {
      _offset = 0;
      state.value = const PagedState(items: [], hasMore: false);
      return;
    }
    final List<RadioSummaryData> cachedItems;
    try {
      cachedItems = await _repository.loadCachedSubscribedRadios(_userId);
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

  /// 刷新订阅电台第一页。
  Future<bool> refresh() async {
    if (_disposed) {
      return true;
    }
    if (!_hasUserId) {
      _requestGeneration++;
      _offset = 0;
      state.value = const PagedState(items: [], hasMore: false);
      return true;
    }
    state.value = state.value.copyWith(
      refreshing: true,
      error: null,
    );
    return _reload();
  }

  /// 加载下一页订阅电台。
  Future<bool> loadMore() async {
    if (_disposed) {
      return true;
    }
    if (!_hasUserId) {
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
      final page = await _repository.fetchSubscribedRadios(
        userId: _userId,
        offset: _offset,
        limit: pageSize,
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
      final page = await _repository.fetchSubscribedRadios(
        userId: _userId,
        offset: 0,
        limit: pageSize,
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

  /// 释放订阅电台状态监听器。
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

  bool get _hasUserId => _userId.isNotEmpty;

  static String _normalizedUserId(String userId) {
    return userId.trim();
  }
}
