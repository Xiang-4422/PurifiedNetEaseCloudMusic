class PlaylistTrackRef {
  const PlaylistTrackRef({
    required this.trackId,
    required this.order,
    this.addedAt,
  });

  final String trackId;
  final int order;
  final int? addedAt;
}
