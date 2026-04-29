import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:flutter/foundation.dart';

/// FloorCommentController。
class FloorCommentController {
  /// 创建 FloorCommentController。
  FloorCommentController({
    required this.id,
    required this.type,
    required this.parentCommentId,
    required CommentRepository repository,
    this.pageSize = 20,
  }) : _repository = repository;

  /// id。
  final String id;

  /// type。
  final String type;

  /// parentCommentId。
  final String parentCommentId;

  /// pageSize。
  final int pageSize;
  final CommentRepository _repository;

  /// state。
  final ValueNotifier<PagedState<CommentData>> state =
      ValueNotifier(PagedState.initialLoading());

  int _time = -1;
  bool _loadedOnce = false;

  /// loadInitial。
  Future<void> loadInitial({bool force = false}) async {
    if (_loadedOnce && !force) {
      return;
    }
    state.value = PagedState.initialLoading();
    await _reload();
  }

  /// refresh。
  Future<bool> refresh() async {
    state.value = state.value.copyWith(
      refreshing: true,
      error: null,
    );
    return _reload();
  }

  /// loadMore。
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
      final page = await _repository.fetchFloorComments(
        id,
        type,
        parentCommentId,
        time: _time,
        limit: pageSize,
      );
      _time = page.nextTime;
      state.value = PagedState(
        items: [...currentState.items, ...page.items],
        hasMore: page.hasMore,
      );
      _loadedOnce = true;
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
      final page = await _repository.fetchFloorComments(
        id,
        type,
        parentCommentId,
        time: -1,
        limit: pageSize,
      );
      _time = page.nextTime;
      state.value = PagedState.data(
        page.items,
        hasMore: page.hasMore,
      );
      _loadedOnce = true;
      return true;
    } catch (error, stackTrace) {
      state.value = PagedState.error(
        error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// toggleLike。
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

  /// sendReply。
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

  /// dispose。
  void dispose() {
    state.dispose();
  }
}
