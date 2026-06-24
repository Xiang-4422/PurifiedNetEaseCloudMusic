import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_paged_controller.dart';
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
  })  : _repository = repository,
        _pagedController = CommentPagedController<int>(
          firstCursor: -1,
          skipRepeatedInitialLoad: true,
          loadPage: ({required cursor, required forceRefresh}) async {
            final page = await repository.fetchFloorComments(
              id,
              type,
              parentCommentId,
              time: cursor,
              limit: pageSize,
              forceRefresh: forceRefresh,
            );
            return CommentPagedPage<int>(
              items: page.items,
              hasMore: page.hasMore,
              nextCursor: page.nextTime,
            );
          },
        );

  /// 评论资源 id。
  final String id;

  /// 评论资源类型。
  final String type;

  /// 父评论 id。
  final String parentCommentId;

  /// 每页楼层回复数量。
  final int pageSize;
  final CommentRepository _repository;
  final CommentPagedController<int> _pagedController;

  /// 楼层回复分页加载状态。
  ValueNotifier<PagedState<CommentData>> get state => _pagedController.state;

  /// 首次加载楼层回复，可通过 `force` 强制重新加载。
  Future<void> loadInitial({bool force = false}) async {
    await _pagedController.loadInitial(force: force);
  }

  /// 刷新楼层回复第一页。
  Future<bool> refresh() async {
    return _pagedController.refresh();
  }

  /// 加载下一页楼层回复。
  Future<bool> loadMore() async {
    return _pagedController.loadMore();
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
    _pagedController.dispose();
  }
}
