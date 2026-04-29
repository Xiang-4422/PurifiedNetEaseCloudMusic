/// 应用内部的播放重复模式。
///
/// 这里不直接使用 `audio_service` 的枚举，避免 domain 被播放适配层类型绑定。
enum PlaybackRepeatMode {
  none,
  one,
  all,
  group,
}
