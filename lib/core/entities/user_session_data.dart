/// 只保留壳层和业务链路真正关心的登录用户会话字段，避免把远程账号模型扩散到全局状态。
class UserSessionData {
  /// 创建用户 session 数据。
  const UserSessionData({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
  });

  /// 创建空用户 session 数据。
  const UserSessionData.empty()
      : userId = '',
        nickname = '',
        avatarUrl = '';

  /// 用户 id。
  final String userId;

  /// 用户昵称。
  final String nickname;

  /// 头像地址。
  final String avatarUrl;

  /// 当前是否已登录。
  bool get isLoggedIn => userId.isNotEmpty;

  /// 从 JSON 创建用户 session 数据。
  factory UserSessionData.fromJson(Map<String, dynamic> json) {
    return UserSessionData(
      userId: json['userId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  /// 转为可持久化 JSON。
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }
}
