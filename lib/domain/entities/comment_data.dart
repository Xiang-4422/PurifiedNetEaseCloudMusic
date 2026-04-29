/// 评论用户摘要。
class CommentUserData {
  /// 创建评论用户摘要。
  const CommentUserData({
    required this.nickname,
    required this.avatarUrl,
  });

  /// 用户昵称。
  final String nickname;

  /// 用户头像地址。
  final String avatarUrl;
}

/// 评论领域数据。
class CommentData {
  /// 创建评论数据。
  const CommentData({
    required this.commentId,
    required this.user,
    required this.content,
    required this.time,
    required this.replyCount,
    required this.likedCount,
    required this.liked,
  });

  /// 评论 id。
  final String commentId;

  /// 评论用户。
  final CommentUserData user;

  /// 评论正文。
  final String content;

  /// 评论时间戳。
  final int time;

  /// 回复数量。
  final int replyCount;

  /// 点赞数量。
  final int likedCount;

  /// 当前用户是否已点赞。
  final bool liked;

  /// 复制评论数据并替换指定字段。
  CommentData copyWith({
    String? commentId,
    CommentUserData? user,
    String? content,
    int? time,
    int? replyCount,
    int? likedCount,
    bool? liked,
  }) {
    return CommentData(
      commentId: commentId ?? this.commentId,
      user: user ?? this.user,
      content: content ?? this.content,
      time: time ?? this.time,
      replyCount: replyCount ?? this.replyCount,
      likedCount: likedCount ?? this.likedCount,
      liked: liked ?? this.liked,
    );
  }
}
