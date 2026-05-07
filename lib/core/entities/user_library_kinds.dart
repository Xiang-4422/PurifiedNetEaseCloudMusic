/// 用户曲目列表类型。
enum UserTrackListKind {
  /// 喜欢歌曲列表。
  liked,

  /// 每日推荐列表。
  dailyRecommend,

  /// 私人 FM 列表。
  fm,

  /// 云盘歌曲列表。
  cloud,
}

/// 用户歌单列表类型。
enum UserPlaylistListKind {
  /// 收藏歌单列表。
  likedCollection,

  /// 用户创建或拥有的歌单列表。
  userPlaylists,

  /// 推荐歌单列表。
  recommended,
}
