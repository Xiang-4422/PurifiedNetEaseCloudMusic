import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';

/// App 播放队列事实状态。
///
/// `originalQueue` 保存业务原始顺序，`activeQueue` 保存当前 UI 和播放器共同使用的
/// 展示顺序；随机、顺序和模式切换都必须先改这里，再向 selection 和 audio adapter 同步。
class PlaybackQueueState {
  /// 创建播放队列事实状态。
  const PlaybackQueueState({
    this.originalQueue = const <PlaybackQueueItem>[],
    this.activeQueue = const <PlaybackQueueItem>[],
    this.selectedIndex = -1,
    this.confirmedIndex = -1,
    this.playlistName = '',
    this.playlistHeader = '',
    this.repeatMode = PlaybackRepeatMode.all,
    this.playbackMode = PlaybackMode.playlist,
    this.pendingRestorePosition = Duration.zero,
    this.selectionVersion = 0,
    this.queueVersion = 0,
  });

  /// 业务原始队列。
  final List<PlaybackQueueItem> originalQueue;

  /// 当前播放链路实际使用的队列。
  final List<PlaybackQueueItem> activeQueue;

  /// UI 当前选中的 active queue 索引。
  final int selectedIndex;

  /// 底层播放器已经确认音源的 active queue 索引。
  final int confirmedIndex;

  /// 当前队列名称。
  final String playlistName;

  /// 当前队列标题前缀。
  final String playlistHeader;

  /// 当前重复播放模式。
  final PlaybackRepeatMode repeatMode;

  /// 当前播放模式。
  final PlaybackMode playbackMode;

  /// 恢复播放时等待应用到播放器的进度。
  final Duration pendingRestorePosition;

  /// selection 版本号。
  final int selectionVersion;

  /// 队列结构版本号。
  final int queueVersion;

  /// 当前是否有有效队列。
  bool get hasQueue => activeQueue.isNotEmpty;

  /// UI 当前选中的歌曲。
  PlaybackQueueItem get selectedItem =>
      _itemAt(activeQueue, selectedIndex) ?? const PlaybackQueueItem.empty();

  /// 底层播放器已经确认的歌曲。
  PlaybackQueueItem get confirmedItem =>
      _itemAt(activeQueue, confirmedIndex) ?? const PlaybackQueueItem.empty();

  /// 复制队列状态并替换指定字段。
  PlaybackQueueState copyWith({
    List<PlaybackQueueItem>? originalQueue,
    List<PlaybackQueueItem>? activeQueue,
    int? selectedIndex,
    int? confirmedIndex,
    String? playlistName,
    String? playlistHeader,
    PlaybackRepeatMode? repeatMode,
    PlaybackMode? playbackMode,
    Duration? pendingRestorePosition,
    int? selectionVersion,
    int? queueVersion,
  }) {
    return PlaybackQueueState(
      originalQueue: originalQueue ?? this.originalQueue,
      activeQueue: activeQueue ?? this.activeQueue,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      confirmedIndex: confirmedIndex ?? this.confirmedIndex,
      playlistName: playlistName ?? this.playlistName,
      playlistHeader: playlistHeader ?? this.playlistHeader,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackMode: playbackMode ?? this.playbackMode,
      pendingRestorePosition:
          pendingRestorePosition ?? this.pendingRestorePosition,
      selectionVersion: selectionVersion ?? this.selectionVersion,
      queueVersion: queueVersion ?? this.queueVersion,
    );
  }

  PlaybackQueueItem? _itemAt(List<PlaybackQueueItem> queue, int index) {
    if (index < 0 || index >= queue.length) {
      return null;
    }
    return queue[index];
  }
}
