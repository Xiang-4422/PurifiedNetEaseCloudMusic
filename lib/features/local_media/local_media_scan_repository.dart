import 'dart:io';

import 'local_media_repository.dart';

class LocalMediaScanRepository {
  LocalMediaScanRepository({required LocalMediaRepository localMediaRepository})
      : _localMediaRepository = localMediaRepository;

  final LocalMediaRepository _localMediaRepository;

  static const Set<String> _supportedExtensions = {
    '.mp3',
    '.flac',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
  };

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

  Future<List<LocalTrackImport>> scanDirectories(
    List<String> directoryPaths, {
    bool recursive = true,
  }) async {
    final imports = <LocalTrackImport>[];
    final seenPaths = <String>{};
    for (final directoryPath in directoryPaths) {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        continue;
      }
      final entities = directory.listSync(recursive: recursive);
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

  Future<List<LocalTrackImport>> scanFiles(List<String> filePaths) async {
    final imports = <LocalTrackImport>[];
    final seenPaths = <String>{};
    for (final filePath in filePaths) {
      if (!seenPaths.add(filePath) || !_isSupportedAudioFile(filePath)) {
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

  Future<int> importFiles(List<String> filePaths) async {
    final tracks = await scanFiles(filePaths);
    if (tracks.isEmpty) {
      return 0;
    }
    await _localMediaRepository.importLocalTracks(tracks);
    return tracks.length;
  }

  bool _isSupportedAudioFile(String path) {
    final normalizedPath = path.toLowerCase();
    return _supportedExtensions.any(normalizedPath.endsWith);
  }

  /// 本地导入时优先猜测同目录同名资源，避免用户明明已经整理好封面和歌词，
  /// 但导入后还要重新走一次手工补全。
  String? _findArtworkPath(String audioPath) {
    final audioFile = File(audioPath);
    final basePath = _filePathWithoutExtension(audioFile.path);
    for (final extension in _supportedArtworkExtensions) {
      final artworkFile = File('$basePath$extension');
      if (artworkFile.existsSync()) {
        return artworkFile.path;
      }
    }

    final directory = audioFile.parent;
    const fallbackNames = {'cover', 'folder', 'front', 'album'};
    for (final entity in directory.listSync()) {
      if (entity is! File) {
        continue;
      }
      final fileName = entity.uri.pathSegments.last.toLowerCase();
      final extension = _extensionOf(fileName);
      final nameWithoutExtension = _fileNameWithoutExtension(fileName);
      if (_supportedArtworkExtensions.contains(extension) &&
          fallbackNames.contains(nameWithoutExtension)) {
        return entity.path;
      }
    }
    return null;
  }

  String? _findLyricsPath(String audioPath) {
    final basePath = _filePathWithoutExtension(audioPath);
    for (final extension in _supportedLyricsExtensions) {
      final lyricsFile = File('$basePath$extension');
      if (lyricsFile.existsSync()) {
        return lyricsFile.path;
      }
    }
    return null;
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
}
