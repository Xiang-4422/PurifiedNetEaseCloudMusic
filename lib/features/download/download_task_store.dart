import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/database/download_task_record.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/data/local/download_task_record_codec.dart';
import 'package:bujuan/domain/entities/download_task.dart';

class DownloadTaskStore {
  const DownloadTaskStore();

  Future<DownloadTask?> getTask(String trackId) async {
    final bucket = _readBucket();
    return _decodeTask(bucket[trackId]);
  }

  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) async {
    final tasks = _readBucket()
        .values
        .map(_decodeTask)
        .whereType<DownloadTask>()
        .where(
          (task) => statuses == null || statuses.contains(task.status),
        )
        .toList();
    tasks.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return tasks;
  }

  Future<void> saveTask(DownloadTask task) {
    final bucket = _readBucket();
    bucket[task.trackId] = _encodeTask(task);
    return CacheBox.instance.put(downloadTasksSp, bucket);
  }

  Future<void> removeTask(String trackId) {
    final bucket = _readBucket();
    bucket.remove(trackId);
    return CacheBox.instance.put(downloadTasksSp, bucket);
  }

  Map<String, dynamic> _readBucket() {
    final storedValue = CacheBox.instance.get(downloadTasksSp);
    if (storedValue is Map) {
      return storedValue.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
  }

  Map<String, Object?> _encodeTask(DownloadTask task) {
    return DownloadTaskRecordCodec.encode(task).toMap();
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
