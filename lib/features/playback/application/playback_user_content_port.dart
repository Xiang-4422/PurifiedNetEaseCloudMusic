import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 播放应用层读取用户侧内容的最小接口。
class PlaybackUserContentPort {
  /// 创建 PlaybackUserContentPort。
  const PlaybackUserContentPort({
    required this.toggleLikeStatus,
    required this.likedSongIds,
    required this.ensureLikedSongsLoaded,
    required this.likedSongs,
    required this.loadFmSongs,
    required this.loadHeartBeatSongs,
    required this.randomLikedSongId,
  });

  /// 切换喜欢状态。
  final Future<PlaybackQueueItem?> Function(PlaybackQueueItem item)
      toggleLikeStatus;

  /// Function。
  final List<int> Function() likedSongIds;

  /// Function。
  final Future<void> Function() ensureLikedSongsLoaded;

  /// Function。
  final List<PlaybackQueueItem> Function() likedSongs;

  /// Function。
  final Future<List<PlaybackQueueItem>> Function() loadFmSongs;

  /// 加载心动模式歌曲。
  final Future<List<PlaybackQueueItem>> Function(
    String startSongId,
    String randomLikedSongId,
    bool fromPlayAll,
  ) loadHeartBeatSongs;

  /// Function。
  final String Function() randomLikedSongId;
}
