import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/database/download_task_record.dart';
import 'package:bujuan/core/storage/cache_box_storage_adapter.dart';
import 'package:bujuan/core/storage/key_value_storage_adapter.dart';
import 'package:bujuan/domain/entities/download_task.dart';

import 'download_task_data_source.dart';
import 'download_task_record_codec.dart';

class PersistentDownloadTaskDataSource implements DownloadTaskDataSource {
  PersistentDownloadTaskDataSource({
    KeyValueStorageAdapter? storageAdapter,
  }) : _storageAdapter = storageAdapter ?? const CacheBoxStorageAdapter();

  final KeyValueStorageAdapter _storageAdapter;

  @override
  Future<DownloadTask?> getTask(String trackId) async {
    final bucket = _readBucket();
    return _decodeTask(bucket[trackId]);
  }

  @override
  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    final tasks = _readBucket()
        .values
        .map(_decodeTask)
        .whereType<DownloadTask>()
        .where((task) => statuses == null || statuses.contains(task.status))
        .toList();
    tasks.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return tasks;
  }

  @override
  Future<void> saveTask(DownloadTask task) {
    final bucket = _readBucket();
    bucket[task.trackId] = DownloadTaskRecordCodec.encode(task).toMap();
    return _storageAdapter.put(downloadTasksSp, bucket);
  }

  @override
  Future<void> removeTask(String trackId) {
    final bucket = _readBucket();
    bucket.remove(trackId);
    return _storageAdapter.put(downloadTasksSp, bucket);
  }

  Map<String, dynamic> _readBucket() {
    final storedValue = _storageAdapter.get<Object?>(downloadTasksSp);
    if (storedValue is Map) {
      return storedValue.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
  }

  DownloadTask? _decodeTask(Object? value) {
    if (value is! Map) {
      return null;
    }
    final map = value.map((key, value) => MapEntry('$key', value));
    return DownloadTaskRecordCodec.decode(
      DownloadTaskRecord.fromMap(Map<String, Object?>.from(map)),
    );
  }
}
