import 'dart:async';

import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/playback_queue_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 播放队列事实源。
///
/// 这里集中维护 original queue、active queue、selection index 和 confirmed index。
/// `AudioServiceHandler` 只消费 active queue 做通知栏展示，不再反向决定业务队列顺序。
class PlaybackQueueService {
  /// 创建播放队列服务。
  PlaybackQueueService({
    required PlaybackQueueStore queueStore,
    required PlaybackService playbackService,
  })  : _queueStore = queueStore,
        _playbackService = playbackService;

  final PlaybackQueueStore _queueStore;
  final PlaybackService _playbackService;
  final StreamController<PlaybackQueueState> _stateController =
      StreamController<PlaybackQueueState>.broadcast(sync: true);

  PlaybackQueueState _state = const PlaybackQueueState();

  /// 当前队列事实快照。
  PlaybackQueueState get state => _state;

  /// 队列事实变化流。
  Stream<PlaybackQueueState> get stream => _stateController.stream;

  /// 替换当前播放队列。
  Future<PlaybackQueueState> replaceQueue(
    List<PlaybackQueueItem> queue,
    int index, {
    required String playlistName,
    String playlistHeader = '',
    bool needStore = true,
  }) async {
    final selectedOriginalIndex = _clampIndex(index, queue.length);
    final selectedItem = selectedOriginalIndex >= 0
        ? queue[selectedOriginalIndex]
        : const PlaybackQueueItem.empty();
    final activeQueue = _buildActiveQueue(
      originalQueue: queue,
      repeatMode: _state.repeatMode,
      playbackMode: _state.playbackMode,
    );
    final selectedIndex = _indexOfItem(activeQueue, selectedItem.id);
    final nextState = _state.copyWith(
      originalQueue: List<PlaybackQueueItem>.unmodifiable(queue),
      activeQueue: List<PlaybackQueueItem>.unmodifiable(activeQueue),
      selectedIndex: selectedIndex,
      confirmedIndex: _confirmedIndexAfterQueueChange(
        activeQueue,
        _state.confirmedItem.id,
      ),
      playlistName: playlistName,
      playlistHeader: playlistHeader,
      selectionVersion: _state.selectionVersion + 1,
      queueVersion: _state.queueVersion + 1,
    );
    _emit(nextState);
    await _syncNotificationQueue();
    if (needStore) {
      await _queueStore.saveQueueSnapshot(
        originalSongs: _state.originalQueue,
        playlistName: playlistName,
        playlistHeader: playlistHeader,
      );
    } else {
      await _queueStore.savePlaylistMeta(
        playlistName: playlistName,
        playlistHeader: playlistHeader,
      );
    }
    return _state;
  }

  /// 选择 active queue 中的指定索引。
  Future<PlaybackQueueState> selectIndex(int index) async {
    final selectedIndex = _clampIndex(index, _state.activeQueue.length);
    if (selectedIndex < 0) {
      return _state;
    }
    _emit(_state.copyWith(
      selectedIndex: selectedIndex,
      selectionVersion: _state.selectionVersion + 1,
    ));
    await _syncNotificationQueue();
    return _state;
  }

  /// 按当前 repeat/playback mode 选择下一首。
  Future<PlaybackQueueState?> selectNext() async {
    final resolvedIndex = nextIndex();
    if (resolvedIndex == null) {
      return null;
    }
    return selectIndex(resolvedIndex);
  }

  /// 按当前 repeat mode 选择上一首。
  Future<PlaybackQueueState?> selectPrevious() async {
    final resolvedIndex = previousIndex();
    if (resolvedIndex == null) {
      return null;
    }
    return selectIndex(resolvedIndex);
  }

  /// 计算下一首索引。
  int? nextIndex() {
    final queueLength = _state.activeQueue.length;
    if (queueLength <= 0) {
      return null;
    }
    if (_state.repeatMode == PlaybackRepeatMode.one) {
      return _clampIndex(_state.selectedIndex, queueLength);
    }
    final next = _clampIndex(_state.selectedIndex, queueLength) + 1;
    if (next < queueLength) {
      return next;
    }
    if (_state.playbackMode == PlaybackMode.roaming) {
      return null;
    }
    return 0;
  }

  /// 计算上一首索引。
  int? previousIndex() {
    final queueLength = _state.activeQueue.length;
    if (queueLength <= 0) {
      return null;
    }
    if (_state.repeatMode == PlaybackRepeatMode.one) {
      return _clampIndex(_state.selectedIndex, queueLength);
    }
    final previous = _clampIndex(_state.selectedIndex, queueLength) - 1;
    return previous >= 0 ? previous : queueLength - 1;
  }

  /// 更新重复播放模式，并按需重建 active queue。
  Future<PlaybackQueueState> setRepeatMode(
      PlaybackRepeatMode repeatMode) async {
    final selectedId = _state.selectedItem.id;
    final activeQueue = _buildActiveQueue(
      originalQueue: _state.originalQueue,
      repeatMode: repeatMode,
      playbackMode: _state.playbackMode,
    );
    _emit(_state.copyWith(
      activeQueue: List<PlaybackQueueItem>.unmodifiable(activeQueue),
      selectedIndex: _indexOfItem(activeQueue, selectedId),
      confirmedIndex: _confirmedIndexAfterQueueChange(
        activeQueue,
        _state.confirmedItem.id,
      ),
      repeatMode: repeatMode,
      queueVersion: _state.queueVersion + 1,
    ));
    await _queueStore.saveRepeatMode(repeatMode);
    await _syncNotificationQueue();
    return _state;
  }

  /// 循环到下一种重复播放模式。
  Future<PlaybackQueueState> cycleRepeatMode() {
    return setRepeatMode(nextRepeatMode(_state.repeatMode));
  }

  /// 计算下一种重复播放模式。
  PlaybackRepeatMode nextRepeatMode(PlaybackRepeatMode currentMode) {
    switch (currentMode) {
      case PlaybackRepeatMode.one:
        return PlaybackRepeatMode.none;
      case PlaybackRepeatMode.none:
        return PlaybackRepeatMode.all;
      case PlaybackRepeatMode.all:
      case PlaybackRepeatMode.group:
        return PlaybackRepeatMode.one;
    }
  }

  /// 更新播放模式。
  Future<PlaybackQueueState> setPlaybackMode(PlaybackMode playbackMode) async {
    _emit(_state.copyWith(playbackMode: playbackMode));
    await _queueStore.savePlaybackMode(playbackMode);
    return _state;
  }

  /// 追加漫游歌曲。
  Future<PlaybackQueueState> appendQueueItems(
    List<PlaybackQueueItem> incomingSongs, {
    required String currentSongId,
    int maxQueueLength = 200,
    int retainQueueLength = 150,
  }) async {
    if (incomingSongs.isEmpty) {
      return _state;
    }
    final existingIds = _state.originalQueue.map((item) => item.id).toSet();
    final filteredSongs = incomingSongs
        .where((item) => !existingIds.contains(item.id))
        .toList(growable: false);
    if (filteredSongs.isEmpty) {
      return _state;
    }

    final combined = [..._state.originalQueue, ...filteredSongs];
    if (combined.length > maxQueueLength) {
      combined.removeRange(0, combined.length - retainQueueLength);
    }
    final selectedId = _state.selectedItem.id.isNotEmpty
        ? _state.selectedItem.id
        : currentSongId;
    final activeQueue = _buildActiveQueue(
      originalQueue: combined,
      repeatMode: _state.repeatMode,
      playbackMode: _state.playbackMode,
    );
    _emit(_state.copyWith(
      originalQueue: List<PlaybackQueueItem>.unmodifiable(combined),
      activeQueue: List<PlaybackQueueItem>.unmodifiable(activeQueue),
      selectedIndex: _indexOfItem(activeQueue, selectedId),
      confirmedIndex: _confirmedIndexAfterQueueChange(
        activeQueue,
        _state.confirmedItem.id,
      ),
      queueVersion: _state.queueVersion + 1,
    ));
    await _syncNotificationQueue();
    return _state;
  }

  /// 更新队列中的歌曲展示信息。
  Future<PlaybackQueueState> updateQueueItem(PlaybackQueueItem item) async {
    final originalQueue = _replaceQueueItem(_state.originalQueue, item);
    final activeQueue = _replaceQueueItem(_state.activeQueue, item);
    _emit(_state.copyWith(
      originalQueue: List<PlaybackQueueItem>.unmodifiable(originalQueue),
      activeQueue: List<PlaybackQueueItem>.unmodifiable(activeQueue),
      queueVersion: _state.queueVersion + 1,
    ));
    await _syncNotificationQueue();
    return _state;
  }

  /// 标记底层已经确认的歌曲。
  Future<PlaybackQueueState> markConfirmed({
    required PlaybackQueueItem item,
    int? index,
  }) async {
    final confirmedIndex = index ?? _indexOfItem(_state.activeQueue, item.id);
    if (confirmedIndex < 0) {
      return _state;
    }
    _emit(_state.copyWith(confirmedIndex: confirmedIndex));
    await _syncNotificationQueue();
    return _state;
  }

  /// 从恢复快照重建队列事实。
  Future<PlaybackQueueState> restoreSnapshot(
    PlaybackRestoreSnapshot snapshot,
  ) async {
    _emit(_state.copyWith(
      repeatMode: snapshot.repeatMode,
      playbackMode: snapshot.playbackMode,
      pendingRestorePosition: snapshot.position,
    ));
    if (snapshot.queue.isEmpty) {
      return _state;
    }
    final selectedIndex = _clampIndex(snapshot.index, snapshot.queue.length);
    final selectedItem = snapshot.queue[selectedIndex];
    final activeQueue = _buildActiveQueue(
      originalQueue: snapshot.queue,
      repeatMode: snapshot.repeatMode,
      playbackMode: snapshot.playbackMode,
    );
    _emit(_state.copyWith(
      originalQueue: List<PlaybackQueueItem>.unmodifiable(snapshot.queue),
      activeQueue: List<PlaybackQueueItem>.unmodifiable(activeQueue),
      selectedIndex: _indexOfItem(activeQueue, selectedItem.id),
      confirmedIndex: -1,
      playlistName: snapshot.playlistName,
      playlistHeader: snapshot.playlistHeader,
      selectionVersion: _state.selectionVersion + 1,
      queueVersion: _state.queueVersion + 1,
    ));
    await _playbackService.setPendingRestorePosition(snapshot.position);
    await _syncNotificationQueue();
    return _state;
  }

  /// 清理已经消费的恢复进度。
  void clearPendingRestorePosition() {
    if (_state.pendingRestorePosition == Duration.zero) {
      return;
    }
    _emit(_state.copyWith(pendingRestorePosition: Duration.zero));
  }

  Future<void> _syncNotificationQueue() {
    final notificationIndex = _state.confirmedIndex >= 0
        ? _state.confirmedIndex
        : _state.selectedIndex;
    return _playbackService.setNotificationQueue(
      _state.activeQueue,
      currentIndex: notificationIndex,
      playlistName: _state.playlistName,
      playlistHeader: _state.playlistHeader,
    );
  }

  List<PlaybackQueueItem> _buildActiveQueue({
    required List<PlaybackQueueItem> originalQueue,
    required PlaybackRepeatMode repeatMode,
    required PlaybackMode playbackMode,
  }) {
    final queue = <PlaybackQueueItem>[...originalQueue];
    if (queue.isEmpty) {
      return queue;
    }
    if (repeatMode == PlaybackRepeatMode.none &&
        playbackMode == PlaybackMode.playlist) {
      queue.shuffle();
    }
    return queue;
  }

  int _confirmedIndexAfterQueueChange(
    List<PlaybackQueueItem> activeQueue,
    String confirmedItemId,
  ) {
    if (confirmedItemId.isEmpty) {
      return -1;
    }
    return _indexOfItem(activeQueue, confirmedItemId);
  }

  List<PlaybackQueueItem> _replaceQueueItem(
    List<PlaybackQueueItem> queue,
    PlaybackQueueItem item,
  ) {
    return queue
        .map((queueItem) => queueItem.id == item.id ? item : queueItem)
        .toList(growable: false);
  }

  int _indexOfItem(List<PlaybackQueueItem> queue, String itemId) {
    if (itemId.isEmpty) {
      return -1;
    }
    return queue.indexWhere((item) => item.id == itemId);
  }

  int _clampIndex(int index, int queueLength) {
    if (queueLength <= 0) {
      return -1;
    }
    if (index < 0) {
      return 0;
    }
    if (index >= queueLength) {
      return queueLength - 1;
    }
    return index;
  }

  void _emit(PlaybackQueueState state) {
    _state = state;
    _stateController.add(state);
  }

  /// 释放队列事实流。
  Future<void> dispose() async {
    await _stateController.close();
  }
}
