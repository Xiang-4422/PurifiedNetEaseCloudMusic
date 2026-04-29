import 'package:bujuan/data/netease/api/src/api/event/bean.dart';
import 'package:bujuan/domain/entities/comment_data.dart';

/// 网易云评论 mapper。
class NeteaseCommentMapper {
  /// 禁止实例化网易云评论 mapper。
  const NeteaseCommentMapper._();

  /// 将评论列表响应转换为领域评论分页数据。
  static ({
    List<CommentData> items,
    bool hasMore,
    String? nextCursor,
  }) fromCommentListResponse(Map<String, dynamic> json) {
    final wrap = CommentList2Wrap.fromJson(json);
    return (
      items: fromItemList(wrap.data.comments ?? const []),
      hasMore: wrap.data.hasMore ?? false,
      nextCursor: wrap.data.cursor,
    );
  }

  /// 将楼层评论响应转换为领域评论分页数据。
  static ({
    List<CommentData> items,
    bool hasMore,
    int nextTime,
  }) fromFloorCommentResponse(FloorCommentDetailWrap wrap) {
    return (
      items: fromItemList(wrap.data.comments ?? const []),
      hasMore: wrap.data.hasMore ?? false,
      nextTime: wrap.data.time ?? -1,
    );
  }

  /// 将网易云评论条目转换为领域评论数据。
  static CommentData fromItem(CommentItem item) {
    return CommentData(
      commentId: item.commentId,
      user: CommentUserData(
        nickname: item.user.nickname ?? '',
        avatarUrl: item.user.avatarUrl ?? '',
      ),
      content: item.content ?? '',
      time: item.time ?? 0,
      replyCount: item.replyCount ?? 0,
      likedCount: item.likedCount ?? 0,
      liked: item.liked ?? false,
    );
  }

  /// 将网易云评论条目列表转换为领域评论数据列表。
  static List<CommentData> fromItemList(List<CommentItem> items) {
    return items.map(fromItem).toList();
  }
}
