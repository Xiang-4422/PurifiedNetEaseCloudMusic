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
}
