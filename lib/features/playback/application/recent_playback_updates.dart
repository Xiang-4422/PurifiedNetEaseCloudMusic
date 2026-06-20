import 'dart:async';

/// 播放历史更新通知通道。
class RecentPlaybackUpdates {
  /// 创建播放历史更新通知通道。
  RecentPlaybackUpdates();

  final StreamController<void> _updates = StreamController<void>.broadcast();

  /// 历史更新事件流。
  Stream<void> get stream => _updates.stream;

  /// 通知最近播放历史已经写入完成。
  void notify() {
    _updates.add(null);
  }

  /// 关闭通知通道。
  Future<void> close() {
    return _updates.close();
  }
}
