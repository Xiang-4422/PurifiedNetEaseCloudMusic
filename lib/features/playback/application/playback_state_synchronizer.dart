import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_preference_port.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
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
    required PlaybackQueueCoordinator queueCoordinator,
    required PlaybackUserContentPort userContentPort,
    required CurrentTrackDownloadUseCase downloadUseCase,
    required PlaybackPreferencePort preferencePort,
    required PlaybackToastPort toastPort,
    required PlaybackLyricUiStateController lyricUiStateController,
  })  : _playbackService = playbackService,
        _queueStore = queueStore,
        _queueCoordinator = queueCoordinator,
        _userContentPort = userContentPort,
        _downloadUseCase = downloadUseCase,
        _preferencePort = preferencePort,
        _toastPort = toastPort,
        _lyricUiStateController = lyricUiStateController;

  final PlaybackService _playbackService;
  final PlaybackQueueStore _queueStore;
  final PlaybackQueueCoordinator _queueCoordinator;
  final PlaybackUserContentPort _userContentPort;
  final CurrentTrackDownloadUseCase _downloadUseCase;
  final PlaybackPreferencePort _preferencePort;
  final PlaybackToastPort _toastPort;
  final PlaybackLyricUiStateController _lyricUiStateController;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  int _lastStoredPositionSecond = -1;
  bool _isFetchingFm = false;
  bool _restoringPlaybackState = false;
  Timer? _currentTrackSideEffectTimer;
  int _currentTrackSideEffectVersion = 0;

  /// 启动播放流订阅、恢复上次状态并同步当前播放状态。
  Future<void> start({
    required PlaybackSessionSync syncSessionState,
    required PlaybackRuntimeSync syncRuntimeState,
    required void Function({int? currentIndex}) syncLyricState,
    required Future<void> Function({bool currentItemUpdated})
        updateCurrentPlayIndex,
    required Future<void> Function(PlaybackQueueItem item) toggleLike,
    required Future<void> Function(PlaybackQueueItem item)
        ensureCurrentTrackArtwork,
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
    );
    await _playbackService.ensureInitialized();

    _subscriptions.add(
      _playbackService.queueStream.listen((queueItems) async {
        syncRuntimeState(queue: queueItems);
        await updateCurrentPlayIndex(currentItemUpdated: false);
      }),
    );

    _subscriptions.add(
      _playbackService.mediaItemStream.listen((queueItem) async {
        if (queueItem == null) return;
        syncRuntimeState(currentSong: queueItem);
        unawaited(_queueStore.saveCurrentSong(queueItem.id));
        _scheduleCurrentTrackSideEffects(
          item: queueItem,
          runtimeState: runtimeState,
          syncCurrentQueueItem: syncCurrentQueueItem,
          ensureCurrentTrackArtwork: ensureCurrentTrackArtwork,
        );
        await updateCurrentPlayIndex(
          currentItemUpdated: !_restoringPlaybackState,
        );
        await _appendRoamingSongsIfNeeded(
          playbackMode: playbackMode,
          runtimeState: runtimeState,
        );
      }),
    );

    _subscriptions.add(
      _playbackService.playbackStateStream.listen((playbackState) {
        _syncCurrentSongFromQueueIndex(
          playbackState.queueIndex,
          runtimeState,
          syncRuntimeState,
        );
        setIsPlaying(playbackState.playing);
        _lyricUiStateController.updateFullScreenLyricTimerCounter(
          isPlaying: isPlaying(),
          setFullScreenLyricOpen: setFullScreenLyricOpen,
          cancelTimer: !isPlaying(),
        );
        if (playbackState.processingState == AudioProcessingState.completed) {
          _playbackService.skipToNext();
        }
      }),
    );

    _subscriptions.add(
      AudioService.createPositionStream(
        minPeriod: const Duration(milliseconds: 200),
        steps: 1000,
      ).listen((newCurPlayingDuration) async {
        syncRuntimeState(currentPosition: newCurPlayingDuration);
        final currentSecond = newCurPlayingDuration.inSeconds;
        if (currentSecond != _lastStoredPositionSecond) {
          _lastStoredPositionSecond = currentSecond;
          unawaited(_queueStore.savePosition(newCurPlayingDuration));
        }
        final newLyricIndex = _lyricUiStateController.resolveCurrentLyricIndex(
          lines: lyricState().lines,
          position: newCurPlayingDuration,
        );
        if (newLyricIndex != lyricState().currentIndex) {
          syncLyricState(currentIndex: newLyricIndex);
        }
      }),
    );

    _restoringPlaybackState = true;
    await _playbackService.restoreLastPlayState();
    _restoringPlaybackState = false;
    await updateCurrentPlayIndex();
  }

  Future<void> _appendRoamingSongsIfNeeded({
    required PlaybackMode Function() playbackMode,
    required PlaybackRuntimeState Function() runtimeState,
  }) async {
    final currentRuntimeState = runtimeState();
    final newIndex = currentRuntimeState.queue.indexWhere(
      (element) => element.id == currentRuntimeState.currentSong.id,
    );
    if (playbackMode() != PlaybackMode.roaming ||
        newIndex < currentRuntimeState.queue.length - 2 ||
        _isFetchingFm) {
      return;
    }

    _isFetchingFm = true;
    try {
      final newFmPlayList = await _userContentPort.loadFmSongs();
      if (playbackMode() == PlaybackMode.roaming && newFmPlayList.isNotEmpty) {
        final shouldAutoPlayNext =
            newIndex == currentRuntimeState.queue.length - 1 &&
                _playbackService.handler.playbackState.value.processingState ==
                    AudioProcessingState.completed;

        await _queueCoordinator.appendRoamingSongs(
          currentQueue: currentRuntimeState.queue,
          incomingSongs: newFmPlayList,
          currentSongId: currentRuntimeState.currentSong.id,
          shouldAutoPlayNext: shouldAutoPlayNext,
          fallbackIndex: newIndex,
        );
      }
    } finally {
      _isFetchingFm = false;
    }
  }

  void _syncCurrentSongFromQueueIndex(
    int? queueIndex,
    PlaybackRuntimeState Function() runtimeState,
    PlaybackRuntimeSync syncRuntimeState,
  ) {
    if (queueIndex == null || queueIndex < 0) {
      return;
    }
    final currentRuntimeState = runtimeState();
    final queue = currentRuntimeState.queue;
    if (queueIndex >= queue.length) {
      return;
    }
    final queueItem = queue[queueIndex];
    if (currentRuntimeState.currentIndex == queueIndex &&
        currentRuntimeState.currentSong.id == queueItem.id) {
      return;
    }
    syncRuntimeState(
      currentIndex: queueIndex,
      currentSong: queueItem,
    );
  }

  Future<void> _cacheCurrentTrackForPlayback(
    PlaybackQueueItem item,
    PlaybackRuntimeState Function() runtimeState,
    Future<void> Function(PlaybackQueueItem item) syncCurrentQueueItem,
  ) async {
    if (item.id.isEmpty ||
        item.mediaType == MediaType.local ||
        item.mediaType == MediaType.neteaseCache) {
      return;
    }
    final updatedItem = await _downloadUseCase.cacheTrackForPlayback(
      item.id,
      preferHighQuality: _preferencePort.isHighQualityEnabled(),
    );
    if (updatedItem != null && runtimeState().currentSong.id == item.id) {
      await syncCurrentQueueItem(updatedItem);
    }
  }

  void _scheduleCurrentTrackSideEffects({
    required PlaybackQueueItem item,
    required PlaybackRuntimeState Function() runtimeState,
    required Future<void> Function(PlaybackQueueItem item) syncCurrentQueueItem,
    required Future<void> Function(PlaybackQueueItem item)
        ensureCurrentTrackArtwork,
  }) {
    final version = ++_currentTrackSideEffectVersion;
    _currentTrackSideEffectTimer?.cancel();
    _currentTrackSideEffectTimer =
        Timer(const Duration(milliseconds: 700), () async {
      if (!_isStillCurrentTrack(version, item.id, runtimeState)) {
        return;
      }
      await _cacheCurrentTrackForPlayback(
        item,
        runtimeState,
        syncCurrentQueueItem,
      );
      if (!_isStillCurrentTrack(version, item.id, runtimeState)) {
        return;
      }
      await ensureCurrentTrackArtwork(item);
    });
  }

  bool _isStillCurrentTrack(
    int version,
    String itemId,
    PlaybackRuntimeState Function() runtimeState,
  ) {
    return version == _currentTrackSideEffectVersion &&
        runtimeState().currentSong.id == itemId;
  }

  /// 停止所有播放状态订阅。
  Future<void> dispose() async {
    _currentTrackSideEffectTimer?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
