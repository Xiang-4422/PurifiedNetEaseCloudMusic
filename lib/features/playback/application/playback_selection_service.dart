import 'dart:async';

import 'package:bujuan/features/playback/playback_performance_logger.dart';
import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
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
    Duration userSkipCoalesceDelay = const Duration(milliseconds: 220),
  })  : _queueService = queueService,
        _switchCoordinator = switchCoordinator,
        _userSkipCoalesceDelay = userSkipCoalesceDelay {
    _queueSubscription = _queueService.stream.listen(_syncFromQueueState);
  }

  final PlaybackQueueService _queueService;
  final PlaybackSwitchCoordinator _switchCoordinator;
  final Duration _userSkipCoalesceDelay;
  final StreamController<PlaybackSelectionState> _stateController = StreamController<PlaybackSelectionState>.broadcast();
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
    final stopwatch = PlaybackPerformanceLogger.start();
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
    PlaybackPerformanceLogger.elapsed(
      'selection.selectQueue',
      stopwatch,
      details: 'trigger=${trigger.name} index=${queueState.selectedIndex} queue=${queueState.activeQueue.length} playNow=$playNow',
    );
  }

  /// 选择队列中的指定索引。
  Future<void> selectIndex(
    int index, {
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    final queueState = await _queueService.selectIndex(index);
    _syncFromQueueState(queueState);
    if (queueState.selectedIndex < 0) {
      PlaybackPerformanceLogger.elapsed(
        'selection.selectIndex.empty',
        stopwatch,
        details: 'requested=$index queue=${queueState.activeQueue.length}',
      );
      return;
    }
    if (playNow) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
    PlaybackPerformanceLogger.elapsed(
      'selection.selectIndex',
      stopwatch,
      details: 'trigger=${trigger.name} requested=$index selected=${queueState.selectedIndex} queue=${queueState.activeQueue.length} playNow=$playNow',
    );
  }

  /// 选择下一首。
  Future<void> selectNext({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    final queueState = _usesConfirmedIndex(trigger) ? await _queueService.selectNextFromConfirmed() : await _queueService.selectNext();
    if (queueState == null) {
      PlaybackPerformanceLogger.elapsed(
        'selection.selectNext.empty',
        stopwatch,
        details: 'trigger=${trigger.name}',
      );
      return;
    }
    _syncFromQueueState(queueState);
    if (playNow) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
    PlaybackPerformanceLogger.elapsed(
      'selection.selectNext',
      stopwatch,
      details: 'trigger=${trigger.name} selected=${queueState.selectedIndex} queue=${queueState.activeQueue.length} playNow=$playNow',
    );
  }

  /// 选择上一首。
  Future<void> selectPrevious({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    final queueState = await _queueService.selectPrevious();
    if (queueState == null) {
      PlaybackPerformanceLogger.elapsed(
        'selection.selectPrevious.empty',
        stopwatch,
        details: 'trigger=${trigger.name}',
      );
      return;
    }
    _syncFromQueueState(queueState);
    if (playNow) {
      await _submitCurrentSelection(trigger: trigger, playNow: true);
    }
    PlaybackPerformanceLogger.elapsed(
      'selection.selectPrevious',
      stopwatch,
      details: 'trigger=${trigger.name} selected=${queueState.selectedIndex} queue=${queueState.activeQueue.length} playNow=$playNow',
    );
  }

  /// 从队列事实源同步 selection，但不提交到底层播放。
  void syncFromQueueState() {
    _syncFromQueueState(_queueService.state);
  }

  /// 提交当前 selection 到底层播放。
  Future<void> submitCurrent({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) {
    if (!_state.hasSelection) {
      return Future<void>.value();
    }
    return _submitCurrentSelection(trigger: trigger, playNow: playNow);
  }

  Future<void> _submitCurrentSelection({
    required PlaybackSwitchTrigger trigger,
    required bool playNow,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    var outcome = 'success';
    final version = _state.selectionVersion;
    final selectedItem = _state.selectedItem;
    final selectedIndex = _state.selectedIndex;
    final queueLength = _state.queue.length;
    try {
      _emitState(
        _state.copyWith(
          sourceStatus: PlaybackSelectionSourceStatus.loading,
          sourceError: null,
        ),
      );
      if (_shouldCoalesceUserSkip(trigger, playNow)) {
        final coalesceStopwatch = PlaybackPerformanceLogger.start();
        if (_userSkipCoalesceDelay > Duration.zero) {
          await Future<void>.delayed(_userSkipCoalesceDelay);
        }
        PlaybackPerformanceLogger.elapsed(
          'selection.submit.coalesceUserSkip',
          coalesceStopwatch,
          details: 'version=$version id=${selectedItem.id} index=$selectedIndex delay=${_userSkipCoalesceDelay.inMilliseconds}',
          warnAfterMs: 1,
        );
        if (_state.selectionVersion != version) {
          outcome = 'obsoleteBeforeSwitch';
          return;
        }
      }
      final switchStopwatch = PlaybackPerformanceLogger.start();
      final result = await _switchCoordinator.switchToSelection(
        queue: _state.queue,
        item: _state.selectedItem,
        activeIndex: _state.selectedIndex,
        selectionVersion: _state.selectionVersion,
        trigger: trigger,
        playNow: playNow,
      );
      PlaybackPerformanceLogger.elapsed(
        'selection.submit.switchToSelection',
        switchStopwatch,
        details: 'version=$version id=${selectedItem.id} index=$selectedIndex success=${result.success} obsolete=${result.isObsolete}',
      );
      if (result.isObsolete || _state.selectionVersion != version) {
        outcome = 'obsolete';
        return;
      }
      _emitState(
        _state.copyWith(
          sourceStatus: result.success ? PlaybackSelectionSourceStatus.ready : PlaybackSelectionSourceStatus.error,
          sourceError: result.success ? null : result.message,
        ),
      );
      if (!result.success && _shouldRollbackToConfirmed(trigger)) {
        outcome = 'rollback';
        await _rollbackToConfirmedSelection(result.message);
        return;
      }
      if (!result.success && (trigger == PlaybackSwitchTrigger.queueCompletion || trigger == PlaybackSwitchTrigger.modeAutoAdvance)) {
        outcome = 'autoAdvance';
        await selectNext(
          trigger: PlaybackSwitchTrigger.modeAutoAdvance,
          playNow: playNow,
        );
      }
      if (!result.success) {
        outcome = 'failed';
      }
    } catch (error) {
      outcome = 'exception:$error';
      rethrow;
    } finally {
      PlaybackPerformanceLogger.elapsed(
        'selection.submitCurrent',
        stopwatch,
        details: 'version=$version id=${selectedItem.id} index=$selectedIndex queue=$queueLength trigger=${trigger.name} playNow=$playNow outcome=$outcome',
      );
    }
  }

  void _emitSelection({
    required List<PlaybackQueueItem> queue,
    required int selectedIndex,
    required PlaybackSelectionSourceStatus sourceStatus,
    required int selectionVersion,
  }) {
    final selectedItem = selectedIndex >= 0 && selectedIndex < queue.length ? queue[selectedIndex] : const PlaybackQueueItem.empty();
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
    final selectedIdChanged = _normalizedQueueItemId(_state.selectedItem.id) != _normalizedQueueItemId(queueState.selectedItem.id);
    final sourceStatus = selectedIdChanged ? PlaybackSelectionSourceStatus.idle : _state.sourceStatus;
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

  bool _usesConfirmedIndex(PlaybackSwitchTrigger trigger) {
    return trigger == PlaybackSwitchTrigger.queueCompletion || trigger == PlaybackSwitchTrigger.modeAutoAdvance;
  }

  bool _shouldRollbackToConfirmed(PlaybackSwitchTrigger trigger) {
    return trigger == PlaybackSwitchTrigger.userSelect || trigger == PlaybackSwitchTrigger.userNext || trigger == PlaybackSwitchTrigger.userPrevious;
  }

  String _normalizedQueueItemId(String id) {
    return id.trim();
  }

  bool _shouldCoalesceUserSkip(
    PlaybackSwitchTrigger trigger,
    bool playNow,
  ) {
    return playNow && (trigger == PlaybackSwitchTrigger.userNext || trigger == PlaybackSwitchTrigger.userPrevious);
  }

  Future<void> _rollbackToConfirmedSelection(String? errorMessage) async {
    final confirmedIndex = _queueService.state.confirmedIndex;
    if (confirmedIndex < 0 || confirmedIndex >= _queueService.state.activeQueue.length || confirmedIndex == _state.selectedIndex) {
      return;
    }
    final queueState = await _queueService.selectIndex(confirmedIndex);
    _syncFromQueueState(queueState);
    _emitState(
      _state.copyWith(
        sourceStatus: PlaybackSelectionSourceStatus.error,
        sourceError: errorMessage,
      ),
    );
  }

  /// 释放 selection 状态流。
  Future<void> dispose() async {
    await _queueSubscription.cancel();
    await _stateController.close();
  }
}
