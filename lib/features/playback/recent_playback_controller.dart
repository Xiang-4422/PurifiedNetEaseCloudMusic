import 'dart:async';

import 'package:bujuan/core/entities/liked_song_ids.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/track_playback_queue_builder.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:get/get.dart';

/// 管理首页最近播放的本地优先展示状态。
class RecentPlaybackController extends GetxController {
  /// 创建最近播放控制器。
  RecentPlaybackController({
    required PlaybackRepository repository,
    required List<int> Function() likedSongIds,
  })  : _repository = repository,
        _likedSongIds = likedSongIds;

  static const int _defaultLimit = 8;

  final PlaybackRepository _repository;
  final List<int> Function() _likedSongIds;

  /// 最近确认播放过的曲目。
  final RxList<PlaybackQueueItem> recentTracks = <PlaybackQueueItem>[].obs;

  /// 最近播放是否正在刷新。
  final RxBool isLoading = false.obs;

  /// 最近播放加载错误；为空时表示无错误。
  final RxString errorMessage = ''.obs;

  StreamSubscription<void>? _recentPlaybackUpdates;
  int _requestGeneration = 0;
  int _lastLimit = _defaultLimit;
  bool _pendingHistoryRefresh = false;
  bool _disposed = false;

  @override
  void onInit() {
    super.onInit();
    _recentPlaybackUpdates = _repository.recentPlaybackUpdates.listen((_) {
      _reloadAfterHistoryUpdate();
    });
    unawaited(loadRecent());
  }

  void _reloadAfterHistoryUpdate() {
    if (_disposed) {
      return;
    }
    if (isLoading.value) {
      _pendingHistoryRefresh = true;
      return;
    }
    unawaited(loadRecent(limit: _lastLimit));
  }

  /// 从本地播放历史读取最近播放曲目。
  Future<void> loadRecent({int limit = _defaultLimit}) async {
    if (_disposed) {
      return;
    }
    _lastLimit = limit;
    final generation = ++_requestGeneration;
    isLoading.value = true;
    try {
      final tracks = await _repository.loadRecentPlayedTracks(limit: limit);
      final items = TrackPlaybackQueueBuilder.fromTrackResources(
        tracks,
        likedSongIds: normalizeLikedSongIds(_likedSongIds()),
      );
      if (_disposed || generation != _requestGeneration) {
        return;
      }
      recentTracks.assignAll(items);
      errorMessage.value = '';
    } catch (error) {
      if (_disposed || generation != _requestGeneration) {
        return;
      }
      errorMessage.value = error.toString();
    } finally {
      if (!_disposed && generation == _requestGeneration) {
        final shouldReload = _pendingHistoryRefresh;
        _pendingHistoryRefresh = false;
        isLoading.value = false;
        if (shouldReload) {
          unawaited(loadRecent(limit: _lastLimit));
        }
      }
    }
  }

  @override
  void onClose() {
    _disposed = true;
    _requestGeneration++;
    _pendingHistoryRefresh = false;
    unawaited(_recentPlaybackUpdates?.cancel());
    super.onClose();
  }
}
