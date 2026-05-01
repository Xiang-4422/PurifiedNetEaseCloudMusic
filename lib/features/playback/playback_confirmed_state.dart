import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';

/// 底层播放器已经确认的真实播放态。
class PlaybackConfirmedState {
  /// 创建已确认播放状态。
  const PlaybackConfirmedState({
    this.queue = const <PlaybackQueueItem>[],
    this.currentSong = const PlaybackQueueItem.empty(),
    this.currentIndex = -1,
    this.currentPosition = Duration.zero,
    this.isPlaying = false,
  });

  /// 底层播放器当前队列。
  final List<PlaybackQueueItem> queue;

  /// 底层已确认歌曲。
  final PlaybackQueueItem currentSong;

  /// 底层已确认歌曲索引。
  final int currentIndex;

  /// 当前播放进度。
  final Duration currentPosition;

  /// 底层当前是否播放中。
  final bool isPlaying;

  /// 从运行态创建已确认状态。
  factory PlaybackConfirmedState.fromRuntime(
    PlaybackRuntimeState state, {
    required bool isPlaying,
  }) {
    return PlaybackConfirmedState(
      queue: state.queue,
      currentSong: state.currentSong,
      currentIndex: state.currentIndex,
      currentPosition: state.currentPosition,
      isPlaying: isPlaying,
    );
  }
}
