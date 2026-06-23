/// 播放偏好读取端口。
class PlaybackPreferencePort {
  /// 创建播放偏好端口。
  const PlaybackPreferencePort({
    required this.isHighQualityEnabled,
    required this.toggleHighQuality,
  });

  /// 当前是否优先使用高音质播放源。
  final bool Function() isHighQualityEnabled;

  /// 切换高音质播放源偏好。
  final Future<void> Function() toggleHighQuality;
}
