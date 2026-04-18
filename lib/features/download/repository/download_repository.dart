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
      metadata: {'downloadOrigin': 'managed_download'},
    );
  }

  Future<Track?> markDownloading(
    String trackId, {
    double? progress,
  }) {
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.downloading,
      metadata: {
        'downloadOrigin': 'managed_download',
        if (progress != null) 'downloadProgress': progress,
      },
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
      downloadState: DownloadState.downloaded,
      availability: TrackAvailability.playable,
      metadata: {
        'downloadOrigin': 'managed_download',
        'downloadProgress': 1.0,
        if (artworkPath != null) 'localArtworkPath': artworkPath,
        if (lyricsPath != null) 'localLyricsPath': lyricsPath,
      },
    );
  }

  Future<Track?> markFailed(
    String trackId, {
    String? reason,
  }) {
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.failed,
      metadata: {
        'downloadOrigin': 'managed_download',
        if (reason != null) 'downloadFailureReason': reason,
      },
    );
  }
}
