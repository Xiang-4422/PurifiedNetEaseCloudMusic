import 'package:bujuan/data/netease/api/src/api/event/bean.dart';
import 'package:bujuan/domain/entities/comment_data.dart';

class NeteaseCommentMapper {
  const NeteaseCommentMapper._();

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

  static List<CommentData> fromItemList(List<CommentItem> items) {
    return items.map(fromItem).toList();
  }
}
