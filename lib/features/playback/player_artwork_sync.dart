part of 'player_controller.dart';

/// 播放控制器的队列展示项和封面预加载同步逻辑。
extension PlayerArtworkSync on PlayerController {
  /// 确保当前歌曲具备可展示封面。
  Future<void> ensureCurrentTrackArtwork(PlaybackQueueItem item) async {
    final itemId = _normalizedQueueItemId(item.id);
    if (itemId.isEmpty) {
      return;
    }
    final normalizedItem = _normalizedQueueItem(item);
    final updatedItem = await _artworkPresenter.resolveMissingArtwork(normalizedItem);
    if (updatedItem == null || _normalizedQueueItemId(runtimeState.value.currentSong.id) != itemId) {
      return;
    }
    await syncCurrentQueueItem(_normalizedQueueItem(updatedItem));
  }

  /// 同步当前队列项到 UI 队列和播放服务。
  Future<void> syncCurrentQueueItem(PlaybackQueueItem updatedItem) async {
    final normalizedItem = _normalizedQueueItem(updatedItem);
    final itemId = normalizedItem.id;
    if (itemId.isEmpty) {
      return;
    }
    final queue = runtimeState.value.queue.map((item) => _normalizedQueueItemId(item.id) == itemId ? normalizedItem : item).toList(growable: false);
    await _queueService.updateQueueItem(normalizedItem);
    syncRuntimeState(
      queue: queue,
      currentSong: normalizedItem,
    );
    await _playbackService.updateQueueItem(normalizedItem);
  }

  /// 同步底部封面分页使用的轻量展示队列。
  void syncArtworkPageItems(List<PlaybackQueueItem> queue) {
    final stopwatch = PlaybackPerformanceLogger.start();
    final nextItems = queue.map(PlaybackArtworkPageItem.fromQueueItem).toList(growable: false);
    if (artworkPageItems.length != nextItems.length) {
      artworkPageItems.assignAll(nextItems);
      PlaybackPerformanceLogger.elapsed(
        'controller.syncArtworkPageItems.assignAll',
        stopwatch,
        details: 'count=${nextItems.length}',
        warnAfterMs: 2,
      );
      return;
    }
    var changedCount = 0;
    for (var index = 0; index < nextItems.length; index++) {
      if (!artworkPageItems[index].hasSameArtwork(nextItems[index])) {
        artworkPageItems[index] = nextItems[index];
        changedCount++;
      }
    }
    PlaybackPerformanceLogger.elapsed(
      'controller.syncArtworkPageItems.incremental',
      stopwatch,
      details: 'count=${nextItems.length} changed=$changedCount',
      warnAfterMs: 2,
    );
  }

  /// 同步播放队列展示项。
  void syncQueueStateItems(List<PlaybackQueueItem> queue) {
    final stopwatch = PlaybackPerformanceLogger.start();
    if (queueState.length != queue.length) {
      queueState.assignAll(queue);
      PlaybackPerformanceLogger.elapsed(
        'controller.syncQueueStateItems.assignAll',
        stopwatch,
        details: 'count=${queue.length}',
        warnAfterMs: 2,
      );
      return;
    }
    var changedCount = 0;
    for (var index = 0; index < queue.length; index++) {
      if (!hasSameQueueItem(queueState[index], queue[index])) {
        queueState[index] = queue[index];
        changedCount++;
      }
    }
    PlaybackPerformanceLogger.elapsed(
      'controller.syncQueueStateItems.incremental',
      stopwatch,
      details: 'count=${queue.length} changed=$changedCount',
      warnAfterMs: 2,
    );
  }

  /// 判断两个队列项的展示字段是否一致。
  bool hasSameQueueItem(
    PlaybackQueueItem current,
    PlaybackQueueItem next,
  ) {
    return current.id == next.id &&
        current.title == next.title &&
        current.artist == next.artist &&
        current.artworkUrl == next.artworkUrl &&
        current.localArtworkPath == next.localArtworkPath &&
        current.isLiked == next.isLiked &&
        current.isCached == next.isCached;
  }

  PlaybackQueueItem _normalizedQueueItem(PlaybackQueueItem item) {
    final normalizedItemId = _normalizedQueueItemId(item.id);
    if (normalizedItemId == item.id) {
      return item;
    }
    return item.copyWith(id: normalizedItemId);
  }

  String _normalizedQueueItemId(String id) {
    return id.trim();
  }

  /// 预加载当前 selection 附近的封面图片。
  void preloadImages() {
    if (isPlaying.isFalse) {
      return;
    }
    final stopwatch = PlaybackPerformanceLogger.start();
    _artworkPresenter.preloadQueueArtwork(
      queue: selectionState.value.queue,
      currentIndex: selectionState.value.selectedIndex,
      context: Get.context,
    );
    PlaybackPerformanceLogger.elapsed(
      'controller.preloadArtwork',
      stopwatch,
      details: 'index=${selectionState.value.selectedIndex} queue=${selectionState.value.queue.length}',
      warnAfterMs: 2,
    );
  }
}
