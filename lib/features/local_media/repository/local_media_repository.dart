import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:get_it/get_it.dart';

class LocalMediaRepository {
  LocalMediaRepository({LibraryRepository? libraryRepository})
      : _libraryRepository =
            libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<Track> importLocalTrack({
    required String filePath,
    required String title,
    List<String> artistNames = const [],
    String? albumTitle,
    int? durationMs,
    String? artworkUrl,
    Map<String, Object?> metadata = const {},
  }) async {
    final track = Track(
      id: _buildLocalTrackId(filePath),
      sourceType: SourceType.local,
      sourceId: filePath,
      title: title,
      artistNames: artistNames,
      albumTitle: albumTitle,
      durationMs: durationMs,
      artworkUrl: artworkUrl,
      localPath: filePath,
      availability: TrackAvailability.localOnly,
      downloadState: DownloadState.downloaded,
      metadata: {
        'importedFrom': 'local_scan',
        ...metadata,
      },
    );
    await _libraryRepository.saveTrack(track);
    return track;
  }

  Future<List<Track>> importLocalTracks(List<LocalTrackImport> tracks) async {
    final importedTracks = tracks
        .map(
          (track) => Track(
            id: _buildLocalTrackId(track.filePath),
            sourceType: SourceType.local,
            sourceId: track.filePath,
            title: track.title,
            artistNames: track.artistNames,
            albumTitle: track.albumTitle,
            durationMs: track.durationMs,
            artworkUrl: track.artworkUrl,
            localPath: track.filePath,
            availability: TrackAvailability.localOnly,
            downloadState: DownloadState.downloaded,
            metadata: {
              'importedFrom': 'local_scan',
              ...track.metadata,
            },
          ),
        )
        .toList();
    await _libraryRepository.saveTracks(importedTracks);
    return importedTracks;
  }

  String buildTrackTitleFromPath(String filePath) {
    final normalizedPath = filePath.replaceAll('\\', '/');
    final fileName = normalizedPath.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }

  String _buildLocalTrackId(String filePath) {
    return 'local:$filePath';
  }
}

class LocalTrackImport {
  const LocalTrackImport({
    required this.filePath,
    required this.title,
    this.artistNames = const [],
    this.albumTitle,
    this.durationMs,
    this.artworkUrl,
    this.metadata = const {},
  });

  final String filePath;
  final String title;
  final List<String> artistNames;
  final String? albumTitle;
  final int? durationMs;
  final String? artworkUrl;
  final Map<String, Object?> metadata;
}
