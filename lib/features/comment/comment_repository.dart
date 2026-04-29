import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/data/netease/netease_comment_remote_data_source.dart';
import 'package:bujuan/domain/entities/comment_data.dart';

/// 评论仓库，封装评论列表、楼层评论、发送评论和点赞操作。
class CommentRepository {
  /// 创建评论仓库。
  CommentRepository({NeteaseCommentRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? NeteaseCommentRemoteDataSource();

  final NeteaseCommentRemoteDataSource _remoteDataSource;

  /// 分页获取评论列表。
  Future<CommentPage> fetchComments(
    String id,
    String type, {
    int pageNo = 1,
    int pageSize = 20,
    bool showInner = false,
    int? sortType,
    String? cursor,
  }) async {
    final page = await _remoteDataSource.fetchComments(
      id,
      type,
      pageNo: pageNo,
      pageSize: pageSize,
      showInner: showInner,
      sortType: sortType ?? 99,
      cursor: cursor ?? '0',
    );
    return CommentPage(
      items: page.items,
      hasMore: page.hasMore,
      nextCursor: page.nextCursor,
    );
  }

  /// 分页获取楼层评论。
  Future<FloorCommentPage> fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    int time = -1,
    int limit = 20,
  }) async {
    final page = await _remoteDataSource.fetchFloorComments(
      id,
      type,
      parentCommentId,
      time: time,
      limit: limit,
    );
    return FloorCommentPage(
      items: page.items,
      hasMore: page.hasMore,
      nextTime: page.nextTime,
    );
  }

  /// 发送、回复或删除评论。
  Future<OperationResult> sendComment(
    String id,
    String type,
    String operation, {
    required String content,
    String? commentId,
  }) async {
    final result = await _remoteDataSource.sendComment(
      id,
      type,
      operation,
      content: content,
      commentId: commentId,
    );
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  /// 切换评论点赞状态。
  Future<OperationResult> toggleCommentLike(
    String id,
    String type,
    String commentId,
    bool like,
  ) async {
    final result = await _remoteDataSource.toggleCommentLike(
      id,
      type,
      commentId,
      like,
    );
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }
}

/// 评论分页数据。
class CommentPage {
  /// 创建评论分页数据。
  const CommentPage({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
  });

  /// 评论列表。
  final List<CommentData> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页游标。
  final String? nextCursor;
}

/// 楼层评论分页数据。
class FloorCommentPage {
  /// 创建楼层评论分页数据。
  const FloorCommentPage({
    required this.items,
    required this.hasMore,
    required this.nextTime,
  });

  /// 评论列表。
  final List<CommentData> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页时间游标。
  final int nextTime;
}
