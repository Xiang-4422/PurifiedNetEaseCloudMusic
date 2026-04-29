import 'package:bujuan/core/network/request_repository.dart';
import 'package:bujuan/data/netease/api/src/dio_ext.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/api/src/netease_handler.dart';
import 'package:bujuan/data/netease/mappers/netease_comment_mapper.dart';
import 'package:bujuan/domain/entities/comment_data.dart';

/// 网易云评论远程数据源。
class NeteaseCommentRemoteDataSource {
  /// 创建网易云评论远程数据源。
  NeteaseCommentRemoteDataSource({RequestRepository? requestRepository})
      : _requestRepository = requestRepository ?? RequestRepository();

  final RequestRepository _requestRepository;

  /// 分页获取资源评论。
  Future<({List<CommentData> items, bool hasMore, String? nextCursor})>
      fetchComments(
    String id,
    String type, {
    required int pageNo,
    required int pageSize,
    required bool showInner,
    required int sortType,
    required String cursor,
  }) async {
    final normalizedId = _normalizeResourceId(id);
    final response = await _requestRepository.post(
      DioMetaData(
        joinUri('/api/v2/resource/comments'),
        data: {
          'threadId': _typeKey(type) + normalizedId,
          'pageNo': pageNo,
          'pageSize': pageSize,
          'showInner': showInner,
          'sortType': sortType,
          'cursor': cursor,
        },
        options: joinOptions(
          encryptType: EncryptType.EApi,
          eApiUrl: '/api/v2/resource/comments',
          cookies: const {'os': 'pc'},
        ),
      ),
    );
    final page = NeteaseCommentMapper.fromCommentListResponse(response.data);
    return (
      items: page.items,
      hasMore: page.hasMore,
      nextCursor: page.nextCursor,
    );
  }

  /// 分页获取楼层评论。
  Future<({List<CommentData> items, bool hasMore, int nextTime})>
      fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    required int time,
    required int limit,
  }) async {
    final normalizedId = _normalizeResourceId(id);
    final wrap = await NeteaseMusicApi().floorComments(
      normalizedId,
      type,
      parentCommentId,
      time: time,
      limit: limit,
    );
    final page = NeteaseCommentMapper.fromFloorCommentResponse(wrap);
    return (
      items: page.items,
      hasMore: page.hasMore,
      nextTime: page.nextTime,
    );
  }

  /// 发送、回复或删除评论。
  Future<({bool success, String? message})> sendComment(
    String id,
    String type,
    String operation, {
    required String content,
    String? commentId,
  }) async {
    final normalizedId = _normalizeResourceId(id);
    final result = await NeteaseMusicApi().comment(
      normalizedId,
      type,
      operation,
      content: content,
      commentId: commentId,
    );
    return (
      success: result.code == 200,
      message: result.message,
    );
  }

  /// 切换评论点赞状态。
  Future<({bool success, String? message})> toggleCommentLike(
    String id,
    String type,
    String commentId,
    bool like,
  ) async {
    final normalizedId = _normalizeResourceId(id);
    final result = await NeteaseMusicApi().likeComment(
      normalizedId,
      commentId,
      type,
      like,
      threadId: _typeKey(type) + normalizedId,
    );
    return (
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

  String _normalizeResourceId(String id) {
    final separatorIndex = id.indexOf(':');
    if (separatorIndex == -1) {
      return id;
    }
    return id.substring(separatorIndex + 1);
  }
}
