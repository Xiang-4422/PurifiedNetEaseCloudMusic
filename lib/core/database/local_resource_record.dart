class LocalResourceRecord {
  const LocalResourceRecord({
    required this.trackId,
    required this.kind,
    required this.path,
    required this.origin,
    required this.updatedAtMs,
  });

  final String trackId;
  final String kind;
  final String path;
  final String origin;
  final int updatedAtMs;

  Map<String, Object?> toMap() {
    return {
      'trackId': trackId,
      'kind': kind,
      'path': path,
      'origin': origin,
      'updatedAtMs': updatedAtMs,
    };
  }

  factory LocalResourceRecord.fromMap(Map<String, Object?> map) {
    return LocalResourceRecord(
      trackId: map['trackId'] as String? ?? '',
      kind: map['kind'] as String? ?? '',
      path: map['path'] as String? ?? '',
      origin: map['origin'] as String? ?? '',
      updatedAtMs: map['updatedAtMs'] as int? ?? 0,
    );
  }
}
