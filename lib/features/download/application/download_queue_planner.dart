import 'dart:async';

import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

class DownloadQueuePlanner {
  DownloadQueuePlanner({
    required LibraryRepository libraryRepository,
    required DownloadTaskDataSource taskDataSource,
  })  : _libraryRepository = libraryRepository,
        _taskDataSource = taskDataSource;

  final LibraryRepository _libraryRepository;
  final DownloadTaskDataSource _taskDataSource;

  Future<void> queueTracks(
    Iterable<String> trackIds, {
    required Future<Track?> Function(
      String trackId, {
      bool preferHighQuality,
    }) downloadTrack,
    bool preferHighQuality = true,
  }) async {
    final candidateIds = trackIds.toSet().toList();
    if (candidateIds.isEmpty) {
      return;
    }
    final tracksWithResources =
        await _libraryRepository.getTracksWithResources(candidateIds);
    final tracksById = {
      for (final item in tracksWithResources) item.track.id: item,
    };
    for (final trackId in candidateIds) {
      final trackWithResources = tracksById[trackId];
      final currentTask = await _taskDataSource.getTask(trackId);
      if (currentTask != null &&
          {
            DownloadTaskStatus.queued,
            DownloadTaskStatus.downloading,
          }.contains(currentTask.status)) {
        continue;
      }
      if (trackWithResources == null) {
        continue;
      }
      final track = trackWithResources.track;
      final audioResource = trackWithResources.resources.audio;
      if (track.sourceType == SourceType.local ||
          audioResource?.origin == TrackResourceOrigin.managedDownload) {
        continue;
      }
      unawaited(
        downloadTrack(trackId, preferHighQuality: preferHighQuality),
      );
    }
  }
}
