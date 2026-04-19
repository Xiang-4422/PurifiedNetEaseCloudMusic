import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/database/local_resource_record.dart';
import 'package:bujuan/core/storage/cache_box_storage_adapter.dart';
import 'package:bujuan/core/storage/key_value_storage_adapter.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';

import 'local_resource_index_data_source.dart';
import 'local_resource_record_codec.dart';

class PersistentLocalResourceIndexDataSource
    implements LocalResourceIndexDataSource {
  PersistentLocalResourceIndexDataSource({
    KeyValueStorageAdapter? storageAdapter,
  }) : _storageAdapter = storageAdapter ?? const CacheBoxStorageAdapter();

  final KeyValueStorageAdapter _storageAdapter;

  @override
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  ) async {
    final bucket = _readBucket();
    return _decodeEntry(bucket[_buildKey(trackId, kind)]);
  }

  @override
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    return _readBucket()
        .values
        .map(_decodeEntry)
        .whereType<LocalResourceEntry>()
        .where((entry) => entry.trackId == trackId)
        .toList()
      ..sort((left, right) => left.kind.index.compareTo(right.kind.index));
  }

  @override
  Future<void> saveResource(LocalResourceEntry entry) {
    final bucket = _readBucket();
    bucket[_buildKey(entry.trackId, entry.kind)] =
        LocalResourceRecordCodec.encode(entry).toMap();
    return _storageAdapter.put(localResourceIndexSp, bucket);
  }

  @override
  Future<void> removeResource(String trackId, LocalResourceKind kind) {
    final bucket = _readBucket();
    bucket.remove(_buildKey(trackId, kind));
    return _storageAdapter.put(localResourceIndexSp, bucket);
  }

  @override
  Future<void> removeTrackResources(String trackId) {
    final bucket = _readBucket();
    bucket.removeWhere((key, _) => key.toString().startsWith('$trackId::'));
    return _storageAdapter.put(localResourceIndexSp, bucket);
  }

  String _buildKey(String trackId, LocalResourceKind kind) {
    return '$trackId::${kind.name}';
  }

  Map<String, dynamic> _readBucket() {
    final storedValue = _storageAdapter.get<Object?>(localResourceIndexSp);
    if (storedValue is Map) {
      return storedValue.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
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
