import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 播放恢复数据，包含恢复播放器所需的队列和会话信息。
class PlaybackRestoreData {
  /// 创建播放恢复数据。
  const PlaybackRestoreData({
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

  /// 加载可直接用于恢复播放器的数据。
  Future<PlaybackRestoreData> loadRestoreData() async {
    final restoreState = await _repository.getRestoreState();
    final playlist = await _decodeQueueSafely(restoreState.queue);
    var index = playlist.indexWhere(
      (element) => element.id == restoreState.currentSongId,
    );
    if (index < 0 && playlist.isNotEmpty) {
      index = 0;
    }
    return PlaybackRestoreData(
      playbackMode: restoreState.playbackMode,
      repeatMode: restoreState.repeatMode,
      queue: playlist,
      index: index,
      playlistName: playlist.isEmpty ? '' : restoreState.playlistName,
      playlistHeader: playlist.isEmpty ? '' : restoreState.playlistHeader,
      position: playlist.isEmpty ? Duration.zero : restoreState.position,
    );
  }

  Future<List<PlaybackQueueItem>> _decodeQueueSafely(List<String> queueState) async {
    if (queueState.isEmpty) {
      return const <PlaybackQueueItem>[];
    }
    try {
      return (await _queueStore.decodeQueue(queueState)).where((item) => item.id.isNotEmpty).toList(growable: false);
    } catch (_) {
      return const <PlaybackQueueItem>[];
    }
  }
}
