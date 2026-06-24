import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/confirmed_playback_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_background_task_runner.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_preference_port.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_source_error_recovery_gate.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 播放会话状态同步回调，用于把服务层变化写回控制器状态。
typedef PlaybackSessionSync = void Function({
  PlaybackMode? playbackMode,
  PlaybackRepeatMode? repeatMode,
  String? playlistName,
  String? playlistHeader,
  bool? isPlayingLikedSongs,
});

/// 播放运行态同步回调，用于更新队列、当前歌曲和播放进度。
typedef PlaybackRuntimeSync = void Function({
  List<PlaybackQueueItem>? queue,
  PlaybackQueueItem? currentSong,
  int? currentIndex,
  Duration? currentPosition,
});

/// 播放状态同步器，集中订阅底层播放流并派发给 UI 状态。
class PlaybackStateSynchronizer {
  /// 创建播放状态同步器。
  PlaybackStateSynchronizer({
    required PlaybackService playbackService,
    required PlaybackQueueStore queueStore,
    required PlaybackQueueService queueService,
    required PlaybackQueueCoordinator queueCoordinator,
    required PlaybackUserContentPort userContentPort,
    required CurrentTrackDownloadUseCase downloadUseCase,
    required PlaybackPreferencePort preferencePort,
    required PlaybackToastPort toastPort,
    required PlaybackLyricUiStateController lyricUiStateController,
    required PlaybackSelectionService selectionService,
    required ConfirmedPlaybackEffectCoordinator sideEffectCoordinator,
    PlaybackBackgroundErrorHandler? onBackgroundError,
  })  : _playbackService = playbackService,
        _queueStore = queueStore,
        _queueService = queueService,
        _queueCoordinator = queueCoordinator,
        _userContentPort = userContentPort,
        _downloadUseCase = downloadUseCase,
        _preferencePort = preferencePort,
        _toastPort = toastPort,
        _lyricUiStateController = lyricUiStateController,
        _selectionService = selectionService,
        _sideEffectCoordinator = sideEffectCoordinator,
        _backgroundTasks = PlaybackBackgroundTaskRunner(
          onError: onBackgroundError,
        );

  final PlaybackService _playbackService;
  final PlaybackQueueStore _queueStore;
  final PlaybackQueueService _queueService;
  final PlaybackQueueCoordinator _queueCoordinator;
  final PlaybackUserContentPort _userContentPort;
  final CurrentTrackDownloadUseCase _downloadUseCase;
  final PlaybackPreferencePort _preferencePort;
  final PlaybackToastPort _toastPort;
  final PlaybackLyricUiStateController _lyricUiStateController;
  final PlaybackSelectionService _selectionService;
  final ConfirmedPlaybackEffectCoordinator _sideEffectCoordinator;
  final PlaybackBackgroundTaskRunner _backgroundTasks;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Duration _latestPosition = Duration.zero;
  Duration _lastStoredPosition = Duration.zero;
  String _lastPositionTrackId = '';
  bool _isFetchingFm = false;
  String? _lastConfirmedSideEffectKey;
  bool _completionAdvanceInFlight = false;
  final PlaybackSourceErrorRecoveryGate _sourceErrorRecoveryGate = PlaybackSourceErrorRecoveryGate();

  static const Duration _positionSaveInterval = Duration(seconds: 5);

  /// 启动播放流订阅、恢复上次状态并同步当前播放状态。
  Future<void> start({
    required PlaybackSessionSync syncSessionState,
    required PlaybackRuntimeSync syncRuntimeState,
    required void Function({int? currentIndex}) syncLyricState,
    required void Function(List<PlaybackQueueItem> queue, int selectedIndex) syncSelectionQueue,
    required Future<void> Function({bool currentItemUpdated}) updateCurrentPlayIndex,
    required Future<void> Function(PlaybackQueueItem item) toggleLike,
    required Future<void> Function(PlaybackQueueItem item) ensureCurrentTrackArtwork,
    required Future<void> Function(PlaybackQueueItem item) syncCurrentQueueItem,
    required PlaybackRuntimeState Function() runtimeState,
    required PlaybackLyricState Function() lyricState,
    required PlaybackMode Function() playbackMode,
    required void Function(bool isPlaying) setIsPlaying,
    required bool Function() isPlaying,
    required void Function(bool isOpen) setFullScreenLyricOpen,
  }) async {
    _playbackService.bindControllerState(
      onRestorePlaybackMode: (mode) => syncSessionState(playbackMode: mode),
      onRepeatModeChanged: (mode) => syncSessionState(repeatMode: mode),
      onPlaylistMetaChanged: (playlistName, playlistHeader, isLikedSongs) {
        syncSessionState(
          playlistName: playlistName,
          playlistHeader: playlistHeader,
          isPlayingLikedSongs: isLikedSongs,
        );
      },
      isHighQualityEnabled: _preferencePort.isHighQualityEnabled,
      onToggleLike: toggleLike,
      onToast: _toastPort.show,
      isPlaylistMode: () => playbackMode() == PlaybackMode.playlist,
      isRoamingMode: () => playbackMode() == PlaybackMode.roaming,
      onSkipToPrevious: () => _selectionService.selectPrevious(
        trigger: PlaybackSwitchTrigger.userPrevious,
      ),
      onSkipToNext: () => _selectionService.selectNext(
        trigger: PlaybackSwitchTrigger.userNext,
      ),
    );
    await _playbackService.ensureInitialized();
    final restoreData = await _playbackService.loadRestoreData();
    syncSessionState(
      playbackMode: restoreData.playbackMode,
      repeatMode: restoreData.repeatMode,
      playlistName: restoreData.playlistName,
      playlistHeader: restoreData.playlistHeader,
      isPlayingLikedSongs: restoreData.playlistName == '喜欢的音乐',
    );
    await _queueService.restoreFromData(restoreData);
    syncSelectionQueue(
      _selectionService.state.queue,
      _selectionService.state.selectedIndex,
    );

    _subscriptions.add(
      _playbackService.queueStream.listen((queueItems) {
        _backgroundTasks.run(
          taskName: 'playback.queueStream.sync',
          task: () async {
            syncRuntimeState(queue: queueItems);
            await updateCurrentPlayIndex(currentItemUpdated: false);
          },
        );
      }),
    );

    _subscriptions.add(
      _playbackService.mediaItemStream.listen((queueItem) {
        if (queueItem == null) return;
        final queueItemId = _normalizedItemId(queueItem.id);
        if (queueItemId.isEmpty) return;
        final normalizedQueueItem = _normalizedQueueItem(queueItem);
        _backgroundTasks.run(
          taskName: 'playback.mediaItem.sync',
          trackId: queueItemId,
          task: () async {
            final trackChanged = _lastPositionTrackId.isNotEmpty && _lastPositionTrackId != queueItemId;
            if (trackChanged) {
              _latestPosition = Duration.zero;
              _lastStoredPosition = Duration.zero;
            }
            _lastPositionTrackId = queueItemId;
            final queueState = _queueService.state;
            final confirmedIndex = queueState.confirmedIndex >= 0
                ? queueState.confirmedIndex
                : queueState.activeQueue.indexWhere(
                    (item) => _normalizedItemId(item.id) == queueItemId,
                  );
            syncRuntimeState(
              currentSong: normalizedQueueItem,
              currentIndex: confirmedIndex,
              currentPosition: trackChanged ? Duration.zero : null,
            );
            _backgroundTasks.run(
              taskName: 'playback.currentSong.save',
              trackId: queueItemId,
              task: () => _queueStore.saveCurrentSong(
                queueItemId,
                position: trackChanged ? Duration.zero : null,
              ),
            );
            await updateCurrentPlayIndex(currentItemUpdated: false);
            await _appendRoamingSongsIfNeeded(
              playbackMode: playbackMode,
              runtimeState: runtimeState,
            );
          },
        );
      }),
    );

    _subscriptions.add(
      _playbackService.playbackStateStream.listen((playbackState) {
        _backgroundTasks.run(
          taskName: 'playback.state.sync',
          task: () {
            final trackId = _normalizedItemId(runtimeState().currentSong.id);
            _scheduleConfirmedCurrentTrackSideEffects(
              playbackState: playbackState,
              runtimeState: runtimeState,
              syncCurrentQueueItem: syncCurrentQueueItem,
              ensureCurrentTrackArtwork: ensureCurrentTrackArtwork,
              updateCurrentPlayIndex: updateCurrentPlayIndex,
            );
            setIsPlaying(playbackState.playing);
            _lyricUiStateController.updateFullScreenLyricTimerCounter(
              isPlaying: isPlaying(),
              setFullScreenLyricOpen: setFullScreenLyricOpen,
              cancelTimer: !isPlaying(),
            );
            if (!playbackState.playing || playbackState.processingState == AudioProcessingState.completed) {
              _backgroundTasks.run(
                taskName: 'playback.position.saveOnStateChange',
                trackId: trackId.isEmpty ? null : trackId,
                task: () => _savePlaybackPosition(force: true),
              );
            }
            if (playbackState.processingState != AudioProcessingState.completed) {
              _completionAdvanceInFlight = false;
            } else if (!_completionAdvanceInFlight) {
              _advanceAfterQueueCompletion(trackId: trackId);
            }
            if (_hasConfirmedPlaybackSource(playbackState.processingState)) {
              _sourceErrorRecoveryGate.markSourceReady();
            } else if (playbackState.processingState == AudioProcessingState.error) {
              _recoverCurrentSourceAfterPlaybackError(runtimeState);
            }
          },
        );
      }),
    );

    _subscriptions.add(
      AudioService.createPositionStream(
        minPeriod: const Duration(milliseconds: 200),
        steps: 1000,
      ).listen((newCurPlayingDuration) {
        _backgroundTasks.run(
          taskName: 'playback.positionStream.sync',
          task: () {
            final trackId = _normalizedItemId(runtimeState().currentSong.id);
            _latestPosition = newCurPlayingDuration;
            syncRuntimeState(currentPosition: newCurPlayingDuration);
            _backgroundTasks.run(
              taskName: 'playback.position.savePeriodic',
              trackId: trackId.isEmpty ? null : trackId,
              task: () => _savePlaybackPosition(),
            );
            if (_normalizedItemId(_selectionService.state.selectedItem.id) != trackId) {
              if (lyricState().currentIndex != -1) {
                syncLyricState(currentIndex: -1);
              }
              return;
            }
            final newLyricIndex = _lyricUiStateController.resolveCurrentLyricIndex(
              lines: lyricState().lines,
              position: newCurPlayingDuration,
            );
            if (newLyricIndex != lyricState().currentIndex) {
              syncLyricState(currentIndex: newLyricIndex);
            }
          },
        );
      }),
    );

    await updateCurrentPlayIndex(currentItemUpdated: false);
  }

  Future<void> _savePlaybackPosition({bool force = false}) async {
    final position = _latestPosition;
    if (position < Duration.zero) {
      return;
    }
    if (!force && (position - _lastStoredPosition).inMilliseconds.abs() < _positionSaveInterval.inMilliseconds) {
      return;
    }
    if (force && position == _lastStoredPosition) {
      return;
    }
    _lastStoredPosition = position;
    await _queueStore.savePosition(position);
  }

  Future<void> _appendRoamingSongsIfNeeded({
    required PlaybackMode Function() playbackMode,
    required PlaybackRuntimeState Function() runtimeState,
  }) async {
    final currentRuntimeState = runtimeState();
    final currentSongId = _normalizedItemId(currentRuntimeState.currentSong.id);
    if (currentSongId.isEmpty) {
      return;
    }
    final newIndex = currentRuntimeState.queue.indexWhere(
      (element) => _normalizedItemId(element.id) == currentSongId,
    );
    if (playbackMode() != PlaybackMode.roaming || newIndex < currentRuntimeState.queue.length - 2 || _isFetchingFm) {
      return;
    }

    _isFetchingFm = true;
    try {
      final newFmPlayList = await _userContentPort.loadFmSongs();
      if (playbackMode() == PlaybackMode.roaming && newFmPlayList.isNotEmpty) {
        final shouldAutoPlayNext = newIndex == currentRuntimeState.queue.length - 1 && _playbackService.handler.playbackState.value.processingState == AudioProcessingState.completed;

        await _queueCoordinator.appendRoamingSongs(
          currentQueue: currentRuntimeState.queue,
          incomingSongs: newFmPlayList,
          currentSongId: currentSongId,
          shouldAutoPlayNext: shouldAutoPlayNext,
          fallbackIndex: newIndex,
        );
      }
    } finally {
      _isFetchingFm = false;
    }
  }

  Future<void> _cacheCurrentTrackForPlayback(
    PlaybackQueueItem item,
    PlaybackRuntimeState Function() runtimeState,
    Future<void> Function(PlaybackQueueItem item) syncCurrentQueueItem,
  ) async {
    final itemId = _normalizedItemId(item.id);
    if (itemId.isEmpty || item.mediaType == MediaType.local || item.mediaType == MediaType.neteaseCache) {
      return;
    }
    final updatedItem = await _downloadUseCase.cacheTrackForPlayback(
      itemId,
      preferHighQuality: _preferencePort.isHighQualityEnabled(),
    );
    if (updatedItem != null && _isStillCurrentTrack(itemId, runtimeState)) {
      await syncCurrentQueueItem(_normalizedQueueItem(updatedItem));
    }
  }

  void _scheduleCurrentTrackSideEffects({
    required PlaybackQueueItem item,
    required PlaybackRuntimeState Function() runtimeState,
    required Future<void> Function(PlaybackQueueItem item) syncCurrentQueueItem,
    required Future<void> Function(PlaybackQueueItem item) ensureCurrentTrackArtwork,
  }) {
    final itemId = _normalizedItemId(item.id);
    if (itemId.isEmpty) {
      return;
    }
    final normalizedItem = _normalizedQueueItem(item);
    _sideEffectCoordinator.schedule(
      channel: 'confirmed-cache-artwork',
      delay: const Duration(milliseconds: 700),
      trackId: itemId,
      isStillCurrent: (trackId) => _isStillCurrentTrack(trackId, runtimeState),
      run: () async {
        await _cacheCurrentTrackForPlayback(
          normalizedItem,
          runtimeState,
          syncCurrentQueueItem,
        );
        if (!_isStillCurrentTrack(itemId, runtimeState)) {
          return;
        }
        await ensureCurrentTrackArtwork(normalizedItem);
      },
    );
  }

  void _scheduleConfirmedCurrentTrackSideEffects({
    required PlaybackState playbackState,
    required PlaybackRuntimeState Function() runtimeState,
    required Future<void> Function(PlaybackQueueItem item) syncCurrentQueueItem,
    required Future<void> Function(PlaybackQueueItem item) ensureCurrentTrackArtwork,
    required Future<void> Function({bool currentItemUpdated}) updateCurrentPlayIndex,
  }) {
    if (!_hasConfirmedPlaybackSource(playbackState.processingState)) {
      return;
    }
    final queueIndex = playbackState.queueIndex;
    if (queueIndex == null || queueIndex < 0) {
      return;
    }
    final item = _normalizedQueueItem(runtimeState().currentSong);
    final itemId = item.id;
    if (itemId.isEmpty) {
      return;
    }
    final selection = _selectionService.state;
    if (_normalizedItemId(selection.selectedItem.id) != itemId) {
      return;
    }
    final sideEffectKey = '${selection.selectionVersion}:$queueIndex:$itemId';
    if (_lastConfirmedSideEffectKey == sideEffectKey) {
      return;
    }
    _lastConfirmedSideEffectKey = sideEffectKey;
    _backgroundTasks.run(
      taskName: 'playback.currentIndex.updateConfirmed',
      trackId: itemId,
      task: () => updateCurrentPlayIndex(currentItemUpdated: true),
    );
    _scheduleCurrentTrackSideEffects(
      item: item,
      runtimeState: runtimeState,
      syncCurrentQueueItem: syncCurrentQueueItem,
      ensureCurrentTrackArtwork: ensureCurrentTrackArtwork,
    );
  }

  bool _hasConfirmedPlaybackSource(AudioProcessingState processingState) {
    return processingState == AudioProcessingState.ready || processingState == AudioProcessingState.buffering;
  }

  void _recoverCurrentSourceAfterPlaybackError(
    PlaybackRuntimeState Function() runtimeState,
  ) {
    final item = runtimeState().currentSong;
    final normalizedItemId = _normalizedItemId(item.id);
    final selection = _selectionService.state;
    final recoveryKey = _sourceErrorRecoveryGate.startRecovery(
      currentItemId: normalizedItemId,
      selection: selection,
    );
    if (recoveryKey == null) {
      return;
    }
    final recoveryItemId = normalizedItemId;
    final recoverySelectionVersion = selection.selectionVersion;
    _backgroundTasks.run(
      taskName: 'playback.sourceError.recover',
      trackId: normalizedItemId,
      task: () => _submitCurrentAfterPlaybackSourceError(
        itemId: recoveryItemId,
        selectionVersion: recoverySelectionVersion,
        recoveryKey: recoveryKey,
      ),
    );
  }

  Future<void> _submitCurrentAfterPlaybackSourceError({
    required String itemId,
    required int selectionVersion,
    required String recoveryKey,
  }) async {
    try {
      final normalizedItemId = _normalizedItemId(itemId);
      final selection = _selectionService.state;
      final normalizedSelectedItemId = _normalizedItemId(selection.selectedItem.id);
      if (normalizedItemId.isEmpty || selection.selectionVersion != selectionVersion || normalizedSelectedItemId != normalizedItemId) {
        return;
      }
      await _selectionService.submitCurrent(
        trigger: PlaybackSwitchTrigger.sourceError,
        playNow: true,
      );
    } finally {
      _sourceErrorRecoveryGate.completeRecovery(recoveryKey);
    }
  }

  void _advanceAfterQueueCompletion({required String trackId}) {
    _completionAdvanceInFlight = true;
    _backgroundTasks.run(
      taskName: 'playback.completion.selectNext',
      trackId: trackId.isEmpty ? null : trackId,
      task: () async {
        try {
          await _selectionService.selectNext(
            trigger: PlaybackSwitchTrigger.queueCompletion,
          );
        } catch (_) {
          _completionAdvanceInFlight = false;
          rethrow;
        }
      },
    );
  }

  bool _isStillCurrentTrack(
    String itemId,
    PlaybackRuntimeState Function() runtimeState,
  ) {
    final normalizedItemId = _normalizedItemId(itemId);
    return normalizedItemId.isNotEmpty && _normalizedItemId(runtimeState().currentSong.id) == normalizedItemId && _normalizedItemId(_selectionService.state.selectedItem.id) == normalizedItemId;
  }

  PlaybackQueueItem _normalizedQueueItem(PlaybackQueueItem item) {
    final normalizedItemId = _normalizedItemId(item.id);
    if (normalizedItemId == item.id) {
      return item;
    }
    return item.copyWith(id: normalizedItemId);
  }

  String _normalizedItemId(String itemId) {
    return itemId.trim();
  }

  /// 停止所有播放状态订阅。
  Future<void> dispose() async {
    _sideEffectCoordinator.cancel('confirmed-cache-artwork');
    await _savePlaybackPosition(force: true);
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
