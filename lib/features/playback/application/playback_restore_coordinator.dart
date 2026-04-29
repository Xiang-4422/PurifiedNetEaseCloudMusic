import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 播放恢复快照，包含恢复播放器所需的队列和会话信息。
class PlaybackRestoreSnapshot {
  /// 创建播放恢复快照。
  const PlaybackRestoreSnapshot({
    required this.playbackMode,
    required this.repeatMode,
    required this.queue,
    required this.index,
    required this.playlistName,
    required this.playlistHeader,
    required this.position,
  });

  /// 恢复后的播放模式。
  final PlaybackMode playbackMode;

  /// 恢复后的重复播放模式。
  final PlaybackRepeatMode repeatMode;

  /// 恢复后的播放队列。
  final List<PlaybackQueueItem> queue;

  /// 恢复后的当前队列索引。
  final int index;

  /// 恢复后的队列名称。
  final String playlistName;

  /// 恢复后的队列标题前缀。
  final String playlistHeader;

  /// 恢复后的播放进度。
  final Duration position;
}

/// 组装上次播放状态，避免 handler 直接读取恢复存储细节。
class PlaybackRestoreCoordinator {
  /// 创建播放恢复协调器。
  PlaybackRestoreCoordinator({
    required PlaybackRepository repository,
    required PlaybackQueueStore queueStore,
  })  : _repository = repository,
        _queueStore = queueStore;

  final PlaybackRepository _repository;
  final PlaybackQueueStore _queueStore;

  /// 加载可直接用于恢复播放器的快照。
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
