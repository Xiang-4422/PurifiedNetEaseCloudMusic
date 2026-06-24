import 'dart:async';
import 'dart:developer' as developer;

import 'package:bujuan/core/diagnostics/performance_metric.dart';
import 'package:bujuan/features/playback/playback_performance_logger.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_prefetcher.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 单次底层 source 替换尝试超时时间。
const Duration playbackSourceReplaceAttemptTimeout = Duration(seconds: 4);

/// 整条底层 source 替换和 fallback 链路的总超时时间。
const Duration playbackSourceReplaceFallbackTimeout = Duration(seconds: 12);

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
    Duration replaceAttemptTimeout = playbackSourceReplaceAttemptTimeout,
    Duration replaceFallbackTimeout = playbackSourceReplaceFallbackTimeout,
  })  : _playbackService = playbackService,
        _queueService = queueService,
        _sourcePrefetcher = sourcePrefetcher ?? PlaybackSourcePrefetcher(resolver: sourceResolver),
        _replaceAttemptTimeout = replaceAttemptTimeout,
        _replaceFallbackTimeout = replaceFallbackTimeout;

  final PlaybackService _playbackService;
  final PlaybackQueueService _queueService;
  final PlaybackSourcePrefetcher _sourcePrefetcher;
  final Duration _replaceAttemptTimeout;
  final Duration _replaceFallbackTimeout;
  final StreamController<PlaybackSwitchState> _stateController = StreamController<PlaybackSwitchState>.broadcast(sync: true);
  int _latestVersion = 0;
  int _consecutiveAutoFailures = 0;
  int _switchId = 0;
  int _autoplayCancelVersion = 0;
  Completer<void>? _replaceInFlight;
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
    final totalStopwatch = PlaybackPerformanceLogger.start();
    final version = selectionVersion;
    _latestVersion = version;
    final switchId = ++_switchId;
    final autoplayCancelVersion = _autoplayCancelVersion;
    var sourceKind = '';
    PlaybackSwitchResult complete(
      PlaybackSwitchResult result, {
      required String outcome,
    }) {
      PlaybackPerformanceLogger.elapsedMetric(
        AppPerformanceMetrics.trackSwitch,
        totalStopwatch,
        details: 'switchId=$switchId version=$version id=${item.id} index=$activeIndex trigger=${trigger.name} playNow=$playNow outcome=$outcome success=${result.success} obsolete=${result.isObsolete} source=$sourceKind',
      );
      return result;
    }

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
      return complete(
        PlaybackSwitchResult(
          selectionVersion: version,
          success: false,
          message: '没有可播放的歌曲',
        ),
        outcome: 'invalidSelection',
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
      return complete(
        PlaybackSwitchResult(
          selectionVersion: version,
          success: false,
          isObsolete: true,
        ),
        outcome: 'obsoleteBeforeResolve',
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
    final resolveStopwatch = PlaybackPerformanceLogger.start();
    final sourceResult = await _resolveSource(
      item,
      trigger: trigger,
    );
    PlaybackPerformanceLogger.elapsed(
      'switch.resolveSource',
      resolveStopwatch,
      details: 'switchId=$switchId version=$version id=${item.id} success=${sourceResult.isSuccess} message=${sourceResult.message ?? ''}',
    );
    if (_isObsolete(version)) {
      _emitCancelled(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      );
      return complete(
        PlaybackSwitchResult(
          selectionVersion: version,
          success: false,
          isObsolete: true,
        ),
        outcome: 'obsoleteAfterResolve',
      );
    }
    final source = sourceResult.source;
    if (source == null || source.isEmpty) {
      return complete(
        _failedResult(
          switchId: switchId,
          selectionVersion: version,
          item: item,
          activeIndex: activeIndex,
          trigger: trigger,
          message: sourceResult.message,
        ),
        outcome: 'resolveFailed',
      );
    }
    sourceKind = source.kind.name;
    _emitState(_buildState(
      switchId: switchId,
      selectionVersion: version,
      phase: PlaybackSwitchPhase.readyToReplace,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: playNow,
    ));
    final shouldAutoPlay = playNow && autoplayCancelVersion == _autoplayCancelVersion;
    await _waitForReplaceTurn(
      switchId: switchId,
      selectionVersion: version,
      item: item,
      activeIndex: activeIndex,
    );
    if (_isObsolete(version)) {
      _emitCancelled(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      );
      return complete(
        PlaybackSwitchResult(
          selectionVersion: version,
          success: false,
          isObsolete: true,
        ),
        outcome: 'obsoleteBeforeReplace',
      );
    }
    final replaceTurn = _beginReplaceTurn();
    var success = false;
    try {
      _emitState(_buildState(
        switchId: switchId,
        selectionVersion: version,
        phase: PlaybackSwitchPhase.replacing,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
        autoplayIntent: shouldAutoPlay,
      ));
      final replaceStopwatch = PlaybackPerformanceLogger.start();
      success = await _replaceSourceWithFallback(
        queue: queue,
        item: item,
        activeIndex: activeIndex,
        source: source,
        playNow: shouldAutoPlay,
      ).timeout(
        _replaceFallbackTimeout,
        onTimeout: () => false,
      );
      PlaybackPerformanceLogger.elapsed(
        'switch.replaceSourceWithFallback',
        replaceStopwatch,
        details: 'switchId=$switchId version=$version id=${item.id} index=$activeIndex source=${source.kind.name} success=$success playNow=$shouldAutoPlay',
      );
    } finally {
      _completeReplaceTurn(replaceTurn);
    }
    if (_isObsolete(version)) {
      _emitCancelled(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      );
      return complete(
        PlaybackSwitchResult(
          selectionVersion: version,
          success: false,
          isObsolete: true,
        ),
        outcome: 'obsoleteAfterReplace',
      );
    }
    if (success) {
      _consecutiveAutoFailures = 0;
      final confirmStopwatch = PlaybackPerformanceLogger.start();
      await _queueService.markConfirmed(item: item, index: activeIndex);
      PlaybackPerformanceLogger.elapsed(
        'switch.markConfirmed',
        confirmStopwatch,
        details: 'switchId=$switchId version=$version id=${item.id} index=$activeIndex queue=${queue.length}',
      );
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
      return complete(
        PlaybackSwitchResult(
          selectionVersion: version,
          success: true,
        ),
        outcome: 'confirmed',
      );
    }
    return complete(
      _failedResult(
        switchId: switchId,
        selectionVersion: version,
        item: item,
        activeIndex: activeIndex,
        trigger: trigger,
      ),
      outcome: 'replaceFailed',
    );
  }

  Future<void> _waitForReplaceTurn({
    required int switchId,
    required int selectionVersion,
    required PlaybackQueueItem item,
    required int activeIndex,
  }) async {
    final inFlight = _replaceInFlight;
    if (inFlight == null) {
      return;
    }
    final stopwatch = PlaybackPerformanceLogger.start();
    await inFlight.future;
    PlaybackPerformanceLogger.elapsed(
      'switch.waitReplaceTurn',
      stopwatch,
      details: 'switchId=$switchId version=$selectionVersion id=${item.id} index=$activeIndex',
      warnAfterMs: 1,
    );
  }

  Completer<void> _beginReplaceTurn() {
    final turn = Completer<void>();
    _replaceInFlight = turn;
    return turn;
  }

  void _completeReplaceTurn(Completer<void> turn) {
    if (identical(_replaceInFlight, turn)) {
      _replaceInFlight = null;
    }
    if (!turn.isCompleted) {
      turn.complete();
    }
  }

  Future<bool> _replaceSourceWithFallback({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackResolvedSource source,
    required bool playNow,
  }) async {
    final success = await _replaceSource(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      source: source,
      playNow: playNow,
    );
    if (success) {
      return true;
    }
    if (source.kind == PlaybackResolvedSourceKind.url) {
      return _replaceRemoteSourceWithFallback(
        queue: queue,
        item: item,
        activeIndex: activeIndex,
        playNow: playNow,
        forceRefreshBeforeFirst: true,
      );
    }
    if (source.kind != PlaybackResolvedSourceKind.filePath && source.kind != PlaybackResolvedSourceKind.neteaseCacheStream) {
      return false;
    }
    if (!_canResolveRemoteFallback(item)) {
      return false;
    }
    return _replaceRemoteSourceWithFallback(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      playNow: playNow,
    );
  }

  bool _canResolveRemoteFallback(PlaybackQueueItem item) {
    return item.sourceType != SourceType.local;
  }

  Future<bool> _replaceRemoteSourceWithFallback({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required bool playNow,
    bool forceRefreshBeforeFirst = false,
  }) async {
    if (await _replaceResolvedRemoteSource(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      playNow: playNow,
      forceRefresh: forceRefreshBeforeFirst,
    )) {
      return true;
    }
    if (!forceRefreshBeforeFirst &&
        await _replaceResolvedRemoteSource(
          queue: queue,
          item: item,
          activeIndex: activeIndex,
          playNow: playNow,
          forceRefresh: true,
        )) {
      return true;
    }
    if (!_playbackService.isHighQualityEnabled()) {
      return false;
    }
    _logSwitch('fallback-normal-quality-after-replace-failure id=${item.id}');
    return _replaceResolvedRemoteSource(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      playNow: playNow,
      preferHighQuality: false,
      forceRefresh: true,
    );
  }

  Future<bool> _replaceResolvedRemoteSource({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required bool playNow,
    bool? preferHighQuality,
    bool forceRefresh = false,
  }) async {
    final source = await _safeResolveRemote(
      item,
      preferHighQuality: preferHighQuality,
      forceRefresh: forceRefresh,
    );
    if (source.isEmpty) {
      return false;
    }
    return _replaceSource(
      queue: queue,
      item: item,
      activeIndex: activeIndex,
      source: source,
      playNow: playNow,
    );
  }

  Future<_SourceResolveResult> _resolveSource(
    PlaybackQueueItem item, {
    required PlaybackSwitchTrigger trigger,
  }) async {
    final preferHighQuality = _playbackService.isHighQualityEnabled();
    if (trigger == PlaybackSwitchTrigger.sourceError) {
      if (!_canResolveRemoteFallback(item)) {
        return const _SourceResolveResult.failure('当前本地歌曲文件不可用');
      }
      final primary = await _tryResolveSource(
        item,
        preferHighQuality: preferHighQuality,
        remoteOnly: true,
        forceRefresh: true,
      );
      if (primary.isSuccess || !preferHighQuality) {
        return primary;
      }
      _logSwitch(
        'retry-normal-quality-after-source-error id=${item.id} reason=${primary.message}',
      );
      final fallback = await _tryResolveSource(
        item,
        preferHighQuality: false,
        remoteOnly: true,
        forceRefresh: true,
      );
      return fallback.isSuccess ? fallback : primary;
    }
    final primary = await _tryResolveSource(
      item,
      preferHighQuality: preferHighQuality,
    );
    if (primary.isSuccess || !preferHighQuality) {
      return primary;
    }
    _logSwitch(
      'retry-normal-quality id=${item.id} reason=${primary.message}',
    );
    final fallback = await _tryResolveSource(
      item,
      preferHighQuality: false,
    );
    return fallback.isSuccess ? fallback : primary;
  }

  Future<_SourceResolveResult> _tryResolveSource(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool remoteOnly = false,
    bool forceRefresh = false,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    try {
      final sourceFuture = remoteOnly
          ? _sourcePrefetcher.resolveRemote(
              item,
              preferHighQuality: preferHighQuality,
              forceRefresh: forceRefresh,
            )
          : _sourcePrefetcher.resolve(
              item,
              preferHighQuality: preferHighQuality,
            );
      final source = await sourceFuture.timeout(const Duration(seconds: 12));
      if (source.isEmpty) {
        PlaybackPerformanceLogger.elapsed(
          'switch.tryResolveSource',
          stopwatch,
          details: 'id=${item.id} highQuality=$preferHighQuality remoteOnly=$remoteOnly forceRefresh=$forceRefresh success=false empty=true',
        );
        return const _SourceResolveResult.failure('当前歌曲暂无可用播放地址');
      }
      _logSwitch(
        'resolve-success id=${item.id} highQuality=$preferHighQuality kind=${source.kind}',
      );
      PlaybackPerformanceLogger.elapsed(
        'switch.tryResolveSource',
        stopwatch,
        details: 'id=${item.id} highQuality=$preferHighQuality remoteOnly=$remoteOnly forceRefresh=$forceRefresh success=true kind=${source.kind.name}',
      );
      return _SourceResolveResult.success(source);
    } on TimeoutException catch (error) {
      _logSwitch('resolve-timeout id=${item.id} error=$error');
      PlaybackPerformanceLogger.elapsed(
        'switch.tryResolveSource',
        stopwatch,
        details: 'id=${item.id} highQuality=$preferHighQuality remoteOnly=$remoteOnly forceRefresh=$forceRefresh success=false timeout=true',
      );
      return const _SourceResolveResult.failure('播放地址获取超时，请重试');
    } catch (error) {
      _logSwitch('resolve-failure id=${item.id} error=$error');
      PlaybackPerformanceLogger.elapsed(
        'switch.tryResolveSource',
        stopwatch,
        details: 'id=${item.id} highQuality=$preferHighQuality remoteOnly=$remoteOnly forceRefresh=$forceRefresh success=false error=$error',
      );
      return _SourceResolveResult.failure(_resolveErrorMessage(error));
    }
  }

  Future<PlaybackResolvedSource> _safeResolveRemote(
    PlaybackQueueItem item, {
    bool? preferHighQuality,
    bool forceRefresh = false,
  }) async {
    try {
      return await _sourcePrefetcher
          .resolveRemote(
            item,
            preferHighQuality: preferHighQuality ?? _playbackService.isHighQualityEnabled(),
            forceRefresh: forceRefresh,
          )
          .timeout(const Duration(seconds: 12));
    } catch (error) {
      _logSwitch('remote-resolve-failure id=${item.id} error=$error');
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
  }

  Future<bool> _replaceSource({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackResolvedSource source,
    required bool playNow,
  }) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    try {
      final success = await _playbackService
          .replaceSourceForQueueItem(
            queue: queue,
            item: item,
            activeIndex: activeIndex,
            source: source,
            playNow: playNow,
          )
          .timeout(_replaceAttemptTimeout);
      _logSwitch(
        'replace-${success ? 'success' : 'failure'} id=${item.id} index=$activeIndex kind=${source.kind}',
      );
      PlaybackPerformanceLogger.elapsed(
        'switch.replaceSource',
        stopwatch,
        details: 'id=${item.id} index=$activeIndex queue=${queue.length} kind=${source.kind.name} playNow=$playNow success=$success',
      );
      return success;
    } on TimeoutException catch (error) {
      _logSwitch('replace-timeout id=${item.id} error=$error');
      PlaybackPerformanceLogger.elapsed(
        'switch.replaceSource',
        stopwatch,
        details: 'id=${item.id} index=$activeIndex queue=${queue.length} kind=${source.kind.name} playNow=$playNow success=false timeout=true',
      );
      return false;
    } catch (error) {
      _logSwitch('replace-exception id=${item.id} error=$error');
      PlaybackPerformanceLogger.elapsed(
        'switch.replaceSource',
        stopwatch,
        details: 'id=${item.id} index=$activeIndex queue=${queue.length} kind=${source.kind.name} playNow=$playNow success=false error=$error',
      );
      return false;
    }
  }

  PlaybackSwitchResult _failedResult({
    required int switchId,
    required int selectionVersion,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackSwitchTrigger trigger,
    String? message,
  }) {
    if (_isAutoAdvance(trigger)) {
      _consecutiveAutoFailures++;
    }
    final resolvedMessage = message ?? (_isAutoAdvance(trigger) && _consecutiveAutoFailures >= maxAutoAdvanceFailures ? '连续多首歌曲无法播放' : '当前歌曲暂时无法播放');
    _emitState(_buildState(
      switchId: switchId,
      selectionVersion: selectionVersion,
      phase: PlaybackSwitchPhase.failed,
      item: item,
      activeIndex: activeIndex,
      trigger: trigger,
      autoplayIntent: false,
      message: resolvedMessage,
    ));
    return PlaybackSwitchResult(
      selectionVersion: selectionVersion,
      success: false,
      message: resolvedMessage,
    );
  }

  bool _isObsolete(int version) {
    return version != _latestVersion;
  }

  bool _isAutoAdvance(PlaybackSwitchTrigger trigger) {
    return trigger == PlaybackSwitchTrigger.queueCompletion || trigger == PlaybackSwitchTrigger.modeAutoAdvance;
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
    _logSwitch(
      'phase=${state.phase.name} version=${state.selectionVersion} id=${state.targetItem.id} index=${state.targetIndex} trigger=${state.trigger.name} message=${state.message ?? ''}',
    );
  }

  String _resolveErrorMessage(Object error) {
    final errorText = error.toString().toLowerCase();
    if (errorText.contains('timeout') || errorText.contains('timed out')) {
      return '播放地址获取超时，请重试';
    }
    return '播放地址获取失败，请重试';
  }

  void _logSwitch(String message) {
    developer.log(message, name: 'PlaybackSwitch');
  }

  /// 释放切源状态流。
  Future<void> dispose() async {
    await _stateController.close();
  }
}

class _SourceResolveResult {
  const _SourceResolveResult.success(this.source) : message = null;

  const _SourceResolveResult.failure(this.message) : source = null;

  final PlaybackResolvedSource? source;
  final String? message;

  bool get isSuccess => source != null && !source!.isEmpty;
}
