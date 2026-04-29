/// 歌单曲目引用。
class PlaylistTrackRef {
  /// 创建歌单曲目引用。
  const PlaylistTrackRef({
    required this.trackId,
    required this.order,
    this.addedAt,
  });

  /// 曲目 id。
  final String trackId;

  /// 歌单内顺序。
  final int order;

  /// 添加时间戳。
  final int? addedAt;
}
