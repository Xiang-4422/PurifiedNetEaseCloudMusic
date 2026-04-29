import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_cache_codec.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 统一处理播放队列恢复态的编码与持久化。
class PlaybackQueueStore {
  /// 创建播放队列存储。
  PlaybackQueueStore({required PlaybackRepository repository})
      : _repository = repository;

  final PlaybackRepository _repository;

  /// 从恢复快照解码播放队列。
  Future<List<PlaybackQueueItem>> decodeQueue(List<String> queueSnapshot) {
    return decodePlaybackQueueItemCacheList(queueSnapshot);
  }

  /// 保存播放队列快照和队列名称。
  Future<void> saveQueueSnapshot({
    required List<PlaybackQueueItem> originalSongs,
    required String playlistName,
    required String playlistHeader,
  }) async {
    await _repository.updateRestoreState(
      playlistName: playlistName,
      playlistHeader: playlistHeader,
      queue: await encodePlaybackQueueItemCacheList(originalSongs),
    );
  }

  /// 保存当前队列名称和标题前缀。
  Future<void> savePlaylistMeta({
    required String playlistName,
    required String playlistHeader,
  }) {
    return _repository.updateRestoreState(
      playlistName: playlistName,
      playlistHeader: playlistHeader,
    );
  }

  /// 保存重复播放模式。
  Future<void> saveRepeatMode(PlaybackRepeatMode repeatMode) {
    return _repository.updateRestoreState(
      repeatMode: repeatMode,
    );
  }

  /// 保存播放模式。
  Future<void> savePlaybackMode(PlaybackMode playbackMode) {
    return _repository.updateRestoreState(playbackMode: playbackMode);
  }

  /// 保存当前歌曲 id。
  Future<void> saveCurrentSong(String currentSongId) {
    return _repository.updateRestoreState(currentSongId: currentSongId);
  }

  /// 保存当前播放进度。
  Future<void> savePosition(Duration position) {
    return _repository.updateRestoreState(position: position);
  }
}
