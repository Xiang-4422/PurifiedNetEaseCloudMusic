/// 本地资源索引记录。
class LocalResourceRecord {
  /// 创建本地资源索引记录。
  const LocalResourceRecord({
    required this.trackId,
    required this.kind,
    required this.path,
    required this.origin,
    required this.sizeBytes,
    required this.createdAtMs,
    required this.lastAccessedAtMs,
  });

  /// 歌曲 id。
  final String trackId;

  /// 资源类型。
  final String kind;

  /// 本地文件路径。
  final String path;

  /// 资源来源。
  final String origin;

  /// 文件大小，单位字节。
  final int sizeBytes;

  /// 创建时间戳，单位毫秒。
  final int createdAtMs;

  /// 最近访问时间戳，单位毫秒。
  final int lastAccessedAtMs;

  /// 转为可持久化的 Map。
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

  /// 从持久化 Map 创建本地资源索引记录。
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
