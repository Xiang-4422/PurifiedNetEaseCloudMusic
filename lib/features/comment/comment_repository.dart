import 'package:bujuan/common/netease_api/src/api/bean.dart';
import 'package:bujuan/common/netease_api/src/api/event/bean.dart';
import 'package:bujuan/common/netease_api/src/dio_ext.dart';
import 'package:bujuan/common/netease_api/src/netease_api.dart';
import 'package:bujuan/common/netease_api/src/netease_handler.dart';

class CommentRepository {
  DioMetaData buildCommentListRequest(
    String id,
    String type, {
    int pageNo = 1,
    int pageSize = 20,
    bool showInner = false,
    int? sortType,
  }) {
    return DioMetaData(
      joinUri('/api/v2/resource/comments'),
      data: {
        'threadId': _typeKey(type) + id,
        'pageNo': pageNo,
        'pageSize': pageSize,
        'showInner': showInner,
        'sortType': sortType ?? 99,
        'cursor': 0,
      },
      options: joinOptions(
        encryptType: EncryptType.EApi,
        eApiUrl: '/api/v2/resource/comments',
        cookies: {'os': 'pc'},
      ),
    );
  }

  DioMetaData buildFloorCommentsRequest(
    String id,
    String type,
    String parentCommentId, {
    int time = -1,
    int limit = 20,
  }) {
    return DioMetaData(
      joinUri('/api/resource/comment/floor/get'),
      data: {
        'parentCommentId': parentCommentId,
        'threadId': _typeKey(type) + id,
        'time': time,
        'limit': limit,
      },
      options: joinOptions(),
    );
  }

  Future<CommentWrap> sendComment(
    String id,
    String type,
    String operation, {
    required String content,
    String? commentId,
  }) {
    return NeteaseMusicApi().comment(
      id,
      type,
      operation,
      content: content,
      commentId: commentId,
    );
  }

  Future<FloorCommentDetailWrap> fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    int time = -1,
    int limit = 20,
  }) {
    return NeteaseMusicApi().floorComments(
      id,
      type,
      parentCommentId,
      time: time,
      limit: limit,
    );
  }

  Future<ServerStatusBean> toggleCommentLike(
    String id,
    String type,
    String commentId,
    bool like,
  ) {
    return NeteaseMusicApi().likeComment(
      id,
      commentId,
      type,
      like,
      threadId: _typeKey(type) + id,
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
}
