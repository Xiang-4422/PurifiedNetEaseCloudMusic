/// 播放历史本地数据源。
abstract class PlaybackHistoryDataSource {
  /// 记录一首已经被底层播放器确认播放的歌曲。
  Future<void> recordPlayedTrack(
    String trackId, {
    DateTime? playedAt,
  });

  /// 按最近播放时间倒序读取曲目 id。
  Future<List<String>> loadRecentTrackIds({int limit = 20});

  /// 保留最近的播放历史条目，删除更旧的记录。
  Future<void> prune({int maxEntries = 100});
}
