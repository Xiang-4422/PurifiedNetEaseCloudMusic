import 'dart:async';

import 'package:bujuan/domain/entities/track.dart';
import 'package:dio/dio.dart';

/// 下载任务串行队列，集中管理去重、取消 token 和取消标记。
class DownloadTaskQueue {
  static Future<void> _downloadQueue = Future.value();
  static final Map<String, Future<Track?>> _scheduledDownloads = {};
  static final Map<String, Future<Track?>> _scheduledPlaybackCaches = {};
  static final Map<String, CancelToken> _activeCancelTokens = {};
  static final Set<String> _cancelledTrackIds = <String>{};

  /// 指定曲目是否已被取消。
  bool isCancelled(String trackId) => _cancelledTrackIds.contains(trackId);

  /// 清理指定曲目的取消标记。
  void clearCancelled(String trackId) {
    _cancelledTrackIds.remove(trackId);
  }

  /// 标记指定曲目已取消并触发取消 token。
  void markCancelled(String trackId) {
    _cancelledTrackIds.add(trackId);
    _activeCancelTokens[trackId]?.cancel('download_cancelled');
  }

  /// 创建指定曲目的取消 token。
  CancelToken createCancelToken(String trackId) {
    final cancelToken = CancelToken();
    _activeCancelTokens[trackId] = cancelToken;
    return cancelToken;
  }

  /// 结束指定曲目的活跃任务。
  void finishActiveTask(String trackId) {
    _activeCancelTokens.remove(trackId);
  }

  /// 获取已存在的正式下载任务。
  Future<Track?>? existingDownload(String trackId) {
    return _scheduledDownloads[trackId];
  }

  /// 获取已存在的播放缓存任务。
  Future<Track?>? existingPlaybackCache(String trackId) {
    return _scheduledPlaybackCaches[trackId];
  }

  /// 调度正式下载任务。
  Future<Track?> scheduleDownload(
    String trackId,
    Future<Track?> Function() operation,
  ) {
    final taskFuture = _enqueueDownload(operation);
    _scheduledDownloads[trackId] = taskFuture;
    taskFuture.whenComplete(() {
      _scheduledDownloads.remove(trackId);
    });
    return taskFuture;
  }

  /// 调度播放缓存任务。
  Future<Track?> schedulePlaybackCache(
    String trackId,
    Future<Track?> Function() operation,
  ) {
    final taskFuture = operation();
    _scheduledPlaybackCaches[trackId] = taskFuture;
    taskFuture.whenComplete(() {
      _scheduledPlaybackCaches.remove(trackId);
    });
    return taskFuture;
  }

  Future<T> _enqueueDownload<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _downloadQueue = _downloadQueue.catchError((_) {}).then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
