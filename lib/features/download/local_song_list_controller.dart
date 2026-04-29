import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/local_song_entry.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:flutter/foundation.dart';

/// 本地歌曲资源列表控制器。
class LocalSongListController {
  /// 创建本地歌曲列表控制器。
  LocalSongListController({
    required LibraryRepository libraryRepository,
    required DownloadRepository downloadRepository,
    this.origins,
  })  : _libraryRepository = libraryRepository,
        _downloadRepository = downloadRepository;

  final LibraryRepository _libraryRepository;
  final DownloadRepository _downloadRepository;

  /// 当前列表展示的本地资源来源过滤条件。
  final Set<TrackResourceOrigin>? origins;

  /// 本地歌曲列表加载状态。
  final ValueNotifier<LoadState<List<LocalSongEntry>>> state =
      ValueNotifier(const LoadState.loading());

  /// 首次加载本地歌曲列表。
  Future<void> loadInitial() => refresh();

  /// 刷新本地歌曲列表。
  Future<void> refresh() async {
    state.value = const LoadState.loading();
    try {
      final entries = await _libraryRepository.getLocalSongs(origins: origins);
      if (entries.isEmpty) {
        state.value = const LoadState.empty();
        return;
      }
      state.value = LoadState.data(entries);
    } catch (error, stackTrace) {
      state.value = LoadState.error(error, stackTrace: stackTrace);
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
    state.dispose();
  }
}
