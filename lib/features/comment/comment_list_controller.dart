import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:flutter/foundation.dart';

/// 评论列表分页控制器。
class CommentListController {
  /// 创建评论列表控制器。
  CommentListController({
    required this.id,
    required this.type,
    required this.sortType,
    required CommentRepository repository,
    this.pageSize = 10,
  }) : _repository = repository;

  /// 评论资源 id。
  final String id;

  /// 评论资源类型。
  final String type;

  /// 评论排序类型。
  final int sortType;

  /// 每页评论数量。
  final int pageSize;
  final CommentRepository _repository;

  /// 评论分页加载状态。
  final ValueNotifier<PagedState<CommentData>> state =
      ValueNotifier(PagedState.initialLoading());

  int _pageNo = 1;
  String? _cursor;

  /// 首次加载评论列表。
  Future<void> loadInitial() async {
    state.value = PagedState.initialLoading();
    await _reload();
  }

  /// 刷新评论第一页。
  Future<bool> refresh() async {
    state.value = state.value.copyWith(
      refreshing: true,
      error: null,
    );
    return _reload();
  }

  /// 加载下一页评论。
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
      final page = await _repository.fetchComments(
        id,
        type,
        pageNo: _pageNo + 1,
        pageSize: pageSize,
        sortType: sortType,
        cursor: _cursor,
      );
      _pageNo += 1;
      _cursor = page.nextCursor;
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
      final page = await _repository.fetchComments(
        id,
        type,
        pageNo: 1,
        pageSize: pageSize,
        sortType: sortType,
      );
      _pageNo = 1;
      _cursor = page.nextCursor;
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

  /// 释放评论列表状态监听器。
  void dispose() {
    state.dispose();
  }
}
