import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/domain/entities/download_task.dart';

class DownloadTaskStore {
  const DownloadTaskStore();

  Future<DownloadTask?> getTask(String trackId) async {
    final bucket = _readBucket();
    return _decodeTask(bucket[trackId]);
  }

  Future<List<DownloadTask>> getTasks() async {
    return _readBucket()
        .values
        .map(_decodeTask)
        .whereType<DownloadTask>()
        .toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
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
    return {
      'trackId': task.trackId,
      'status': task.status.name,
      'updatedAt': task.updatedAt.millisecondsSinceEpoch,
      'progress': task.progress,
      'localPath': task.localPath,
      'artworkPath': task.artworkPath,
      'lyricsPath': task.lyricsPath,
      'failureReason': task.failureReason,
    };
  }

  DownloadTask? _decodeTask(Object? value) {
    if (value is! Map) {
      return null;
    }
    final map = value.map((key, value) => MapEntry('$key', value));
    final statusName = map['status'] as String?;
    return DownloadTask(
      trackId: map['trackId'] as String? ?? '',
      status: DownloadTaskStatus.values.firstWhere(
        (item) => item.name == statusName,
        orElse: () => DownloadTaskStatus.queued,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as num?)?.toInt() ?? 0,
      ),
      progress: (map['progress'] as num?)?.toDouble(),
      localPath: map['localPath'] as String?,
      artworkPath: map['artworkPath'] as String?,
      lyricsPath: map['lyricsPath'] as String?,
      failureReason: map['failureReason'] as String?,
    );
  }
}
