import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:flutter/foundation.dart';

/// 楼层回复分页控制器。
class FloorCommentController {
  /// 创建楼层回复控制器。
  FloorCommentController({
    required this.id,
    required this.type,
    required this.parentCommentId,
    required CommentRepository repository,
    this.pageSize = 20,
  }) : _repository = repository;

  /// 评论资源 id。
  final String id;

  /// 评论资源类型。
  final String type;

  /// 父评论 id。
  final String parentCommentId;

  /// 每页楼层回复数量。
  final int pageSize;
  final CommentRepository _repository;

  /// 楼层回复分页加载状态。
  final ValueNotifier<PagedState<CommentData>> state = ValueNotifier(PagedState.initialLoading());

  int _time = -1;
  bool _loadedOnce = false;
  int _requestGeneration = 0;
  bool _disposed = false;

  /// 首次加载楼层回复，可通过 `force` 强制重新加载。
  Future<void> loadInitial({bool force = false}) async {
    if (_disposed || (_loadedOnce && !force)) {
      return;
    }
    state.value = PagedState.initialLoading();
    await _reload();
  }

  /// 刷新楼层回复第一页。
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

  /// 加载下一页楼层回复。
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
      final page = await _repository.fetchFloorComments(
        id,
        type,
        parentCommentId,
        time: _time,
        limit: pageSize,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _time = page.nextTime;
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
      final page = await _repository.fetchFloorComments(
        id,
        type,
        parentCommentId,
        time: -1,
        limit: pageSize,
        forceRefresh: previousState.refreshing,
      );
      if (!_isCurrentRequest(generation)) {
        return true;
      }
      _time = page.nextTime;
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

  /// 切换评论点赞状态。
  Future<bool> toggleLike(
    CommentData comment, {
    required bool liked,
  }) async {
    final result = await _repository.toggleCommentLike(
      id,
      type,
      comment.commentId,
      liked,
    );
    return result.success;
  }

  /// 发送楼层回复，失败时返回可展示错误文案。
  Future<String?> sendReply({
    required String content,
    required String commentId,
  }) async {
    final commentWrap = await _repository.sendComment(
      id,
      type,
      'reply',
      content: content,
      commentId: commentId,
    );
    return commentWrap.success ? null : commentWrap.message ?? '评论失败';
  }

  /// 释放楼层回复状态监听器。
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
