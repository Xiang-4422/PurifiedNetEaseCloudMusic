import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 播放选择层的音源状态。
enum PlaybackSelectionSourceStatus {
  /// 当前选择还没有提交到底层播放器。
  idle,

  /// 当前选择正在解析或设置播放源。
  loading,

  /// 当前选择已经被底层播放器确认。
  ready,

  /// 当前选择的播放源解析或设置失败。
  error,
}

/// 用户意图层的播放选择状态。
///
/// 这个状态只描述 App UI 应该展示哪首歌，不代表 `audio_service` 已经成功
/// 设置音源。通知栏和底层播放事实应继续读取 confirmed runtime 状态。
class PlaybackSelectionState {
  /// 创建播放选择状态。
  const PlaybackSelectionState({
    this.queue = const <PlaybackQueueItem>[],
    this.selectedItem = const PlaybackQueueItem.empty(),
    this.selectedIndex = -1,
    this.selectionVersion = 0,
    this.sourceStatus = PlaybackSelectionSourceStatus.idle,
    this.sourceError,
  });

  /// 当前 App 播放队列快照。
  final List<PlaybackQueueItem> queue;

  /// UI 当前选中的歌曲。
  final PlaybackQueueItem selectedItem;

  /// UI 当前选中歌曲在队列中的索引。
  final int selectedIndex;

  /// 选择版本号，用于丢弃旧切歌请求和旧副作用结果。
  final int selectionVersion;

  /// 当前选择的底层音源状态。
  final PlaybackSelectionSourceStatus sourceStatus;

  /// 当前选择的播放源错误信息。
  final String? sourceError;

  /// 当前是否有可展示的选中歌曲。
  bool get hasSelection => selectedItem.id.isNotEmpty && selectedIndex >= 0;

  /// 复制选择状态并替换指定字段。
  PlaybackSelectionState copyWith({
    List<PlaybackQueueItem>? queue,
    PlaybackQueueItem? selectedItem,
    int? selectedIndex,
    int? selectionVersion,
    PlaybackSelectionSourceStatus? sourceStatus,
    Object? sourceError = _unchanged,
  }) {
    return PlaybackSelectionState(
      queue: queue ?? this.queue,
      selectedItem: selectedItem ?? this.selectedItem,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectionVersion: selectionVersion ?? this.selectionVersion,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      sourceError: identical(sourceError, _unchanged)
          ? this.sourceError
          : sourceError as String?,
    );
  }
}

const Object _unchanged = Object();
