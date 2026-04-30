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

  /// 队列移除项目后同步当前索引。
  void removeAt(int index) {
    if (index < currentIndex) {
      currentIndex--;
    }
  }
}
