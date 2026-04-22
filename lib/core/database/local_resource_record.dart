class LocalResourceRecord {
  const LocalResourceRecord({
    required this.trackId,
    required this.kind,
    required this.path,
    required this.origin,
    required this.sizeBytes,
    required this.createdAtMs,
    required this.lastAccessedAtMs,
  });

  final String trackId;
  final String kind;
  final String path;
  final String origin;
  final int sizeBytes;
  final int createdAtMs;
  final int lastAccessedAtMs;

  Map<String, Object?> toMap() {
    return {
      'trackId': trackId,
      'kind': kind,
      'path': path,
      'origin': origin,
      'sizeBytes': sizeBytes,
      'createdAtMs': createdAtMs,
      'lastAccessedAtMs': lastAccessedAtMs,
    };
  }

  factory LocalResourceRecord.fromMap(Map<String, Object?> map) {
    return LocalResourceRecord(
      trackId: map['trackId'] as String? ?? '',
      kind: map['kind'] as String? ?? '',
      path: map['path'] as String? ?? '',
      origin: map['origin'] as String? ?? '',
      sizeBytes: map['sizeBytes'] as int? ?? 0,
      createdAtMs: map['createdAtMs'] as int? ?? 0,
      lastAccessedAtMs: map['lastAccessedAtMs'] as int? ?? 0,
    );
  }
}
