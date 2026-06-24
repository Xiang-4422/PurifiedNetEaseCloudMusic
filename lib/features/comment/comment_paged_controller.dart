import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:flutter/foundation.dart';

/// 评论分页结果。
class CommentPagedPage<C> {
  /// 创建评论分页结果。
  const CommentPagedPage({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
  });

  /// 当前页评论。
  final List<CommentData> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页游标。
  final C nextCursor;
}

/// 评论分页数据加载函数。
typedef CommentPagedLoader<C> = Future<CommentPagedPage<C>> Function({
  required C cursor,
  required bool forceRefresh,
});

/// 评论分页状态控制器，统一处理刷新、加载更多、错误保留和过期请求丢弃。
class CommentPagedController<C> {
  /// 创建评论分页状态控制器。
  CommentPagedController({
    required C firstCursor,
    required CommentPagedLoader<C> loadPage,
    bool skipRepeatedInitialLoad = false,
  })  : _firstCursor = firstCursor,
        _cursor = firstCursor,
        _loadPage = loadPage,
        _skipRepeatedInitialLoad = skipRepeatedInitialLoad;

  final C _firstCursor;
  final CommentPagedLoader<C> _loadPage;
  final bool _skipRepeatedInitialLoad;

  /// 评论分页加载状态。
  final ValueNotifier<PagedState<CommentData>> state = ValueNotifier(PagedState.initialLoading());

  C _cursor;
  bool _loadedOnce = false;
  int _requestGeneration = 0;
  bool _disposed = false;

  /// 首次加载评论分页，可通过 [force] 强制重新加载。
  Future<void> loadInitial({bool force = false}) async {
    if (_disposed || (_skipRepeatedInitialLoad && _loadedOnce && !force)) {
      return;
    }
    state.value = PagedState.initialLoading();
    await _reload();
  }

  /// 刷新第一页。
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

  /// 加载下一页。
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
      final page = await _loadPage(
        cursor: _cursor,
        forceRefresh: false,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _cursor = page.nextCursor;
      state.value = PagedState(
        items: [...currentState.items, ...page.items],
        hasMore: page.hasMore,
      );
      _loadedOnce = true;
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
    final previousState = state.value;
    try {
      final page = await _loadPage(
        cursor: _firstCursor,
        forceRefresh: previousState.refreshing,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _cursor = page.nextCursor;
      state.value = PagedState.data(
        page.items,
        hasMore: page.hasMore,
      );
      _loadedOnce = true;
      return true;
    } catch (error, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      state.value = previousState.items.isEmpty
          ? PagedState.error(
              error,
              stackTrace: stackTrace,
            )
          : previousState.copyWith(
              refreshing: false,
              error: error,
              stackTrace: stackTrace,
            );
      return false;
    }
  }

  /// 释放评论分页状态监听器。
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
}
