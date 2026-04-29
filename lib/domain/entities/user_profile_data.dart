/// 用户资料数据。
class UserProfileData {
  /// 创建用户资料数据。
  const UserProfileData({
    required this.userId,
    required this.nickname,
    required this.signature,
    required this.follows,
    required this.followeds,
    required this.playlistCount,
    required this.avatarUrl,
  });

  /// 用户 id。
  final String userId;

  /// 用户昵称。
  final String nickname;

  /// 用户签名。
  final String signature;

  /// 关注数量。
  final int follows;

  /// 粉丝数量。
  final int followeds;

  /// 歌单数量。
  final int playlistCount;

  /// 头像地址。
  final String avatarUrl;

  /// 从 JSON 创建用户资料数据。
  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      userId: json['userId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      follows: json['follows'] as int? ?? 0,
      followeds: json['followeds'] as int? ?? 0,
      playlistCount: json['playlistCount'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  /// 转为可持久化 JSON。
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'signature': signature,
      'follows': follows,
      'followeds': followeds,
      'playlistCount': playlistCount,
      'avatarUrl': avatarUrl,
    };
  }
}
