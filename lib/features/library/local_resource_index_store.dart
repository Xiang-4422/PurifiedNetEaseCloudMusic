import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/core/database/local_resource_record.dart';
import 'package:bujuan/data/local/local_resource_record_codec.dart';

class LocalResourceIndexStore {
  const LocalResourceIndexStore();

  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  ) async {
    final bucket = _readBucket();
    return _decodeEntry(bucket[_buildKey(trackId, kind)]);
  }

  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    return _readBucket()
        .values
        .map(_decodeEntry)
        .whereType<LocalResourceEntry>()
        .where((entry) => entry.trackId == trackId)
        .toList()
      ..sort((left, right) => left.kind.index.compareTo(right.kind.index));
  }

  Future<void> saveResource(LocalResourceEntry entry) {
    final bucket = _readBucket();
    bucket[_buildKey(entry.trackId, entry.kind)] = _encodeEntry(entry);
    return CacheBox.instance.put(localResourceIndexSp, bucket);
  }

  Future<void> removeResource(String trackId, LocalResourceKind kind) {
    final bucket = _readBucket();
    bucket.remove(_buildKey(trackId, kind));
    return CacheBox.instance.put(localResourceIndexSp, bucket);
  }

  Future<void> removeTrackResources(String trackId) {
    final bucket = _readBucket();
    bucket.removeWhere(
      (key, _) => key.toString().startsWith('$trackId::'),
    );
    return CacheBox.instance.put(localResourceIndexSp, bucket);
  }

  String _buildKey(String trackId, LocalResourceKind kind) {
    return '$trackId::${kind.name}';
  }

  Map<String, dynamic> _readBucket() {
    final storedValue = CacheBox.instance.get(localResourceIndexSp);
    if (storedValue is Map) {
      return storedValue.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
  }

  Map<String, Object?> _encodeEntry(LocalResourceEntry entry) {
    return LocalResourceRecordCodec.encode(entry).toMap();
  }

  LocalResourceEntry? _decodeEntry(Object? value) {
    if (value is! Map) {
      return null;
    }
    final map = value.map((key, value) => MapEntry('$key', value));
    return LocalResourceRecordCodec.decode(
      LocalResourceRecord.fromMap(Map<String, Object?>.from(map)),
    );
  }
}
