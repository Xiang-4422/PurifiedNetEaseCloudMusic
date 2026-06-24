import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_paged_controller.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:flutter/foundation.dart';

/// 评论列表分页游标。
class CommentListPageCursor {
  /// 创建评论列表分页游标。
  const CommentListPageCursor({
    required this.pageNo,
    required this.cursor,
  });

  /// 请求页码。
  final int pageNo;

  /// 服务端游标。
  final String? cursor;
}

/// 评论列表分页控制器。
class CommentListController {
  /// 创建评论列表控制器。
  CommentListController({
    required this.id,
    required this.type,
    required this.sortType,
    required CommentRepository repository,
    this.pageSize = 10,
  }) : _pagedController = CommentPagedController<CommentListPageCursor>(
          firstCursor: const CommentListPageCursor(
            pageNo: 1,
            cursor: null,
          ),
          loadPage: ({required cursor, required forceRefresh}) async {
            final page = await repository.fetchComments(
              id,
              type,
              pageNo: cursor.pageNo,
              pageSize: pageSize,
              sortType: sortType,
              cursor: cursor.cursor,
              forceRefresh: forceRefresh,
            );
            return CommentPagedPage<CommentListPageCursor>(
              items: page.items,
              hasMore: page.hasMore,
              nextCursor: CommentListPageCursor(
                pageNo: cursor.pageNo + 1,
                cursor: page.nextCursor,
              ),
            );
          },
        );

  /// 评论资源 id。
  final String id;

  /// 评论资源类型。
  final String type;

  /// 评论排序类型。
  final int sortType;

  /// 每页评论数量。
  final int pageSize;
  final CommentPagedController<CommentListPageCursor> _pagedController;

  /// 评论分页加载状态。
  ValueNotifier<PagedState<CommentData>> get state => _pagedController.state;

  /// 首次加载评论列表。
  Future<void> loadInitial() async {
    await _pagedController.loadInitial();
  }

  /// 刷新评论第一页。
  Future<bool> refresh() async {
    return _pagedController.refresh();
  }

  /// 加载下一页评论。
  Future<bool> loadMore() async {
    return _pagedController.loadMore();
  }

  /// 释放评论列表状态监听器。
  void dispose() {
    _pagedController.dispose();
  }
}
