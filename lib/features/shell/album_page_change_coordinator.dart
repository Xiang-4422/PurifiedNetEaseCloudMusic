/// 封面分页切歌的提交协调器。
///
/// PageView 的 `onPageChanged` 会在页面越过阈值时触发，不代表用户手势已经
/// 停止。这里把“记录候选页”和“提交播放”拆开，避免滑动过程中提前切歌。
class AlbumPageChangeCoordinator {
  /// 当前允许提交的页面稳定误差。
  static const double settledPageTolerance = 0.15;

  int? _pendingIndex;

  /// 记录用户滑动产生的候选播放索引。
  void recordPageChange(int index, {required bool isProgrammatic}) {
    if (isProgrammatic) {
      return;
    }
    _pendingIndex = index;
  }

  /// 清理未提交的候选索引。
  void clear() {
    _pendingIndex = null;
  }

  /// 在滑动结束后提交最终播放索引。
  Future<bool> commit({
    required int currentIndex,
    required int queueLength,
    required double? settledPage,
    required Future<void> Function(int index) playIndex,
  }) async {
    final index = _pendingIndex;
    _pendingIndex = null;
    if (index == null || index < 0 || index >= queueLength) {
      return false;
    }
    if (settledPage != null &&
        (settledPage - index).abs() > settledPageTolerance) {
      _pendingIndex = index;
      return false;
    }
    if (currentIndex == index) {
      return false;
    }
    await playIndex(index);
    return true;
  }
}
