import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

class PlaybackRestoreSnapshot {
  const PlaybackRestoreSnapshot({
    required this.playbackMode,
    required this.repeatMode,
    required this.queue,
    required this.index,
    required this.playlistName,
    required this.playlistHeader,
    required this.position,
  });

  final PlaybackMode playbackMode;
  final PlaybackRepeatMode repeatMode;
  final List<PlaybackQueueItem> queue;
  final int index;
  final String playlistName;
  final String playlistHeader;
  final Duration position;
}

/// 组装上次播放状态，避免 handler 直接读取恢复存储细节。
class PlaybackRestoreCoordinator {
  PlaybackRestoreCoordinator({
    required PlaybackRepository repository,
    required PlaybackQueueStore queueStore,
  })  : _repository = repository,
        _queueStore = queueStore;

  final PlaybackRepository _repository;
  final PlaybackQueueStore _queueStore;

  Future<PlaybackRestoreSnapshot> loadSnapshot() async {
    final restoreState = await _repository.getRestoreState();
    final playlist = restoreState.queue.isEmpty
        ? <PlaybackQueueItem>[]
        : await _queueStore.decodeQueue(restoreState.queue);
    var index = playlist.indexWhere(
      (element) => element.id == restoreState.currentSongId,
    );
    if (index < 0 && playlist.isNotEmpty) {
      index = 0;
    }
    return PlaybackRestoreSnapshot(
      playbackMode: restoreState.playbackMode,
      repeatMode: restoreState.repeatMode,
      queue: playlist,
      index: index,
      playlistName: restoreState.playlistName,
      playlistHeader: restoreState.playlistHeader,
      position: restoreState.position,
    );
  }
}
