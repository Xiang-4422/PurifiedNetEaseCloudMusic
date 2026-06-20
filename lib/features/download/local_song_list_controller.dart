import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:flutter/foundation.dart';

/// 本地歌曲资源列表控制器。
class LocalSongListController {
  /// 创建本地歌曲列表控制器。
  LocalSongListController({
    required MusicDataRepository musicDataRepository,
    required DownloadRepository downloadRepository,
    this.origins,
  })  : _musicDataRepository = musicDataRepository,
        _downloadRepository = downloadRepository;

  final MusicDataRepository _musicDataRepository;
  final DownloadRepository _downloadRepository;

  /// 当前列表展示的本地资源来源过滤条件。
  final Set<TrackResourceOrigin>? origins;

  /// 本地歌曲列表加载状态。
  final ValueNotifier<LoadState<List<LocalSongEntry>>> state = ValueNotifier(const LoadState.loading());
  int _loadGeneration = 0;
  bool _disposed = false;

  /// 首次加载本地歌曲列表。
  Future<void> loadInitial() => refresh();

  /// 刷新本地歌曲列表。
  Future<void> refresh() async {
    if (_disposed) {
      return;
    }
    final generation = ++_loadGeneration;
    final previousEntries = state.value.data;
    _setStateIfCurrent(
      generation,
      previousEntries == null || previousEntries.isEmpty ? const LoadState.loading() : LoadState.loading(data: previousEntries),
    );
    try {
      final entries = await _musicDataRepository.getLocalSongs(origins: origins);
      if (!_isCurrentLoad(generation)) {
        return;
      }
      if (entries.isEmpty) {
        _setStateIfCurrent(generation, const LoadState.empty());
        return;
      }
      _setStateIfCurrent(generation, LoadState.data(entries));
    } catch (error, stackTrace) {
      if (!_isCurrentLoad(generation)) {
        return;
      }
      _setStateIfCurrent(
        generation,
        previousEntries == null || previousEntries.isEmpty
            ? LoadState.error(error, stackTrace: stackTrace)
            : LoadState.error(
                error,
                stackTrace: stackTrace,
                data: previousEntries,
              ),
      );
    }
  }

  /// 删除指定本地曲目的资源。
  Future<void> removeLocalTrack(String trackId) async {
    await _downloadRepository.removeLocalTrack(trackId);
    await refresh();
  }

  /// 清理播放缓存来源的本地歌曲资源。
  Future<void> clearPlaybackCache() async {
    await _downloadRepository.clearPlaybackCache();
    await refresh();
  }

  /// 释放本地歌曲列表状态监听器。
  void dispose() {
    _disposed = true;
    _loadGeneration++;
    state.dispose();
  }

  bool _isCurrentLoad(int generation) {
    return !_disposed && generation == _loadGeneration;
  }

  void _setStateIfCurrent(
    int generation,
    LoadState<List<LocalSongEntry>> nextState,
  ) {
    if (_isCurrentLoad(generation)) {
      state.value = nextState;
    }
  }
}
