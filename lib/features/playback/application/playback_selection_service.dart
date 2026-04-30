import 'dart:async';

import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_selection_navigator.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_queue_state.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';

/// 播放 UI selection 的唯一写入口。
///
/// 页面、按钮和封面滑动只更新 selection；底层播放提交委托给
/// `PlaybackSwitchCoordinator`，避免 UI 当前歌继续借用 audio_service mediaItem。
class PlaybackSelectionService {
  /// 创建播放选择服务。
  PlaybackSelectionService({
    required PlaybackQueueService queueService,
    required PlaybackSelectionNavigator navigator,
    required PlaybackSwitchCoordinator switchCoordinator,
  })  : _queueService = queueService,
        _switchCoordinator = switchCoordinator {
    _queueSubscription = _queueService.stream.listen(_syncFromQueueState);
  }

  final PlaybackQueueService _queueService;
  final PlaybackSwitchCoordinator _switchCoordinator;
  final StreamController<PlaybackSelectionState> _stateController =
      StreamController<PlaybackSelectionState>.broadcast();
  late final StreamSubscription<PlaybackQueueState> _queueSubscription;

  PlaybackSelectionState _state = const PlaybackSelectionState();

  /// 当前 selection 快照。
  PlaybackSelectionState get state => _state;

  /// selection 状态变化流。
  Stream<PlaybackSelectionState> get stream => _stateController.stream;

  /// 绑定播放模式读取回调。
  void configure({
    required PlaybackRepeatMode Function() repeatMode,
    required PlaybackMode Function() playbackMode,
  }) {}

  /// 选择并切换播放队列。
  Future<void> selectQueue(
    List<PlaybackQueueItem> queue,
    int index, {
    required String playListName,
    String playListNameHeader = '',
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
    bool needStore = true,
  }) async {
    final queueState = await _queueService.replaceQueue(
      queue,
      index,
      playlistName: playListName,
      needStore: needStore,
      playlistHeader: playListNameHeader,
    );
    _syncFromQueueState(queueState);
    if (playNow && queueState.selectedIndex >= 0) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
  }

  /// 选择队列中的指定索引。
  Future<void> selectIndex(
    int index, {
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final queueState = await _queueService.selectIndex(index);
    _syncFromQueueState(queueState);
    if (queueState.selectedIndex < 0) {
      return;
    }
    if (playNow) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
  }

  /// 选择下一首。
  Future<void> selectNext({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final queueState = await _queueService.selectNext();
    if (queueState == null) {
      return;
    }
    _syncFromQueueState(queueState);
    if (playNow) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
  }

  /// 选择上一首。
  Future<void> selectPrevious({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final queueState = await _queueService.selectPrevious();
    if (queueState == null) {
      return;
    }
    _syncFromQueueState(queueState);
    if (playNow) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
  }

  /// 从队列事实源同步 selection，但不提交到底层播放。
  void syncFromQueueState() {
    _syncFromQueueState(_queueService.state);
  }

  Future<void> _submitCurrentSelection({
    required PlaybackSwitchTrigger trigger,
    required bool playNow,
  }) async {
    final version = _state.selectionVersion;
    _emitState(
      _state.copyWith(
        sourceStatus: PlaybackSelectionSourceStatus.loading,
        sourceError: null,
      ),
    );
    final result = await _switchCoordinator.switchToSelection(
      queue: _state.queue,
      item: _state.selectedItem,
      activeIndex: _state.selectedIndex,
      selectionVersion: _state.selectionVersion,
      trigger: trigger,
      playNow: playNow,
    );
    if (result.isObsolete || _state.selectionVersion != version) {
      return;
    }
    _emitState(
      _state.copyWith(
        sourceStatus: result.success
            ? PlaybackSelectionSourceStatus.ready
            : PlaybackSelectionSourceStatus.error,
        sourceError: result.success ? null : result.message,
      ),
    );
    if (!result.success &&
        (trigger == PlaybackSwitchTrigger.queueCompletion ||
            trigger == PlaybackSwitchTrigger.modeAutoAdvance)) {
      await selectNext(
        trigger: PlaybackSwitchTrigger.modeAutoAdvance,
        playNow: playNow,
      );
    }
  }

  void _emitSelection({
    required List<PlaybackQueueItem> queue,
    required int selectedIndex,
    required PlaybackSelectionSourceStatus sourceStatus,
    required int selectionVersion,
  }) {
    final selectedItem = selectedIndex >= 0 && selectedIndex < queue.length
        ? queue[selectedIndex]
        : const PlaybackQueueItem.empty();
    _emitState(
      _state.copyWith(
        queue: List<PlaybackQueueItem>.unmodifiable(queue),
        selectedItem: selectedItem,
        selectedIndex: selectedIndex,
        selectionVersion: selectionVersion,
        sourceStatus: sourceStatus,
        sourceError: null,
      ),
    );
  }

  void _syncFromQueueState(PlaybackQueueState queueState) {
    final selectedIdChanged =
        _state.selectedItem.id != queueState.selectedItem.id;
    final sourceStatus = selectedIdChanged
        ? PlaybackSelectionSourceStatus.idle
        : _state.sourceStatus;
    _emitSelection(
      queue: queueState.activeQueue,
      selectedIndex: queueState.selectedIndex,
      sourceStatus: sourceStatus,
      selectionVersion: queueState.selectionVersion,
    );
  }

  void _emitState(PlaybackSelectionState state) {
    _state = state;
    _stateController.add(state);
  }

  /// 释放 selection 状态流。
  Future<void> dispose() async {
    await _queueSubscription.cancel();
    await _stateController.close();
  }
}
