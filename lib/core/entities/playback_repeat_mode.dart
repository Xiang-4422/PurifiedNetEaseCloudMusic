/// 应用内部的播放重复模式。
///
/// 这里不直接使用 `audio_service` 的枚举，避免 domain 被播放适配层类型绑定。
enum PlaybackRepeatMode {
  /// 不重复。
  none,

  /// 单曲循环。
  one,

  /// 列表循环。
  all,

  /// 当前分组循环。
  group,
}
