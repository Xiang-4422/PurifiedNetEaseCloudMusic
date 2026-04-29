import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';

/// 负责把本地文件导入资料库并登记本地资源索引。
class LocalMediaRepository {
  /// 创建本地媒体仓库。
  LocalMediaRepository({
    required LibraryRepository libraryRepository,
    required LocalResourceIndexRepository resourceIndexRepository,
  })  : _libraryRepository = libraryRepository,
        _resourceIndexRepository = resourceIndexRepository;

  final LibraryRepository _libraryRepository;
  final LocalResourceIndexRepository _resourceIndexRepository;

  /// 导入单个本地音频文件，并可同时登记封面和歌词资源。
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

  /// 批量导入本地音频文件，并保持输入顺序写入资源索引。
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

  /// 从文件路径推导默认曲目标题。
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

/// 本地曲目导入时携带的文件路径和可选元数据。
class LocalTrackImport {
  /// 创建本地曲目导入参数。
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

  /// 音频文件路径。
  final String filePath;

  /// 曲目标题。
  final String title;

  /// 歌手名称列表。
  final List<String> artistNames;

  /// 专辑标题。
  final String? albumTitle;

  /// 曲目时长，单位毫秒。
  final int? durationMs;

  /// 远程或外部封面地址。
  final String? artworkUrl;

  /// 本地封面文件路径。
  final String? localArtworkPath;

  /// 本地歌词文件路径。
  final String? localLyricsPath;

  /// 导入时保留的扩展元数据。
  final Map<String, Object?> metadata;
}
