import 'dart:io';

import 'package:bujuan/core/util/local_file_path_normalizer.dart';

import 'local_media_repository.dart';

/// 本地媒体扫描仓库，负责从文件系统发现可导入的音频资源。
class LocalMediaScanRepository {
  /// 创建本地媒体扫描仓库。
  LocalMediaScanRepository({required LocalMediaRepository localMediaRepository}) : _localMediaRepository = localMediaRepository;

  final LocalMediaRepository _localMediaRepository;

  static const Set<String> _supportedArtworkExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  static const Set<String> _supportedLyricsExtensions = {
    '.lrc',
    '.txt',
  };

  /// 扫描目录并返回可导入的本地音频条目。
  Future<List<LocalTrackImport>> scanDirectories(
    List<String> directoryPaths, {
    bool recursive = true,
  }) async {
    final imports = <LocalTrackImport>[];
    final seenPaths = <String>{};
    for (final directoryPath in directoryPaths) {
      final normalizedDirectoryPath = _localFilePath(directoryPath);
      if (normalizedDirectoryPath.isEmpty) {
        continue;
      }
      final directory = Directory(normalizedDirectoryPath);
      if (!directory.existsSync()) {
        continue;
      }
      final entities = _safeListDirectory(directory, recursive: recursive);
      for (final entity in entities) {
        if (entity is! File) {
          continue;
        }
        final filePath = entity.path;
        if (!seenPaths.add(filePath) || !_isSupportedAudioFile(filePath)) {
          continue;
        }
        imports.add(
          LocalTrackImport(
            filePath: filePath,
            title: _localMediaRepository.buildTrackTitleFromPath(filePath),
            localArtworkPath: _findArtworkPath(filePath),
            localLyricsPath: _findLyricsPath(filePath),
            metadata: {
              'scanSource': 'directory',
              'scannedAt': DateTime.now().millisecondsSinceEpoch,
            },
          ),
        );
      }
    }
    return imports;
  }

  /// 扫描指定文件路径并返回可导入的本地音频条目。
  Future<List<LocalTrackImport>> scanFiles(List<String> filePaths) async {
    final imports = <LocalTrackImport>[];
    final seenPaths = <String>{};
    for (final rawFilePath in filePaths) {
      final filePath = _localFilePath(rawFilePath);
      if (filePath.isEmpty || !seenPaths.add(filePath) || !_isSupportedAudioFile(filePath)) {
        continue;
      }
      final file = File(filePath);
      if (!file.existsSync()) {
        continue;
      }
      imports.add(
        LocalTrackImport(
          filePath: filePath,
          title: _localMediaRepository.buildTrackTitleFromPath(filePath),
          localArtworkPath: _findArtworkPath(filePath),
          localLyricsPath: _findLyricsPath(filePath),
          metadata: {
            'scanSource': 'file_selection',
            'scannedAt': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
    }
    return imports;
  }

  /// 扫描目录并写入本地媒体库，返回成功导入数量。
  Future<int> importDirectories(
    List<String> directoryPaths, {
    bool recursive = true,
  }) async {
    final tracks = await scanDirectories(directoryPaths, recursive: recursive);
    if (tracks.isEmpty) {
      return 0;
    }
    await _localMediaRepository.importLocalTracks(tracks);
    return tracks.length;
  }

  /// 扫描指定文件并写入本地媒体库，返回成功导入数量。
  Future<int> importFiles(List<String> filePaths) async {
    final tracks = await scanFiles(filePaths);
    if (tracks.isEmpty) {
      return 0;
    }
    await _localMediaRepository.importLocalTracks(tracks);
    return tracks.length;
  }

  bool _isSupportedAudioFile(String path) {
    return LocalMediaRepository.isSupportedAudioFilePath(path);
  }

  String _localFilePath(String rawPath) {
    final normalized = LocalFilePathNormalizer.normalize(rawPath);
    return normalized.isEmpty ? '' : File(normalized).path;
  }

  /// 本地导入时优先猜测同目录同名资源，避免用户明明已经整理好封面和歌词，
  /// 但导入后还要重新走一次手工补全。
  String? _findArtworkPath(String audioPath) {
    final audioFile = File(audioPath);
    final sidecarArtworkPath = _findSidecarPath(
      audioFile,
      extensions: _supportedArtworkExtensions,
    );
    if (sidecarArtworkPath != null) {
      return sidecarArtworkPath;
    }

    final directory = audioFile.parent;
    const fallbackNames = {'cover', 'folder', 'front', 'album'};
    for (final entity in _safeListDirectory(directory)) {
      if (entity is! File) {
        continue;
      }
      final fileName = entity.uri.pathSegments.last.toLowerCase();
      final extension = _extensionOf(fileName);
      final nameWithoutExtension = _fileNameWithoutExtension(fileName);
      if (_supportedArtworkExtensions.contains(extension) && fallbackNames.contains(nameWithoutExtension)) {
        return entity.path;
      }
    }
    return null;
  }

  String? _findLyricsPath(String audioPath) {
    return _findSidecarPath(
      File(audioPath),
      extensions: _supportedLyricsExtensions,
    );
  }

  String? _findSidecarPath(
    File sourceFile, {
    required Set<String> extensions,
  }) {
    final sourceName = _fileNameWithoutExtension(_fileNameOf(sourceFile.path)).toLowerCase();
    for (final entity in _safeListDirectory(sourceFile.parent)) {
      if (entity is! File) {
        continue;
      }
      final fileName = _fileNameOf(entity.path);
      final extension = _extensionOf(fileName).toLowerCase();
      if (!extensions.contains(extension)) {
        continue;
      }
      if (_fileNameWithoutExtension(fileName).toLowerCase() == sourceName) {
        return entity.path;
      }
    }

    final basePath = _filePathWithoutExtension(sourceFile.path);
    for (final extension in extensions) {
      final sidecarFile = File('$basePath$extension');
      if (sidecarFile.existsSync()) {
        return sidecarFile.path;
      }
    }
    return null;
  }

  List<FileSystemEntity> _safeListDirectory(
    Directory directory, {
    bool recursive = false,
  }) {
    try {
      return directory.listSync(
        recursive: recursive,
        followLinks: false,
      );
    } on FileSystemException {
      return const <FileSystemEntity>[];
    }
  }

  String _filePathWithoutExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) {
      return path;
    }
    return path.substring(0, dotIndex);
  }

  String _fileNameWithoutExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) {
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }

  String _extensionOf(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) {
      return '';
    }
    return fileName.substring(dotIndex);
  }

  String _fileNameOf(String path) {
    return path.replaceAll('\\', '/').split('/').last;
  }
}
