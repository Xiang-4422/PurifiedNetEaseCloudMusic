/// 播放队列领域实体。
class PlaybackQueue {
  /// 创建播放队列。
  const PlaybackQueue({
    required this.id,
    required this.trackIds,
    this.currentIndex = 0,
    this.title,
    this.sourcePlaylistId,
  });

  /// 队列 id。
  final String id;

  /// 队列中的曲目 id 列表。
  final List<String> trackIds;

  /// 当前播放索引。
  final int currentIndex;

  /// 队列标题。
  final String? title;

  /// 来源歌单 id。
  final String? sourcePlaylistId;

  /// 复制播放队列并替换指定字段。
  PlaybackQueue copyWith({
    String? id,
    List<String>? trackIds,
    int? currentIndex,
    String? title,
    String? sourcePlaylistId,
  }) {
    return PlaybackQueue(
      id: id ?? this.id,
      trackIds: trackIds ?? this.trackIds,
      currentIndex: currentIndex ?? this.currentIndex,
      title: title ?? this.title,
      sourcePlaylistId: sourcePlaylistId ?? this.sourcePlaylistId,
    );
  }
}
