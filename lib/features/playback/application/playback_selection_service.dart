import 'dart:async';

import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_selection_navigator.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 播放 UI selection 的唯一写入口。
///
/// 页面、按钮和封面滑动只更新 selection；底层播放提交委托给
/// `PlaybackSwitchCoordinator`，避免 UI 当前歌继续借用 audio_service mediaItem。
class PlaybackSelectionService {
  /// 创建播放选择服务。
  PlaybackSelectionService({
    required PlaybackService playbackService,
    required PlaybackSelectionNavigator navigator,
    required PlaybackSwitchCoordinator switchCoordinator,
  })  : _playbackService = playbackService,
        _navigator = navigator,
        _switchCoordinator = switchCoordinator;

  final PlaybackService _playbackService;
  final PlaybackSelectionNavigator _navigator;
  final PlaybackSwitchCoordinator _switchCoordinator;
  final StreamController<PlaybackSelectionState> _stateController =
      StreamController<PlaybackSelectionState>.broadcast();

  PlaybackRepeatMode Function() _repeatMode = () => PlaybackRepeatMode.all;
  PlaybackMode Function() _playbackMode = () => PlaybackMode.playlist;
  PlaybackSelectionState _state = const PlaybackSelectionState();

  /// 当前 selection 快照。
  PlaybackSelectionState get state => _state;

  /// selection 状态变化流。
  Stream<PlaybackSelectionState> get stream => _stateController.stream;

  /// 绑定播放模式读取回调。
  void configure({
    required PlaybackRepeatMode Function() repeatMode,
    required PlaybackMode Function() playbackMode,
  }) {
    _repeatMode = repeatMode;
    _playbackMode = playbackMode;
  }

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
    final selectedIndex = _navigator.clampIndex(
      index: index,
      queueLength: queue.length,
    );
    _emitSelection(
      queue: queue,
      selectedIndex: selectedIndex,
      sourceStatus: PlaybackSelectionSourceStatus.idle,
      bumpVersion: true,
    );
    await _playbackService.changePlayList(
      queue,
      index: selectedIndex < 0 ? 0 : selectedIndex,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
      playNow: false,
      changePlayerSource: false,
      needStore: needStore,
    );
    if (playNow && selectedIndex >= 0) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
  }

  /// 选择队列中的指定索引。
  Future<void> selectIndex(
    int index, {
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final selectedIndex = _navigator.clampIndex(
      index: index,
      queueLength: _state.queue.length,
    );
    if (selectedIndex < 0) {
      return;
    }
    _emitSelection(
      queue: _state.queue,
      selectedIndex: selectedIndex,
      sourceStatus: PlaybackSelectionSourceStatus.idle,
      bumpVersion: true,
    );
    if (playNow) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
  }

  /// 选择下一首。
  Future<void> selectNext({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final index = _navigator.nextIndex(
      queueLength: _state.queue.length,
      selectedIndex: _state.selectedIndex,
      repeatMode: _repeatMode(),
      isRoamingMode: _playbackMode() == PlaybackMode.roaming,
    );
    if (index == null) {
      return;
    }
    await selectIndex(index, trigger: trigger, playNow: playNow);
  }

  /// 选择上一首。
  Future<void> selectPrevious({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final index = _navigator.previousIndex(
      queueLength: _state.queue.length,
      selectedIndex: _state.selectedIndex,
      repeatMode: _repeatMode(),
    );
    if (index == null) {
      return;
    }
    await selectIndex(index, trigger: trigger, playNow: playNow);
  }

  /// 从恢复或队列变化同步 selection 队列，但不提交到底层播放。
  void syncQueueSnapshot(
    List<PlaybackQueueItem> queue, {
    int? preferredIndex,
  }) {
    final currentSelectedId = _state.selectedItem.id;
    var selectedIndex = preferredIndex ??
        queue.indexWhere((item) => item.id == currentSelectedId);
    selectedIndex = _navigator.clampIndex(
      index: selectedIndex,
      queueLength: queue.length,
    );
    _emitSelection(
      queue: queue,
      selectedIndex: selectedIndex,
      sourceStatus: _state.sourceStatus,
      bumpVersion: _state.queue.isEmpty && queue.isNotEmpty,
    );
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
      selection: _state,
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
    required bool bumpVersion,
  }) {
    final selectedItem = selectedIndex >= 0 && selectedIndex < queue.length
        ? queue[selectedIndex]
        : const PlaybackQueueItem.empty();
    _emitState(
      _state.copyWith(
        queue: List<PlaybackQueueItem>.unmodifiable(queue),
        selectedItem: selectedItem,
        selectedIndex: selectedIndex,
        selectionVersion:
            bumpVersion ? _state.selectionVersion + 1 : _state.selectionVersion,
        sourceStatus: sourceStatus,
        sourceError: null,
      ),
    );
  }

  void _emitState(PlaybackSelectionState state) {
    _state = state;
    _stateController.add(state);
  }

  /// 释放 selection 状态流。
  Future<void> dispose() async {
    await _stateController.close();
  }
}
