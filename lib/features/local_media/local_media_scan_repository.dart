import 'dart:io';

import 'local_media_repository.dart';

class LocalMediaScanRepository {
  LocalMediaScanRepository({LocalMediaRepository? localMediaRepository})
      : _localMediaRepository = localMediaRepository ?? LocalMediaRepository();

  final LocalMediaRepository _localMediaRepository;

  static const Set<String> _supportedExtensions = {
    '.mp3',
    '.flac',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
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
}
