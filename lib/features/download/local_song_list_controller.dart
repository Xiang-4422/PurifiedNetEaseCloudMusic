import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:flutter/foundation.dart';

class LocalSongListController {
  LocalSongListController({
    LibraryRepository? libraryRepository,
    DownloadRepository? downloadRepository,
    this.origins,
  })  : _libraryRepository = libraryRepository ?? LibraryRepository(),
        _downloadRepository = downloadRepository ?? DownloadRepository();

  final LibraryRepository _libraryRepository;
  final DownloadRepository _downloadRepository;
  final Set<TrackResourceOrigin>? origins;

  final ValueNotifier<LoadState<List<Track>>> state =
      ValueNotifier(const LoadState.loading());

  Future<void> loadInitial() => refresh();

  Future<void> refresh() async {
    state.value = const LoadState.loading();
    try {
      final tracks = await _libraryRepository.getLocalTracks(origins: origins);
      if (tracks.isEmpty) {
        state.value = const LoadState.empty();
        return;
      }
      state.value = LoadState.data(tracks);
    } catch (error, stackTrace) {
      state.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<void> removeLocalTrack(String trackId) async {
    await _downloadRepository.removeLocalTrack(trackId);
    await refresh();
  }

  Future<void> clearPlaybackCache() async {
    await _downloadRepository.clearPlaybackCache();
    await refresh();
  }

  void dispose() {
    state.dispose();
  }
}
