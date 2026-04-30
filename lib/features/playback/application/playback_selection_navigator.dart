import 'package:bujuan/domain/entities/playback_repeat_mode.dart';

/// 只负责根据当前队列和播放模式计算选择索引。
///
/// 这里不触碰播放器和 UI 状态，避免 next/previous 规则散落到 handler、
/// controller 和页面里。
class PlaybackSelectionNavigator {
  /// 创建播放选择导航器。
  const PlaybackSelectionNavigator();

  /// 计算下一首选择索引。
  int? nextIndex({
    required int queueLength,
    required int selectedIndex,
    required PlaybackRepeatMode repeatMode,
    required bool isRoamingMode,
  }) {
    if (queueLength <= 0) {
      return null;
    }
    if (repeatMode == PlaybackRepeatMode.one) {
      return _clampSelectedIndex(selectedIndex, queueLength);
    }
    final next = _clampSelectedIndex(selectedIndex, queueLength) + 1;
    if (next < queueLength) {
      return next;
    }
    if (isRoamingMode) {
      return null;
    }
    return 0;
  }

  /// 计算上一首选择索引。
  int? previousIndex({
    required int queueLength,
    required int selectedIndex,
    required PlaybackRepeatMode repeatMode,
  }) {
    if (queueLength <= 0) {
      return null;
    }
    if (repeatMode == PlaybackRepeatMode.one) {
      return _clampSelectedIndex(selectedIndex, queueLength);
    }
    final previous = _clampSelectedIndex(selectedIndex, queueLength) - 1;
    return previous >= 0 ? previous : queueLength - 1;
  }

  /// 将索引限制在当前队列范围内。
  int clampIndex({
    required int index,
    required int queueLength,
  }) {
    if (queueLength <= 0) {
      return -1;
    }
    return _clampSelectedIndex(index, queueLength);
  }

  /// 根据 id 查找 active queue 中的索引。
  int indexOfItemId({
    required List<String> activeQueueIds,
    required String itemId,
  }) {
    if (itemId.isEmpty) {
      return -1;
    }
    return activeQueueIds.indexOf(itemId);
  }

  int _clampSelectedIndex(int index, int queueLength) {
    if (index < 0) {
      return 0;
    }
    if (index >= queueLength) {
      return queueLength - 1;
    }
    return index;
  }
}
