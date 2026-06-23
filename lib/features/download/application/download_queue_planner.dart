import 'dart:async';
import 'dart:io';

import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/core/entities/download_task.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/download/application/download_background_error_handler.dart';

/// 下载队列规划器，负责过滤无需下载或已在下载中的曲目。
class DownloadQueuePlanner {
  /// 创建下载队列规划器。
  DownloadQueuePlanner({
    required MusicDataRepository musicDataRepository,
    required DownloadTaskDataSource taskDataSource,
    DownloadBackgroundErrorHandler? onQueuedDownloadError,
  })  : _musicDataRepository = musicDataRepository,
        _taskDataSource = taskDataSource,
        _onQueuedDownloadError = onQueuedDownloadError;

  final MusicDataRepository _musicDataRepository;
  final DownloadTaskDataSource _taskDataSource;
  final DownloadBackgroundErrorHandler? _onQueuedDownloadError;

  /// 将候选曲目加入下载队列。
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
    final tracksWithResources = await _musicDataRepository.getTracksWithResources(candidateIds);
    final tracksById = {
      for (final item in tracksWithResources) item.track.id: item,
    };
    final activeTasks = await _taskDataSource.getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
    final activeTaskIds = activeTasks.map((task) => task.trackId).toSet();
    for (final trackId in candidateIds) {
      final trackWithResources = tracksById[trackId];
      if (activeTaskIds.contains(trackId)) {
        continue;
      }
      if (trackWithResources == null) {
        continue;
      }
      final track = trackWithResources.track;
      final audioResource = trackWithResources.resources.audio;
      if (track.sourceType == SourceType.local || _isAvailableLocalAudioResource(audioResource)) {
        continue;
      }
      unawaited(
        _startQueuedDownload(
          trackId,
          downloadTrack,
          preferHighQuality: preferHighQuality,
        ),
      );
    }
  }

  Future<void> _startQueuedDownload(
    String trackId,
    Future<Track?> Function(
      String trackId, {
      bool preferHighQuality,
    }) downloadTrack, {
    required bool preferHighQuality,
  }) async {
    try {
      await downloadTrack(
        trackId,
        preferHighQuality: preferHighQuality,
      );
    } catch (error, stackTrace) {
      try {
        _onQueuedDownloadError?.call(trackId, error, stackTrace);
      } catch (_) {}
    }
  }

  bool _isAvailableLocalAudioResource(LocalResourceEntry? resource) {
    if (resource == null ||
        !const {
          TrackResourceOrigin.localImport,
          TrackResourceOrigin.managedDownload,
        }.contains(resource.origin)) {
      return false;
    }
    final path = LocalFilePathNormalizer.normalize(resource.path);
    return path.isNotEmpty && File(path).existsSync();
  }
}
