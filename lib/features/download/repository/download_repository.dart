import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:get_it/get_it.dart';

class DownloadRepository {
  DownloadRepository({LibraryRepository? libraryRepository})
      : _libraryRepository =
            libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<Track?> markQueued(String trackId) {
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
  }) {
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
  }) {
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
  }) {
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.failed,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadFailureReason: reason ?? '',
    );
  }
}
