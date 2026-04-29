class PlaybackPreferencePort {
  const PlaybackPreferencePort({
    required this.isHighQualityEnabled,
  });

  final bool Function() isHighQualityEnabled;
}
