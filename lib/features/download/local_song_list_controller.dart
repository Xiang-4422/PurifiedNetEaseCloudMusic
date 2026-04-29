import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/local_song_entry.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class LocalSongListController {
  LocalSongListController({
    required LibraryRepository libraryRepository,
    required DownloadRepository downloadRepository,
    this.origins,
  })  : _libraryRepository = libraryRepository,
        _downloadRepository = downloadRepository;

  factory LocalSongListController.create({
    Set<TrackResourceOrigin>? origins,
  }) {
    return LocalSongListController(
      libraryRepository: Get.find<LibraryRepository>(),
      downloadRepository: Get.find<DownloadRepository>(),
      origins: origins,
    );
  }

  final LibraryRepository _libraryRepository;
  final DownloadRepository _downloadRepository;
  final Set<TrackResourceOrigin>? origins;

  final ValueNotifier<LoadState<List<LocalSongEntry>>> state =
      ValueNotifier(const LoadState.loading());

  Future<void> loadInitial() => refresh();

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
