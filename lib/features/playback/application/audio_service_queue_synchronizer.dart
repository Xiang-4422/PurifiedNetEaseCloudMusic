import 'package:audio_service/audio_service.dart';

/// 维护 audio_service 队列顺序、当前索引和随机播放的原始队列备份。
class AudioServiceQueueSynchronizer {
  final List<MediaItem> _originalSongs = <MediaItem>[];

  /// currentIndex。
  int currentIndex = -1;

  /// originalSongs。
  List<MediaItem> get originalSongs => List.unmodifiable(_originalSongs);

  /// replaceOriginalQueue。
  void replaceOriginalQueue(List<MediaItem> queue) {
    _originalSongs
      ..clear()
      ..addAll(queue);
  }

  /// buildPlayableQueue。
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

  /// reorder。
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

  /// nextIndex。
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

  /// previousIndex。
  int previousIndex({required int queueLength, required bool repeatOne}) {
    if (repeatOne) {
      return currentIndex;
    }
    final previous = currentIndex - 1;
    return previous < 0 ? queueLength - 1 : previous;
  }

  /// removeAt。
  void removeAt(int index) {
    if (index < currentIndex) {
      currentIndex--;
    }
  }
}
