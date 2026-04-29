/// PlaybackPreferencePort。
class PlaybackPreferencePort {
  /// 创建 PlaybackPreferencePort。
  const PlaybackPreferencePort({
    required this.isHighQualityEnabled,
  });

  /// Function。
  final bool Function() isHighQualityEnabled;
}
