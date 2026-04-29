import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_cache_codec.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 统一处理播放队列恢复态的编码与持久化。
class PlaybackQueueStore {
  /// 创建 PlaybackQueueStore。
  PlaybackQueueStore({required PlaybackRepository repository})
      : _repository = repository;

  final PlaybackRepository _repository;

  /// decodeQueue。
  Future<List<PlaybackQueueItem>> decodeQueue(List<String> queueSnapshot) {
    return decodePlaybackQueueItemCacheList(queueSnapshot);
  }

  /// saveQueueSnapshot。
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

  /// savePlaylistMeta。
  Future<void> savePlaylistMeta({
    required String playlistName,
    required String playlistHeader,
  }) {
    return _repository.updateRestoreState(
      playlistName: playlistName,
      playlistHeader: playlistHeader,
    );
  }

  /// saveRepeatMode。
  Future<void> saveRepeatMode(PlaybackRepeatMode repeatMode) {
    return _repository.updateRestoreState(
      repeatMode: repeatMode,
    );
  }

  /// savePlaybackMode。
  Future<void> savePlaybackMode(PlaybackMode playbackMode) {
    return _repository.updateRestoreState(playbackMode: playbackMode);
  }

  /// saveCurrentSong。
  Future<void> saveCurrentSong(String currentSongId) {
    return _repository.updateRestoreState(currentSongId: currentSongId);
  }

  /// savePosition。
  Future<void> savePosition(Duration position) {
    return _repository.updateRestoreState(position: position);
  }
}
