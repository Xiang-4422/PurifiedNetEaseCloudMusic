import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 播放应用层读取用户侧内容的最小接口。
class PlaybackUserContentPort {
  const PlaybackUserContentPort({
    required this.toggleLikeStatus,
    required this.likedSongIds,
    required this.ensureLikedSongsLoaded,
    required this.likedSongs,
    required this.loadFmSongs,
    required this.loadHeartBeatSongs,
    required this.randomLikedSongId,
  });

  final Future<PlaybackQueueItem?> Function(PlaybackQueueItem item)
      toggleLikeStatus;
  final List<int> Function() likedSongIds;
  final Future<void> Function() ensureLikedSongsLoaded;
  final List<PlaybackQueueItem> Function() likedSongs;
  final Future<List<PlaybackQueueItem>> Function() loadFmSongs;
  final Future<List<PlaybackQueueItem>> Function(
    String startSongId,
    String randomLikedSongId,
    bool fromPlayAll,
  ) loadHeartBeatSongs;
  final String Function() randomLikedSongId;
}
