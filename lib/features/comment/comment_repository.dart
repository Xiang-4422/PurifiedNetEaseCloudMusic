import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/data/netease/netease_comment_remote_data_source.dart';
import 'package:bujuan/domain/entities/comment_data.dart';

class CommentRepository {
  CommentRepository({NeteaseCommentRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? NeteaseCommentRemoteDataSource();

  final NeteaseCommentRemoteDataSource _remoteDataSource;

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

class CommentPage {
  const CommentPage({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
  });

  final List<CommentData> items;
  final bool hasMore;
  final String? nextCursor;
}

class FloorCommentPage {
  const FloorCommentPage({
    required this.items,
    required this.hasMore,
    required this.nextTime,
  });

  final List<CommentData> items;
  final bool hasMore;
  final int nextTime;
}
