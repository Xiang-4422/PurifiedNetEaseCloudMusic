/// PlaybackToastPort。
class PlaybackToastPort {
  /// 创建 PlaybackToastPort。
  const PlaybackToastPort({
    required this.show,
  });

  /// Function。
  final void Function(String message) show;
}
