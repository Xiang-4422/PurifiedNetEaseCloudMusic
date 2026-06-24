import 'dart:io';

import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';

/// 负责把本地文件导入资料库并登记本地资源索引。
class LocalMediaRepository {
  /// 创建本地媒体仓库。
  LocalMediaRepository({
    required MusicDataRepository musicDataRepository,
    required LocalResourceIndexRepository resourceIndexRepository,
  })  : _musicDataRepository = musicDataRepository,
        _resourceIndexRepository = resourceIndexRepository;

  final MusicDataRepository _musicDataRepository;
  final LocalResourceIndexRepository _resourceIndexRepository;

  static const Set<String> _supportedAudioExtensions = {
    '.mp3',
    '.flac',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
  };

  /// 当前文件路径是否是本地导入支持的音频格式。
  static bool isSupportedAudioFilePath(String filePath) {
    final normalizedPath = filePath.trim().toLowerCase();
    return _supportedAudioExtensions.any(normalizedPath.endsWith);
  }

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
    final localFilePath = _normalizeRequiredLocalAudioFilePath(
      filePath,
      argumentName: 'filePath',
    );
    final artworkPath = _normalizeOptionalLocalFilePath(localArtworkPath);
    final lyricsPath = _normalizeOptionalLocalFilePath(localLyricsPath);
    final track = Track(
      id: _buildLocalTrackId(localFilePath),
      sourceType: SourceType.local,
      sourceId: localFilePath,
      title: title,
      artistNames: artistNames,
      albumTitle: albumTitle,
      durationMs: durationMs,
      artworkUrl: artworkUrl,
      availability: TrackAvailability.localOnly,
      metadata: metadata,
    );
    await _musicDataRepository.saveTrack(track, precacheArtwork: false);
    await _resourceIndexRepository.saveAudioResource(
      track.id,
      path: localFilePath,
      origin: TrackResourceOrigin.localImport,
    );
    if (artworkPath != null) {
      await _resourceIndexRepository.saveArtworkResource(
        track.id,
        path: artworkPath,
        origin: TrackResourceOrigin.localImport,
      );
    }
    if (lyricsPath != null) {
      await _resourceIndexRepository.saveLyricsResource(
        track.id,
        path: lyricsPath,
        origin: TrackResourceOrigin.localImport,
      );
    }
    return track;
  }

  /// 批量导入本地音频文件，并保持输入顺序写入资源索引。
  Future<List<Track>> importLocalTracks(List<LocalTrackImport> tracks) async {
    final normalizedTracks = <LocalTrackImport>[];
    for (final track in tracks) {
      final localFilePath = _normalizeExistingLocalAudioFilePath(track.filePath);
      if (localFilePath == null) {
        continue;
      }
      normalizedTracks.add(
        track.copyWith(
          filePath: localFilePath,
          localArtworkPath: _normalizeOptionalLocalFilePath(
            track.localArtworkPath,
          ),
          localLyricsPath: _normalizeOptionalLocalFilePath(
            track.localLyricsPath,
          ),
        ),
      );
    }
    if (normalizedTracks.isEmpty) {
      return const <Track>[];
    }
    final importedTracks = normalizedTracks.map((track) {
      return Track(
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
      );
    }).toList();
    await _musicDataRepository.saveTracks(
      importedTracks,
      precacheArtwork: false,
    );
    for (var i = 0; i < importedTracks.length; i++) {
      final track = importedTracks[i];
      final localPath = normalizedTracks[i].filePath;
      await _resourceIndexRepository.saveAudioResource(
        track.id,
        path: localPath,
        origin: TrackResourceOrigin.localImport,
      );
      final localArtworkPath = normalizedTracks[i].localArtworkPath;
      if (localArtworkPath?.isNotEmpty == true) {
        await _resourceIndexRepository.saveArtworkResource(
          track.id,
          path: localArtworkPath!,
          origin: TrackResourceOrigin.localImport,
        );
      }
      final localLyricsPath = normalizedTracks[i].localLyricsPath;
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

  String _normalizeRequiredLocalAudioFilePath(
    String path, {
    required String argumentName,
  }) {
    final normalized = _normalizeExistingLocalAudioFilePath(path);
    if (normalized == null) {
      throw ArgumentError.value(
        path,
        argumentName,
        'Expected an existing local file path.',
      );
    }
    return normalized;
  }

  String? _normalizeExistingLocalAudioFilePath(String path) {
    final normalized = _normalizeExistingLocalFilePath(path);
    if (normalized == null || !isSupportedAudioFilePath(normalized)) {
      return null;
    }
    return normalized;
  }

  String? _normalizeExistingLocalFilePath(String path) {
    final normalized = _localFilePath(path);
    if (normalized.isEmpty) {
      return null;
    }
    final file = File(normalized);
    return file.existsSync() ? file.path : null;
  }

  String? _normalizeOptionalLocalFilePath(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    return _normalizeExistingLocalFilePath(path);
  }

  String _localFilePath(String rawPath) {
    final normalized = LocalFilePathNormalizer.normalize(rawPath);
    return normalized.isEmpty ? '' : File(normalized).path;
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

  /// 复制导入参数并替换指定字段。
  LocalTrackImport copyWith({
    String? filePath,
    String? title,
    List<String>? artistNames,
    String? albumTitle,
    int? durationMs,
    String? artworkUrl,
    Object? localArtworkPath = _unset,
    Object? localLyricsPath = _unset,
    Map<String, Object?>? metadata,
  }) {
    return LocalTrackImport(
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artistNames: artistNames ?? this.artistNames,
      albumTitle: albumTitle ?? this.albumTitle,
      durationMs: durationMs ?? this.durationMs,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: identical(localArtworkPath, _unset) ? this.localArtworkPath : localArtworkPath as String?,
      localLyricsPath: identical(localLyricsPath, _unset) ? this.localLyricsPath : localLyricsPath as String?,
      metadata: metadata ?? this.metadata,
    );
  }

  static const Object _unset = Object();
}
