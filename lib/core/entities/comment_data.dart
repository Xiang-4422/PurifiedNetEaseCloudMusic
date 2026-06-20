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

  /// 从 JSON 创建评论用户摘要。
  factory CommentUserData.fromJson(Map<String, dynamic> json) {
    return CommentUserData(
      nickname: json['nickname']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
    );
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }
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

  /// 从 JSON 创建评论数据。
  factory CommentData.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    return CommentData(
      commentId: json['commentId']?.toString() ?? '',
      user: CommentUserData.fromJson(
        rawUser is Map ? Map<String, dynamic>.from(rawUser.map((key, value) => MapEntry('$key', value))) : const {},
      ),
      content: json['content']?.toString() ?? '',
      time: _intFromJson(json['time']),
      replyCount: _intFromJson(json['replyCount']),
      likedCount: _intFromJson(json['likedCount']),
      liked: json['liked'] == true,
    );
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'user': user.toJson(),
      'content': content,
      'time': time,
      'replyCount': replyCount,
      'likedCount': likedCount,
      'liked': liked,
    };
  }

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

int _intFromJson(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
