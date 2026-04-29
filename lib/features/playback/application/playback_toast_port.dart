class PlaybackToastPort {
  const PlaybackToastPort({
    required this.show,
  });

  final void Function(String message) show;
}
