import 'package:bujuan/core/entities/playback_queue_item.dart';

/// 歌单详情数据来源。
enum PlaylistDetailSource {
  /// 本地曲库。
  local,

  /// 远端接口。
  remote,
}

/// 歌单详情数据，包含歌曲队列和当前用户与歌单的关系。
class PlaylistDetailData {
  /// 创建歌单详情数据。
  const PlaylistDetailData({
    required this.songs,
    required this.isSubscribed,
    required this.isMyPlayList,
    required this.source,
    this.expectedTrackCount,
    this.playlistName,
    this.coverUrl,
    this.trackCount,
  });

  /// 歌单内可播放歌曲队列。
  final List<PlaybackQueueItem> songs;

  /// 当前用户是否已收藏歌单。
  final bool isSubscribed;

  /// 歌单是否属于当前用户。
  final bool isMyPlayList;

  /// 歌单声明或推断出的曲目总数。
  final int? expectedTrackCount;

  /// 歌单名称。
  final String? playlistName;

  /// 歌单封面地址。
  final String? coverUrl;

  /// 歌单声明的曲目总数。
  final int? trackCount;

  /// 歌单详情来源。
  final PlaylistDetailSource source;

  /// 当前歌曲列表是否已覆盖预期曲目数量。
  bool get isComplete => expectedTrackCount == null || songs.length >= expectedTrackCount!;

  /// 从本地曲目顺序和兜底数量推断预期曲目数。
  static int? resolveExpectedTrackCount(
    int orderedTrackCount,
    int? fallbackTrackCount,
  ) {
    if (orderedTrackCount > 0) {
      return orderedTrackCount;
    }
    return fallbackTrackCount != null && fallbackTrackCount > 0 ? fallbackTrackCount : null;
  }
}
