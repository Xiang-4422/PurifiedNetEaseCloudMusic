import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 承接播放队列的裁剪、追加和去重规则。
class PlaybackQueueCoordinator {
  /// 创建 PlaybackQueueCoordinator。
  PlaybackQueueCoordinator({required PlaybackService playbackService})
      : _playbackService = playbackService;

  final PlaybackService _playbackService;

  /// appendRoamingSongs。
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

    final existingIds = currentQueue.map((item) => item.id).toSet();
    final filteredSongs =
        incomingSongs.where((item) => !existingIds.contains(item.id)).toList();
    if (filteredSongs.isEmpty) {
      return;
    }

    final combined = [...currentQueue, ...filteredSongs];
    if (combined.length > 200) {
      combined.removeRange(0, combined.length - 150);
    }

    final updatedIndex =
        combined.indexWhere((element) => element.id == currentSongId);
    final nextIndex = updatedIndex != -1 ? updatedIndex : fallbackIndex;

    await _playbackService.changePlayList(
      combined,
      index: nextIndex,
      playListName: '漫游模式',
      playListNameHeader: '漫游',
      playNow: false,
      changePlayerSource: false,
      needStore: false,
    );

    if (shouldAutoPlayNext) {
      final autoPlayIndex = nextIndex + 1;
      if (autoPlayIndex < combined.length) {
        await _playbackService.playIndex(
          audioSourceIndex: autoPlayIndex,
          playNow: true,
        );
      }
    }
  }
}
