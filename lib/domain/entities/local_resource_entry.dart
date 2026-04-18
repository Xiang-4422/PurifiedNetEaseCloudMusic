import 'track.dart';

enum LocalResourceKind {
  audio,
  artwork,
  lyrics,
}

class LocalResourceEntry {
  const LocalResourceEntry({
    required this.trackId,
    required this.kind,
    required this.path,
    required this.origin,
    required this.updatedAt,
  });

  final String trackId;
  final LocalResourceKind kind;
  final String path;
  final TrackResourceOrigin origin;
  final DateTime updatedAt;

  LocalResourceEntry copyWith({
    String? trackId,
    LocalResourceKind? kind,
    String? path,
    TrackResourceOrigin? origin,
    DateTime? updatedAt,
  }) {
    return LocalResourceEntry(
      trackId: trackId ?? this.trackId,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      origin: origin ?? this.origin,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
