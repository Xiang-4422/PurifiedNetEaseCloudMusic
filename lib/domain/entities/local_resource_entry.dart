import 'track.dart';

/// 本地资源类型。
enum LocalResourceKind {
  /// 音频资源。
  audio,

  /// 封面资源。
  artwork,

  /// 歌词资源。
  lyrics,
}

/// 本地资源索引实体。
class LocalResourceEntry {
  /// 创建本地资源索引实体。
  const LocalResourceEntry({
    required this.trackId,
    required this.kind,
    required this.path,
    required this.origin,
    required this.sizeBytes,
    required this.createdAt,
    required this.lastAccessedAt,
  });

  /// 歌曲 id。
  final String trackId;

  /// 资源类型。
  final LocalResourceKind kind;

  /// 本地文件路径。
  final String path;

  /// 资源来源。
  final TrackResourceOrigin origin;

  /// 文件大小，单位字节。
  final int sizeBytes;

  /// 创建时间。
  final DateTime createdAt;

  /// 最近访问时间。
  final DateTime lastAccessedAt;

  /// 复制本地资源索引并替换指定字段。
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
