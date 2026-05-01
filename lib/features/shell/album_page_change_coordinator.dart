/// 封面分页切歌的提交协调器。
///
/// PageView 的 `onPageChanged` 会在页面越过 50% 阈值时触发，这个时机比
/// ScrollEnd 更适合提前切歌和触发取色。
class AlbumPageChangeCoordinator {
  /// 当前允许提交的页面稳定误差。
  static const double settledPageTolerance = 0.15;

  /// 在页面跨过 50% 阈值时提交播放索引。
  Future<bool> commitPageChange({
    required int index,
    required bool isProgrammatic,
    required int currentIndex,
    required int queueLength,
    required Future<void> Function(int index) playIndex,
  }) async {
    if (isProgrammatic) {
      return false;
    }
    if (index < 0 || index >= queueLength) {
      return false;
    }
    if (currentIndex == index) {
      return false;
    }
    await playIndex(index);
    return true;
  }
}
