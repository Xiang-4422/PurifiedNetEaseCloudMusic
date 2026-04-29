/// 抽屉动画过程中的状态。
///
/// 拖拽过程中状态可能只表示正在打开或关闭；需要稳定终态时使用
/// [DrawerLastAction]。
enum DrawerState {
  /// 抽屉正在打开。
  opening,

  /// 抽屉正在关闭。
  closing,

  /// 抽屉已经完全打开。
  open,

  /// 抽屉已经完全关闭。
  closed,
}
