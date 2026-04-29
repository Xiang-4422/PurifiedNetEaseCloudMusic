import 'package:audio_service/audio_service.dart';

/// 维护 audio_service 队列顺序、当前索引和随机播放的原始队列备份。
class AudioServiceQueueSynchronizer {
  final List<MediaItem> _originalSongs = <MediaItem>[];

  /// 当前播放项在 active queue 中的索引。
  int currentIndex = -1;

  /// 随机播放前的原始队列快照。
  List<MediaItem> get originalSongs => List.unmodifiable(_originalSongs);

  /// 替换原始队列快照。
  void replaceOriginalQueue(List<MediaItem> queue) {
    _originalSongs
      ..clear()
      ..addAll(queue);
  }

  /// 构建传给底层播放器的队列，并在随机模式下保持当前歌曲不变。
  List<MediaItem> buildPlayableQueue({
    required List<MediaItem> queue,
    required int index,
    required bool shouldShuffle,
  }) {
    replaceOriginalQueue(queue);
    final queueCopy = <MediaItem>[...queue];
    currentIndex = index;
    if (shouldShuffle && queueCopy.isNotEmpty && index >= 0) {
      final currentSongId = queue[index].id;
      queueCopy.shuffle();
      currentIndex =
          queueCopy.indexWhere((element) => element.id == currentSongId);
    }
    return queueCopy;
  }

  /// 根据随机开关重新排序当前队列。
  List<MediaItem> reorder({
    required List<MediaItem> currentQueue,
    required bool shuffle,
  }) {
    final queueCopy = <MediaItem>[..._originalSongs];
    if (queueCopy.isEmpty) {
      queueCopy.addAll(currentQueue);
    }
    if (shuffle) {
      queueCopy.shuffle();
    }
    if (currentIndex >= 0 && currentIndex < currentQueue.length) {
      final currentSongId = currentQueue[currentIndex].id;
      currentIndex =
          queueCopy.indexWhere((element) => element.id == currentSongId);
    }
    return queueCopy;
  }

  /// 计算下一首索引。
  int nextIndex({
    required int queueLength,
    required bool repeatOne,
  }) {
    if (repeatOne) {
      return currentIndex;
    }
    final next = currentIndex + 1;
    return next == queueLength ? 0 : next;
  }

  /// 计算上一首索引。
  int previousIndex({required int queueLength, required bool repeatOne}) {
    if (repeatOne) {
      return currentIndex;
    }
    final previous = currentIndex - 1;
    return previous < 0 ? queueLength - 1 : previous;
  }

  /// 队列移除项目后同步当前索引。
  void removeAt(int index) {
    if (index < currentIndex) {
      currentIndex--;
    }
  }
}
