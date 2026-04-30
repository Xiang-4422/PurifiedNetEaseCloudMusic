import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';

/// 承接播放队列的裁剪、追加和去重规则。
class PlaybackQueueCoordinator {
  /// 创建播放队列协调器。
  PlaybackQueueCoordinator({
    required PlaybackQueueService queueService,
    required PlaybackSelectionService selectionService,
  })  : _queueService = queueService,
        _selectionService = selectionService;

  final PlaybackQueueService _queueService;
  final PlaybackSelectionService _selectionService;

  /// 追加漫游歌曲并按需自动播放下一首。
  Future<void> appendRoamingSongs({
    required List<PlaybackQueueItem> currentQueue,
    required List<PlaybackQueueItem> incomingSongs,
    required String currentSongId,
    required bool shouldAutoPlayNext,
    required int fallbackIndex,
  }) async {
    if (incomingSongs.isEmpty) {
      return;
    }

    final queueState = await _queueService.appendQueueItems(
      incomingSongs,
      currentSongId: currentSongId,
    );
    final updatedIndex = queueState.activeQueue.indexWhere(
      (element) => element.id == currentSongId,
    );
    final nextIndex = updatedIndex != -1 ? updatedIndex : fallbackIndex;

    if (shouldAutoPlayNext) {
      final autoPlayIndex = nextIndex + 1;
      if (autoPlayIndex < queueState.activeQueue.length) {
        await _selectionService.selectIndex(
          autoPlayIndex,
          trigger: PlaybackSwitchTrigger.modeAutoAdvance,
        );
      }
    }
  }
}
