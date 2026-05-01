import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';

/// 播放页面当前应该展示的选择态。
class PlaybackDisplayState {
  /// 创建播放展示状态。
  const PlaybackDisplayState({
    this.queue = const <PlaybackQueueItem>[],
    this.currentSong = const PlaybackQueueItem.empty(),
    this.currentIndex = -1,
    this.sourceStatus = PlaybackSelectionSourceStatus.idle,
    this.sourceError,
  });

  /// 当前展示队列。
  final List<PlaybackQueueItem> queue;

  /// 当前展示歌曲。
  final PlaybackQueueItem currentSong;

  /// 当前展示歌曲索引。
  final int currentIndex;

  /// 当前展示歌曲的播放源状态。
  final PlaybackSelectionSourceStatus sourceStatus;

  /// 当前展示歌曲的播放源错误。
  final String? sourceError;

  /// 是否有可展示歌曲。
  bool get hasCurrentSong => currentSong.id.isNotEmpty && currentIndex >= 0;

  /// 从 selection 状态创建展示状态。
  factory PlaybackDisplayState.fromSelection(PlaybackSelectionState state) {
    return PlaybackDisplayState(
      queue: state.queue,
      currentSong: state.selectedItem,
      currentIndex: state.selectedIndex,
      sourceStatus: state.sourceStatus,
      sourceError: state.sourceError,
    );
  }
}
