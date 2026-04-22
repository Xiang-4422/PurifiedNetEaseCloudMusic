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
    required this.sizeBytes,
    required this.createdAt,
    required this.lastAccessedAt,
  });

  final String trackId;
  final LocalResourceKind kind;
  final String path;
  final TrackResourceOrigin origin;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime lastAccessedAt;

  LocalResourceEntry copyWith({
    String? trackId,
    LocalResourceKind? kind,
    String? path,
    TrackResourceOrigin? origin,
    int? sizeBytes,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  }) {
    return LocalResourceEntry(
      trackId: trackId ?? this.trackId,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      origin: origin ?? this.origin,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}
