import 'package:audio_service/audio_service.dart';

/// 维护 audio_service 通知栏队列的当前索引。
class AudioServiceQueueSynchronizer {
  /// 当前播放项在 active queue 中的索引。
  int currentIndex = -1;

  /// 队列替换后校正当前索引。
  void replaceQueue(List<MediaItem> queue) {
    if (queue.isEmpty) {
      currentIndex = -1;
      return;
    }
    if (currentIndex >= queue.length) {
      currentIndex = queue.length - 1;
    }
  }

  /// 队列移除项目后同步当前索引。
  void removeAt(int index) {
    if (index < currentIndex) {
      currentIndex--;
    }
  }
}
