import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/data/netease/api/src/api/event/bean.dart';
import 'package:bujuan/data/netease/api/src/dio_ext.dart';
import 'package:bujuan/data/netease/api/src/netease_api.dart';
import 'package:bujuan/data/netease/api/src/netease_handler.dart';
import 'package:bujuan/core/network/request_repository.dart';
import 'package:bujuan/features/comment/comment_data.dart';
import 'package:bujuan/features/comment/comment_mapper.dart';

class CommentRepository {
  CommentRepository({RequestRepository? requestRepository})
      : _requestRepository = requestRepository ?? RequestRepository();

  final RequestRepository _requestRepository;

  Future<CommentPage> fetchComments(
    String id,
    String type, {
    int pageNo = 1,
    int pageSize = 20,
    bool showInner = false,
    int? sortType,
    String? cursor,
  }) async {
    final response = await _requestRepository.post(
      _commentListRequest(
        id,
        type,
        pageNo: pageNo,
        pageSize: pageSize,
        showInner: showInner,
        sortType: sortType,
        cursor: cursor,
      ),
    );
    final wrap = CommentList2Wrap.fromJson(response.data);
    return CommentPage(
      items: CommentMapper.fromItemList(wrap.data.comments ?? const <CommentItem>[]),
      hasMore: wrap.data.hasMore ?? false,
      nextCursor: wrap.data.cursor,
    );
  }

  Future<FloorCommentPage> fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    int time = -1,
    int limit = 20,
  }) async {
    final wrap = await NeteaseMusicApi().floorComments(
      id,
      type,
      parentCommentId,
      time: time,
      limit: limit,
    );
    return FloorCommentPage(
      items: CommentMapper.fromItemList(wrap.data.comments ?? const <CommentItem>[]),
      hasMore: wrap.data.hasMore ?? false,
      nextTime: wrap.data.time ?? -1,
    );
  }

  Future<OperationResult> sendComment(
    String id,
    String type,
    String operation, {
    required String content,
    String? commentId,
  }) async {
    final result = await NeteaseMusicApi().comment(
      id,
      type,
      operation,
      content: content,
      commentId: commentId,
    );
    return OperationResult(
      success: result.code == 200,
      message: result.message,
    );
  }

  Future<OperationResult> toggleCommentLike(
    String id,
    String type,
    String commentId,
    bool like,
  ) async {
    final result = await NeteaseMusicApi().likeComment(
      id,
      commentId,
      type,
      like,
      threadId: _typeKey(type) + id,
    );
    return OperationResult(
      success: result.code == 200,
      message: result.message,
    );
  }

  String _typeKey(String type) {
    switch (type) {
      case 'mv':
        return 'R_MV_5_';
      case 'playlist':
        return 'A_PL_0_';
      case 'album':
        return 'R_AL_3_';
      case 'dj':
        return 'A_DJ_1_';
      case 'video':
        return 'R_VI_62_';
      case 'event':
        return 'A_EV_2_';
      case 'song':
      default:
        return 'R_SO_4_';
    }
  }

  DioMetaData _commentListRequest(
    String id,
    String type, {
    required int pageNo,
    required int pageSize,
    required bool showInner,
    required int? sortType,
    required String? cursor,
  }) {
    return DioMetaData(
      joinUri('/api/v2/resource/comments'),
      data: {
        'threadId': _typeKey(type) + id,
        'pageNo': pageNo,
        'pageSize': pageSize,
        'showInner': showInner,
        'sortType': sortType ?? 99,
        'cursor': cursor ?? '0',
      },
      options: joinOptions(
        encryptType: EncryptType.EApi,
        eApiUrl: '/api/v2/resource/comments',
        cookies: const {'os': 'pc'},
      ),
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
