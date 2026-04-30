/// 触发底层切歌的来源。
///
/// 失败策略会根据触发来源区分“用户主动选择”和“播放链路自动推进”。
enum PlaybackSwitchTrigger {
  /// 用户直接点选队列、封面页或歌曲项。
  userSelect,

  /// 用户点击下一首。
  userNext,

  /// 用户点击上一首。
  userPrevious,

  /// 当前歌曲自然播放完成后推进。
  queueCompletion,

  /// 从恢复快照恢复选择态。
  restore,

  /// FM、心动等播放模式自动推进。
  modeAutoAdvance,
}
