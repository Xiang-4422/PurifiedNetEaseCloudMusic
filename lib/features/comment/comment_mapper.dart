import 'package:bujuan/data/netease/api/src/api/event/bean.dart';
import 'package:bujuan/features/comment/comment_data.dart';

class CommentMapper {
  const CommentMapper._();

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
