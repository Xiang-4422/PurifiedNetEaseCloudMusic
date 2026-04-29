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

  bool isCancelled(String trackId) => _cancelledTrackIds.contains(trackId);

  void clearCancelled(String trackId) {
    _cancelledTrackIds.remove(trackId);
  }

  void markCancelled(String trackId) {
    _cancelledTrackIds.add(trackId);
    _activeCancelTokens[trackId]?.cancel('download_cancelled');
  }

  CancelToken createCancelToken(String trackId) {
    final cancelToken = CancelToken();
    _activeCancelTokens[trackId] = cancelToken;
    return cancelToken;
  }

  void finishActiveTask(String trackId) {
    _activeCancelTokens.remove(trackId);
  }

  Future<Track?>? existingDownload(String trackId) {
    return _scheduledDownloads[trackId];
  }

  Future<Track?>? existingPlaybackCache(String trackId) {
    return _scheduledPlaybackCaches[trackId];
  }

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
