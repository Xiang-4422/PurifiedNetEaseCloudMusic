part of 'player_controller.dart';

/// 播放控制器的音频服务状态同步逻辑。
extension PlayerStateSync on PlayerController {
  /// 统一接管音频服务的状态流，避免页面各自监听 `AudioService` 形成重复副作用。
  Future<void> initAudioHandler() async {
    await _stateSynchronizer.start(
      syncSessionState: syncSessionState,
      syncRuntimeState: syncRuntimeState,
      syncLyricState: syncLyricState,
      syncSelectionQueue: syncSelectionQueue,
      updateCurrentPlayIndex: updateCurPlayIndex,
      toggleLike: toggleLikeFromPlayback,
      ensureCurrentTrackArtwork: ensureCurrentTrackArtwork,
      syncCurrentQueueItem: syncCurrentQueueItem,
      runtimeState: () => runtimeState.value,
      lyricState: () => lyricState.value,
      playbackMode: () => playbackMode.value,
      setIsPlaying: setIsPlaying,
      isPlaying: () => isPlaying.value,
      setFullScreenLyricOpen: (value) => isFullScreenLyricOpen.value = value,
    );
    _selectionService.configure(
      repeatMode: () => curRepeatMode.value,
      playbackMode: () => playbackMode.value,
    );
    _selectionSubscription ??= _selectionService.stream.listen(
      syncSelectionState,
    );
    syncSelectionState(_selectionService.state);
  }

  /// 同步播放会话状态。
  void syncSessionState({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
    String? playlistName,
    String? playlistHeader,
    bool? isPlayingLikedSongs,
  }) {
    final previousPlaybackMode = sessionState.value.playbackMode;
    final nextState = sessionState.value.copyWith(
      playbackMode: playbackMode,
      repeatMode: repeatMode,
      playlistName: playlistName,
      playlistHeader: playlistHeader,
      isPlayingLikedSongs: isPlayingLikedSongs,
    );
    sessionState.value = nextState;
    this.playbackMode.value = nextState.playbackMode;
    curRepeatMode.value = nextState.repeatMode;
    if (playbackMode != null && nextState.playbackMode != previousPlaybackMode) {
      _backgroundTasks.run(
        taskName: 'playback.mode.syncQueueService',
        task: () => _queueService.setPlaybackMode(nextState.playbackMode),
      );
    }
  }

  /// 同步播放器运行态。
  void syncRuntimeState({
    List<PlaybackQueueItem>? queue,
    PlaybackQueueItem? currentSong,
    int? currentIndex,
    Duration? currentPosition,
  }) {
    final stopwatch = PlaybackPerformanceLogger.start();
    final nextState = runtimeState.value.copyWith(
      queue: queue,
      currentSong: currentSong,
      currentIndex: currentIndex,
      currentPosition: currentPosition,
    );
    runtimeState.value = nextState;
    confirmedState.value = PlaybackConfirmedState.fromRuntime(
      nextState,
      isPlaying: isPlaying.value,
    );
    if (currentSong != null && !selectionState.value.hasSelection) {
      currentSongState.value = currentSong;
    }
    if (currentPosition != null && currentPositionState.value != currentPosition) {
      currentPositionState.value = currentPosition;
    }
    if (queue != null) {
      syncQueueStateItems(queue);
      syncArtworkPageItems(queue);
    }
    if (currentIndex != null && !selectionState.value.hasSelection && currentQueueIndex.value != currentIndex) {
      currentQueueIndex.value = currentIndex;
    }
    PlaybackPerformanceLogger.elapsed(
      'controller.syncRuntimeState',
      stopwatch,
      details: 'queue=${queue?.length ?? '-'} song=${currentSong?.id ?? '-'} index=${currentIndex ?? '-'} position=${currentPosition != null}',
      warnAfterMs: 4,
    );
  }

  /// 触发 selection 状态同步。
  void syncSelectionQueue(List<PlaybackQueueItem> queue, int selectedIndex) {
    syncSelectionState(_selectionService.state);
  }

  /// 同步 UI selection 状态。
  void syncSelectionState(PlaybackSelectionState nextState) {
    final stopwatch = PlaybackPerformanceLogger.start();
    selectionState.value = nextState;
    displayState.value = PlaybackDisplayState.fromSelection(nextState);
    curOrderMode.value = _queueService.state.orderMode;
    if (nextState.selectedItem.id.isNotEmpty) {
      currentSongState.value = nextState.selectedItem;
    }
    if (nextState.selectedIndex >= 0 && currentQueueIndex.value != nextState.selectedIndex) {
      currentQueueIndex.value = nextState.selectedIndex;
    }
    final queueItemsStopwatch = PlaybackPerformanceLogger.start();
    syncQueueStateItems(nextState.queue);
    PlaybackPerformanceLogger.elapsed(
      'controller.syncSelectionState.queueItems',
      queueItemsStopwatch,
      details: 'queue=${nextState.queue.length}',
      warnAfterMs: 1,
    );
    final artworkItemsStopwatch = PlaybackPerformanceLogger.start();
    syncArtworkPageItems(nextState.queue);
    PlaybackPerformanceLogger.elapsed(
      'controller.syncSelectionState.artworkItems',
      artworkItemsStopwatch,
      details: 'queue=${nextState.queue.length}',
      warnAfterMs: 1,
    );
    scheduleSelectionUiSideEffects(nextState);
    showSelectionSourceError(nextState);
    PlaybackPerformanceLogger.elapsed(
      'controller.syncSelectionState',
      stopwatch,
      details: 'version=${nextState.selectionVersion} id=${nextState.selectedItem.id} index=${nextState.selectedIndex} queue=${nextState.queue.length} source=${nextState.sourceStatus.name}',
      warnAfterMs: 4,
    );
  }

  /// 同步播放状态布尔值。
  void setIsPlaying(bool value) {
    isPlaying.value = value;
    confirmedState.value = PlaybackConfirmedState.fromRuntime(
      runtimeState.value,
      isPlaying: value,
    );
  }

  /// 同步歌词 UI 状态。
  void syncLyricState({
    List<LyricsLineModel>? lines,
    int? currentIndex,
    bool? hasTranslatedLyrics,
  }) {
    final nextState = lyricState.value.copyWith(
      lines: lines,
      currentIndex: currentIndex,
      hasTranslatedLyrics: hasTranslatedLyrics,
    );
    lyricState.value = nextState;
  }

  /// 根据播放器当前歌曲回填当前队列索引。
  Future<void> updateCurPlayIndex({bool currentItemUpdated = true}) async {
    final stopwatch = PlaybackPerformanceLogger.start();
    final currentRuntimeState = runtimeState.value;
    final currentIndex = currentRuntimeState.queue.indexWhere(
      (element) => element.id == currentRuntimeState.currentSong.id,
    );
    syncRuntimeState(currentIndex: currentIndex);
    PlaybackPerformanceLogger.elapsed(
      'controller.updateCurPlayIndex',
      stopwatch,
      details: 'id=${currentRuntimeState.currentSong.id} index=$currentIndex queue=${currentRuntimeState.queue.length} currentItemUpdated=$currentItemUpdated',
      warnAfterMs: 1,
    );
  }

  /// 安排选歌后的展示副作用。
  void scheduleSelectionUiSideEffects(PlaybackSelectionState selection) {
    _selectionUiEffectCoordinator.schedule(
      selection: selection,
      latestSelection: () => selectionState.value,
      syncLyricState: syncLyricState,
      preloadImages: preloadImages,
    );
  }

  /// 展示播放源解析错误。
  void showSelectionSourceError(PlaybackSelectionState selection) {
    final errorMessage = selection.sourceError;
    if (selection.sourceStatus != PlaybackSelectionSourceStatus.error || errorMessage == null || errorMessage.isEmpty) {
      return;
    }
    final toastKey = '${selection.selectionVersion}:${selection.selectedItem.id}:$errorMessage';
    if (_lastSelectionErrorToastKey == toastKey) {
      return;
    }
    _lastSelectionErrorToastKey = toastKey;
    _toastPort.show(errorMessage);
  }

  /// 判断播放队列项是否处于当前用户喜欢状态。
  bool isPlaybackItemLiked(PlaybackQueueItem item) {
    if (item.isLiked) {
      return true;
    }
    final sourceId = MusicResourceId.toNeteaseSourceId(
      item.sourceId.isNotEmpty ? item.sourceId : item.id,
    );
    final numericSongId = int.tryParse(sourceId);
    if (numericSongId == null) {
      return false;
    }
    return _userContentPort.likedSongIds().contains(numericSongId);
  }

  /// 从播放边界切换喜欢状态后同步队列项。
  Future<void> toggleLikeFromPlayback(PlaybackQueueItem item) {
    final itemKey = item.id.isNotEmpty ? item.id : item.sourceId;
    if (itemKey.isEmpty) {
      return Future<void>.value();
    }
    final pending = _likeToggleInFlightByItem[itemKey];
    if (pending != null) {
      return pending;
    }
    late final Future<void> command;
    command = _toggleLikeFromPlayback(item).whenComplete(() {
      if (identical(_likeToggleInFlightByItem[itemKey], command)) {
        _likeToggleInFlightByItem.remove(itemKey);
      }
    });
    _likeToggleInFlightByItem[itemKey] = command;
    return command;
  }

  Future<void> _toggleLikeFromPlayback(PlaybackQueueItem item) async {
    final updatedItem = await _userContentPort.toggleLikeStatus(item);
    if (updatedItem != null) {
      await updatePlaybackQueueItem(updatedItem);
    }
  }
}
