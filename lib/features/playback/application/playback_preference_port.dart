/// 播放偏好读取端口。
class PlaybackPreferencePort {
  /// 创建播放偏好端口。
  const PlaybackPreferencePort({
    required this.isHighQualityEnabled,
  });

  /// 当前是否优先使用高音质播放源。
  final bool Function() isHighQualityEnabled;
}
