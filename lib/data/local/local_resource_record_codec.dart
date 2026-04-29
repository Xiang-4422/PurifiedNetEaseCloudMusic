import 'package:bujuan/core/database/local_resource_record.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/track.dart';

/// 本地资源记录 codec，负责领域实体和数据库记录互转。
class LocalResourceRecordCodec {
  /// 禁止实例化本地资源记录 codec。
  const LocalResourceRecordCodec._();

  /// 将本地资源实体编码为数据库记录。
  static LocalResourceRecord encode(LocalResourceEntry entry) {
    return LocalResourceRecord(
      trackId: entry.trackId,
      kind: entry.kind.name,
      path: entry.path,
      origin: entry.origin.name,
      sizeBytes: entry.sizeBytes,
      createdAtMs: entry.createdAt.millisecondsSinceEpoch,
      lastAccessedAtMs: entry.lastAccessedAt.millisecondsSinceEpoch,
    );
  }

  /// 将数据库记录解码为本地资源实体。
  static LocalResourceEntry decode(LocalResourceRecord record) {
    return LocalResourceEntry(
      trackId: record.trackId,
      kind: LocalResourceKind.values.firstWhere(
        (item) => item.name == record.kind,
        orElse: () => LocalResourceKind.audio,
      ),
      path: record.path,
      origin: TrackResourceOrigin.values.firstWhere(
        (item) => item.name == record.origin,
        orElse: () => TrackResourceOrigin.none,
      ),
      sizeBytes: record.sizeBytes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(record.createdAtMs),
      lastAccessedAt: DateTime.fromMillisecondsSinceEpoch(
        record.lastAccessedAtMs,
      ),
    );
  }
}
