class CommentUserData {
  const CommentUserData({
    required this.nickname,
    required this.avatarUrl,
  });

  final String nickname;
  final String avatarUrl;
}

class CommentData {
  const CommentData({
    required this.commentId,
    required this.user,
    required this.content,
    required this.time,
    required this.replyCount,
    required this.likedCount,
    required this.liked,
  });

  final String commentId;
  final CommentUserData user;
  final String content;
  final int time;
  final int replyCount;
  final int likedCount;
  final bool liked;

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
