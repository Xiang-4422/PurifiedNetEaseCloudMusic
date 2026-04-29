import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';

/// LocalMediaRepository。
class LocalMediaRepository {
  /// 创建 LocalMediaRepository。
  LocalMediaRepository({
    required LibraryRepository libraryRepository,
    required LocalResourceIndexRepository resourceIndexRepository,
  })  : _libraryRepository = libraryRepository,
        _resourceIndexRepository = resourceIndexRepository;

  final LibraryRepository _libraryRepository;
  final LocalResourceIndexRepository _resourceIndexRepository;

  /// importLocalTrack。
  Future<Track> importLocalTrack({
    required String filePath,
    required String title,
    List<String> artistNames = const [],
    String? albumTitle,
    int? durationMs,
    String? artworkUrl,
    String? localArtworkPath,
    String? localLyricsPath,
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
      availability: TrackAvailability.localOnly,
      metadata: metadata,
    );
    await _libraryRepository.saveTrack(track);
    await _resourceIndexRepository.saveAudioResource(
      track.id,
      path: filePath,
      origin: TrackResourceOrigin.localImport,
    );
    if (localArtworkPath?.isNotEmpty == true) {
      await _resourceIndexRepository.saveArtworkResource(
        track.id,
        path: localArtworkPath!,
        origin: TrackResourceOrigin.localImport,
      );
    }
    if (localLyricsPath?.isNotEmpty == true) {
      await _resourceIndexRepository.saveLyricsResource(
        track.id,
        path: localLyricsPath!,
        origin: TrackResourceOrigin.localImport,
      );
    }
    return track;
  }

  /// importLocalTracks。
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
            availability: TrackAvailability.localOnly,
            metadata: track.metadata,
          ),
        )
        .toList();
    await _libraryRepository.saveTracks(importedTracks);
    for (var i = 0; i < importedTracks.length; i++) {
      final track = importedTracks[i];
      final localPath = tracks[i].filePath;
      await _resourceIndexRepository.saveAudioResource(
        track.id,
        path: localPath,
        origin: TrackResourceOrigin.localImport,
      );
      final localArtworkPath = tracks[i].localArtworkPath;
      if (localArtworkPath?.isNotEmpty == true) {
        await _resourceIndexRepository.saveArtworkResource(
          track.id,
          path: localArtworkPath!,
          origin: TrackResourceOrigin.localImport,
        );
      }
      final localLyricsPath = tracks[i].localLyricsPath;
      if (localLyricsPath?.isNotEmpty == true) {
        await _resourceIndexRepository.saveLyricsResource(
          track.id,
          path: localLyricsPath!,
          origin: TrackResourceOrigin.localImport,
        );
      }
    }
    return importedTracks;
  }

  /// buildTrackTitleFromPath。
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

/// LocalTrackImport。
class LocalTrackImport {
  /// 创建 LocalTrackImport。
  const LocalTrackImport({
    required this.filePath,
    required this.title,
    this.artistNames = const [],
    this.albumTitle,
    this.durationMs,
    this.artworkUrl,
    this.localArtworkPath,
    this.localLyricsPath,
    this.metadata = const {},
  });

  /// filePath。
  final String filePath;

  /// title。
  final String title;

  /// artistNames。
  final List<String> artistNames;

  /// albumTitle。
  final String? albumTitle;

  /// durationMs。
  final int? durationMs;

  /// artworkUrl。
  final String? artworkUrl;

  /// localArtworkPath。
  final String? localArtworkPath;

  /// localLyricsPath。
  final String? localLyricsPath;

  /// metadata。
  final Map<String, Object?> metadata;
}
