import 'package:bujuan/core/database/local_resource_record.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/track.dart';

class LocalResourceRecordCodec {
  const LocalResourceRecordCodec._();

  static LocalResourceRecord encode(LocalResourceEntry entry) {
    return LocalResourceRecord(
      trackId: entry.trackId,
      kind: entry.kind.name,
      path: entry.path,
      origin: entry.origin.name,
      updatedAtMs: entry.updatedAt.millisecondsSinceEpoch,
    );
  }

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
      updatedAt: DateTime.fromMillisecondsSinceEpoch(record.updatedAtMs),
    );
  }

}
