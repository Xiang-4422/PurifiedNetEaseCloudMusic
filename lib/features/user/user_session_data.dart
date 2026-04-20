/// 只保留壳层和业务链路真正关心的登录用户会话字段，避免把网易云账号 bean 扩散到全局状态。
class UserSessionData {
  const UserSessionData({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
  });

  const UserSessionData.empty()
      : userId = '',
        nickname = '',
        avatarUrl = '';

  final String userId;
  final String nickname;
  final String avatarUrl;

  bool get isLoggedIn => userId.isNotEmpty;

  factory UserSessionData.fromJson(Map<String, dynamic> json) {
    return UserSessionData(
      userId: json['userId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }
}
