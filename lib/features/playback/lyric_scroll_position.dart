/// 歌词自动滚动的视觉锚点。
class LyricScrollPosition {
  const LyricScrollPosition._();

  /// 当前歌词行顶部在可视区域中的目标位置。
  static const double activeLineAlignment = 0.45;

  /// 歌词列表第 0 项是顶部占位，真实歌词行从第 1 项开始。
  static const int lyricItemIndexOffset = 1;
}
