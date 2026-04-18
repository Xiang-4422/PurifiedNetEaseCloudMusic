class PlaybackQueue {
  const PlaybackQueue({
    required this.id,
    required this.trackIds,
    this.currentIndex = 0,
    this.title,
    this.sourcePlaylistId,
  });

  final String id;
  final List<String> trackIds;
  final int currentIndex;
  final String? title;
  final String? sourcePlaylistId;

  PlaybackQueue copyWith({
    String? id,
    List<String>? trackIds,
    int? currentIndex,
    String? title,
    String? sourcePlaylistId,
  }) {
    return PlaybackQueue(
      id: id ?? this.id,
      trackIds: trackIds ?? this.trackIds,
      currentIndex: currentIndex ?? this.currentIndex,
      title: title ?? this.title,
      sourcePlaylistId: sourcePlaylistId ?? this.sourcePlaylistId,
    );
  }
}
