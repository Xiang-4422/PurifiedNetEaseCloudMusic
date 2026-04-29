import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 播放应用层读取用户侧内容的最小接口。
class PlaybackUserContentPort {
  /// 创建播放用户内容端口。
  const PlaybackUserContentPort({
    required this.toggleLikeStatus,
    required this.likedSongIds,
    required this.ensureLikedSongsLoaded,
    required this.likedSongs,
    required this.loadFmSongs,
    required this.loadHeartBeatSongs,
    required this.randomLikedSongId,
  });

  /// 切换歌曲喜欢状态。
  final Future<PlaybackQueueItem?> Function(PlaybackQueueItem item)
      toggleLikeStatus;

  /// 当前用户喜欢歌曲 id 列表。
  final List<int> Function() likedSongIds;

  /// 确保喜欢歌曲队列已经加载。
  final Future<void> Function() ensureLikedSongsLoaded;

  /// 当前用户喜欢歌曲队列。
  final List<PlaybackQueueItem> Function() likedSongs;

  /// 加载私人 FM 候选歌曲。
  final Future<List<PlaybackQueueItem>> Function() loadFmSongs;

  /// 加载心动模式歌曲。
  final Future<List<PlaybackQueueItem>> Function(
    String startSongId,
    String randomLikedSongId,
    bool fromPlayAll,
  ) loadHeartBeatSongs;

  /// 随机喜欢歌曲 id。
  final String Function() randomLikedSongId;
}
