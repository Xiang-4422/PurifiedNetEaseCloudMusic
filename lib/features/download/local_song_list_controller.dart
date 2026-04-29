import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/local_song_entry.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:flutter/foundation.dart';

/// LocalSongListController。
class LocalSongListController {
  /// 创建 LocalSongListController。
  LocalSongListController({
    required LibraryRepository libraryRepository,
    required DownloadRepository downloadRepository,
    this.origins,
  })  : _libraryRepository = libraryRepository,
        _downloadRepository = downloadRepository;

  final LibraryRepository _libraryRepository;
  final DownloadRepository _downloadRepository;

  /// origins。
  final Set<TrackResourceOrigin>? origins;

  /// state。
  final ValueNotifier<LoadState<List<LocalSongEntry>>> state =
      ValueNotifier(const LoadState.loading());

  /// loadInitial。
  Future<void> loadInitial() => refresh();

  /// refresh。
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

  /// removeLocalTrack。
  Future<void> removeLocalTrack(String trackId) async {
    await _downloadRepository.removeLocalTrack(trackId);
    await refresh();
  }

  /// clearPlaybackCache。
  Future<void> clearPlaybackCache() async {
    await _downloadRepository.clearPlaybackCache();
    await refresh();
  }

  /// dispose。
  void dispose() {
    state.dispose();
  }
}
