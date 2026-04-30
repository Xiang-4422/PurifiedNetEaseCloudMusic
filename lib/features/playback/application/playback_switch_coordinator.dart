import 'dart:async';

import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_prefetcher.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 底层切源状态阶段。
enum PlaybackSwitchPhase {
  /// 没有正在执行的底层切源任务。
  idle,

  /// 正在解析目标歌曲播放源。
  resolving,

  /// 播放源已就绪，等待替换底层 source。
  readyToReplace,

  /// 正在替换 just_audio source。
  replacing,

  /// 目标歌曲已经被底层确认。
  confirmed,

  /// 目标歌曲切源失败。
  failed,

  /// 该切源任务已经被更新的 selection 淘汰。
  cancelled,
}

/// 当前底层切源状态。
class PlaybackSwitchState {
  /// 创建底层切源状态。
  const PlaybackSwitchState({
    this.switchId = 0,
    this.selectionVersion = 0,
    this.phase = PlaybackSwitchPhase.idle,
    this.targetItem = const PlaybackQueueItem.empty(),
    this.targetIndex = -1,
    this.trigger = PlaybackSwitchTrigger.userSelect,
    this.autoplayIntent = false,
    this.message,
  });

  /// 当前切源任务 id。
  final int switchId;

  /// 对应的 selection 版本。
  final int selectionVersion;

  /// 当前切源阶段。
  final PlaybackSwitchPhase phase;

  /// 目标歌曲。
  final PlaybackQueueItem targetItem;

  /// 目标歌曲在 active queue 中的索引。
  final int targetIndex;

  /// 触发本次切源的来源。
  final PlaybackSwitchTrigger trigger;

  /// 切源成功后是否还应自动播放。
  final bool autoplayIntent;

  /// 失败或取消原因。
  final String? message;
}

/// 底层切歌结果。
class PlaybackSwitchResult {
  /// 创建底层切歌结果。
  const PlaybackSwitchResult({
    required this.selectionVersion,
    required this.success,
    this.isObsolete = false,
    this.message,
  });

  /// 该结果对应的选择版本。
  final int selectionVersion;

  /// 底层是否成功设置播放源。
  final bool success;

  /// 结果是否已经被更新的选择版本淘汰。
  final bool isObsolete;

  /// 失败或状态提示信息。
  final String? message;
}

/// 负责把 UI selection 串行提交到底层播放器。
///
/// selection 更新本身不经过这里；这里只处理播放源解析、`setSource` 和最后
/// 一次请求生效规则。
class PlaybackSwitchCoordinator {
  /// 创建底层切歌协调器。
  PlaybackSwitchCoordinator({
    required PlaybackService playbackService,
    required PlaybackQueueService queueService,
    required PlaybackSourceResolver sourceResolver,
    PlaybackSourcePrefetcher? sourcePrefetcher,
  })  : _playbackService = playbackService,
        _queueService = queueService,
        _sourcePrefetcher = sourcePrefetcher ??
            PlaybackSourcePrefetcher(resolver: sourceResolver);

  final PlaybackService _playbackService;
  final PlaybackQueueService _queueService;
  final PlaybackSourcePrefetcher _sourcePrefetcher;
  final StreamController<PlaybackSwitchState> _stateController =
      StreamController<PlaybackSwitchState>.broadcast(sync: true);
  int _latestVersion = 0;
  int _consecutiveAutoFailures = 0;
  int _switchId = 0;
  int _autoplayCancelVersion = 0;
  PlaybackSwitchState _state = const PlaybackSwitchState();

  /// 自动推进时允许连续跳过的最大失败次数。
  static const int maxAutoAdvanceFailures = 3;

  /// 当前底层切源状态。
  PlaybackSwitchState get state => _state;

  /// 底层切源状态流。
  Stream<PlaybackSwitchState> get stream => _stateController.stream;

  /// 取消当前及后续已捕获的自动播放意图。
  void cancelAutoplayIntent() {
    _autoplayCancelVersion++;
  }

  /// 提交当前 selection 到底层播放器。
  Future<PlaybackSwitchResult> switchToSelection({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required int selectionVersion,
    required PlaybackSwitchTrigger trigger,
    required bool playNow,
  }) async {
    final version = selectionVersion;
    _latestVersion = version;
    final switchId = ++_switchId;
    final autoplayCancelVersion = _autoplayCancelVersion;
    if (item.id.isEmpty || activeIndex < 0) {
      _emitState(
        _buildState(
          switchId: switchId,
          selectionVersion: version,
          phase: PlaybackSwitchPhase.failed,
          item: item,
          activeIndex: activeIndex,
          trigger: trigger,
          autoplayIntent: false,
          message: '没有可播放的歌曲',
        ),
      );
      return PlaybackSwitchResult(
        selectionVersion: version,
        success: false,
        message: '没有可播放的歌曲',
      );
    }

    if (_isObsolete(version)) {
      _emitCancelled(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      );
      return PlaybackSwitchResult(
        selectionVersion: version,
        success: false,
        isObsolete: true,
      );
    }
    _emitState(_buildState(
      switchId: switchId,
      selectionVersion: version,
      phase: PlaybackSwitchPhase.resolving,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: playNow,
    ));
    final source = await _sourcePrefetcher
        .resolve(
          item,
          preferHighQuality: _playbackService.isHighQualityEnabled(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => const PlaybackResolvedSource(
            kind: PlaybackResolvedSourceKind.empty,
          ),
        );
    if (_isObsolete(version)) {
      _emitCancelled(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      );
      return PlaybackSwitchResult(
        selectionVersion: version,
        success: false,
        isObsolete: true,
      );
    }
    if (source.isEmpty) {
      return _failedResult(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      );
    }
    _emitState(_buildState(
      switchId: switchId,
      selectionVersion: version,
      phase: PlaybackSwitchPhase.readyToReplace,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: playNow,
    ));
    final shouldAutoPlay =
        playNow && autoplayCancelVersion == _autoplayCancelVersion;
    _emitState(_buildState(
      switchId: switchId,
      selectionVersion: version,
      phase: PlaybackSwitchPhase.replacing,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: shouldAutoPlay,
    ));
    final success = await _replaceSourceWithFallback(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      source: source,
      playNow: shouldAutoPlay,
    ).timeout(
      const Duration(seconds: 12),
      onTimeout: () => false,
    );
    if (_isObsolete(version)) {
      _emitCancelled(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      );
      return PlaybackSwitchResult(
        selectionVersion: version,
        success: false,
        isObsolete: true,
      );
    }
    if (success) {
      _consecutiveAutoFailures = 0;
      await _queueService.markConfirmed(item: item, index: activeIndex);
      _prefetchNeighbors(activeIndex);
      _emitState(_buildState(
        switchId: switchId,
        selectionVersion: version,
        phase: PlaybackSwitchPhase.confirmed,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
        autoplayIntent: shouldAutoPlay,
      ));
      return PlaybackSwitchResult(
        selectionVersion: version,
        success: true,
      );
    }
    return _failedResult(
      switchId: switchId,
      selectionVersion: version,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
    );
  }

  Future<bool> _replaceSourceWithFallback({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackResolvedSource source,
    required bool playNow,
  }) async {
    final success = await _playbackService.replaceSourceForQueueItem(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      source: source,
      playNow: playNow,
    );
    if (success ||
        (source.kind != PlaybackResolvedSourceKind.filePath &&
            source.kind != PlaybackResolvedSourceKind.neteaseCacheStream)) {
      return success;
    }
    final remoteSource = await _sourcePrefetcher.resolveRemote(
      item,
      preferHighQuality: _playbackService.isHighQualityEnabled(),
    );
    if (remoteSource.isEmpty) {
      return false;
    }
    return _playbackService.replaceSourceForQueueItem(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      source: remoteSource,
      playNow: playNow,
    );
  }

  PlaybackSwitchResult _failedResult({
    required int switchId,
    required int selectionVersion,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackSwitchTrigger trigger,
  }) {
    if (_isAutoAdvance(trigger)) {
      _consecutiveAutoFailures++;
    }
    final message = _isAutoAdvance(trigger) &&
            _consecutiveAutoFailures >= maxAutoAdvanceFailures
        ? '连续多首歌曲无法播放'
        : '当前歌曲暂时无法播放';
    _emitState(_buildState(
      switchId: switchId,
      selectionVersion: selectionVersion,
      phase: PlaybackSwitchPhase.failed,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: false,
      message: message,
    ));
    return PlaybackSwitchResult(
      selectionVersion: selectionVersion,
      success: false,
      message: message,
    );
  }

  bool _isObsolete(int version) {
    return version != _latestVersion;
  }

  bool _isAutoAdvance(PlaybackSwitchTrigger trigger) {
    return trigger == PlaybackSwitchTrigger.queueCompletion ||
        trigger == PlaybackSwitchTrigger.modeAutoAdvance;
  }

  void _prefetchNeighbors(int activeIndex) {
    final queue = _queueService.state.activeQueue;
    for (final index in <int>[activeIndex - 1, activeIndex + 1]) {
      if (index >= 0 && index < queue.length) {
        _sourcePrefetcher.prefetch(
          queue[index],
          preferHighQuality: _playbackService.isHighQualityEnabled(),
        );
      }
    }
  }

  void _emitCancelled({
    required int switchId,
    required int selectionVersion,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackSwitchTrigger trigger,
  }) {
    _emitState(_buildState(
      switchId: switchId,
      selectionVersion: selectionVersion,
      phase: PlaybackSwitchPhase.cancelled,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: false,
    ));
  }

  PlaybackSwitchState _buildState({
    required int switchId,
    required int selectionVersion,
    required PlaybackSwitchPhase phase,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackSwitchTrigger trigger,
    required bool autoplayIntent,
    String? message,
  }) {
    return PlaybackSwitchState(
      switchId: switchId,
      selectionVersion: selectionVersion,
      phase: phase,
      targetItem: item,
      targetIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: autoplayIntent,
      message: message,
    );
  }

  void _emitState(PlaybackSwitchState state) {
    _state = state;
    _stateController.add(state);
  }

  /// 释放切源状态流。
  Future<void> dispose() async {
    await _stateController.close();
  }
}
