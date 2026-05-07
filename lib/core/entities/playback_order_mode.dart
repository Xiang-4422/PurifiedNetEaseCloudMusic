/// 播放队列的出队顺序模式。
enum PlaybackOrderMode {
  /// 按原始队列顺序播放。
  sequential,

  /// 使用随机重排后的 active queue 播放。
  shuffle,
}
