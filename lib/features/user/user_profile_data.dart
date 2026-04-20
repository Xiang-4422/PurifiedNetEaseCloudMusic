class UserProfileData {
  const UserProfileData({
    required this.userId,
    required this.nickname,
    required this.signature,
    required this.follows,
    required this.followeds,
    required this.playlistCount,
    required this.avatarUrl,
  });

  final String userId;
  final String nickname;
  final String signature;
  final int follows;
  final int followeds;
  final int playlistCount;
  final String avatarUrl;

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
