import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 运行时播放状态描述“播放器此刻正在播放什么、队列在哪、进度到哪”。
///
/// 歌词、取色和面板展示动画仍保持独立，因为它们更新频率更高，也更偏视图层。
/// 这里先收口跨页面最常用的运行态，避免继续在控制器里分散维护多组 Rx 字段。
class PlaybackRuntimeState {
  /// 当前播放队列。
  final List<PlaybackQueueItem> queue;

  /// 当前播放歌曲。
  final PlaybackQueueItem currentSong;

  /// 当前播放歌曲在队列中的索引。
  final int currentIndex;

  /// 当前播放进度。
  final Duration currentPosition;

  /// 创建运行时播放状态。
  const PlaybackRuntimeState({
    this.queue = const <PlaybackQueueItem>[],
    this.currentSong = const PlaybackQueueItem.empty(),
    this.currentIndex = 0,
    this.currentPosition = Duration.zero,
  });

  /// 复制运行时状态并替换指定字段。
  PlaybackRuntimeState copyWith({
    List<PlaybackQueueItem>? queue,
    PlaybackQueueItem? currentSong,
    int? currentIndex,
    Duration? currentPosition,
  }) {
    return PlaybackRuntimeState(
      queue: queue ?? this.queue,
      currentSong: currentSong ?? this.currentSong,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
