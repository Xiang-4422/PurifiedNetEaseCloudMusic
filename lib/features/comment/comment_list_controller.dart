import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:flutter/foundation.dart';

/// CommentListController。
class CommentListController {
  /// 创建 CommentListController。
  CommentListController({
    required this.id,
    required this.type,
    required this.sortType,
    required CommentRepository repository,
    this.pageSize = 10,
  }) : _repository = repository;

  /// id。
  final String id;

  /// type。
  final String type;

  /// sortType。
  final int sortType;

  /// pageSize。
  final int pageSize;
  final CommentRepository _repository;

  /// state。
  final ValueNotifier<PagedState<CommentData>> state =
      ValueNotifier(PagedState.initialLoading());

  int _pageNo = 1;
  String? _cursor;

  /// loadInitial。
  Future<void> loadInitial() async {
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

  /// dispose。
  void dispose() {
    state.dispose();
  }
}
