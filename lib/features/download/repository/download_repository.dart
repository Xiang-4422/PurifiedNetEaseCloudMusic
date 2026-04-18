import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:get_it/get_it.dart';

import 'download_task_store.dart';

class DownloadRepository {
  DownloadRepository({
    LibraryRepository? libraryRepository,
    DownloadTaskStore? taskStore,
  })  : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _taskStore = taskStore ?? const DownloadTaskStore();

  final LibraryRepository _libraryRepository;
  final DownloadTaskStore _taskStore;

  Future<Track?> markQueued(String trackId) async {
    await _taskStore.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.queued,
        updatedAt: DateTime.now(),
        progress: 0,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.queued,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadProgress: 0,
      downloadFailureReason: '',
    );
  }

  Future<Track?> markDownloading(
    String trackId, {
    double? progress,
  }) async {
    await _taskStore.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.downloading,
        updatedAt: DateTime.now(),
        progress: progress ?? 0,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.downloading,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadProgress: progress ?? 0,
      downloadFailureReason: '',
    );
  }

  Future<Track?> markDownloaded(
    String trackId, {
    required String localPath,
    String? artworkPath,
    String? lyricsPath,
  }) async {
    await _taskStore.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.completed,
        updatedAt: DateTime.now(),
        progress: 1,
        localPath: localPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      localPath: localPath,
      localArtworkPath: artworkPath,
      localLyricsPath: lyricsPath,
      downloadState: DownloadState.downloaded,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadProgress: 1,
      downloadFailureReason: '',
      availability: TrackAvailability.playable,
    );
  }

  Future<Track?> markFailed(
    String trackId, {
    String? reason,
  }) async {
    final currentTask = await _taskStore.getTask(trackId);
    await _taskStore.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.failed,
        updatedAt: DateTime.now(),
        progress: currentTask?.progress,
        localPath: currentTask?.localPath,
        artworkPath: currentTask?.artworkPath,
        lyricsPath: currentTask?.lyricsPath,
        failureReason: reason,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.failed,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadFailureReason: reason ?? '',
    );
  }
}
