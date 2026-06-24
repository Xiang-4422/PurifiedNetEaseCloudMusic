import 'dart:io';

import 'local_file_path_normalizer.dart';

/// Deletes local files that are not retained by normalized resource index paths.
class RetainedFileCleaner {
  const RetainedFileCleaner._();

  /// Deletes files in [directory] unless their normalized paths are retained.
  ///
  /// Empty child directories are removed after files are processed. The root
  /// directory is recreated so callers can keep using it as a cache target.
  static Future<void> clearDirectory(
    Directory directory, {
    required Set<String> retainedPaths,
  }) async {
    if (directory.existsSync()) {
      await deleteUnretainedDirectoryFiles(
        directory,
        retainedPaths: retainedPaths,
      );
    }
    await directory.create(recursive: true);
  }

  /// Deletes one file if it is local, exists, and is not retained.
  static Future<void> deleteFileUnlessRetained(
    String path,
    Set<String> retainedPaths,
  ) async {
    final localPath = LocalFilePathNormalizer.normalize(path);
    if (localPath.isEmpty || _normalizedRetainedPaths(retainedPaths).contains(localPath)) {
      return;
    }
    final file = File(localPath);
    if (!file.existsSync()) {
      return;
    }
    try {
      await file.delete();
    } catch (_) {}
  }

  /// Deletes all unretained files below [directory] and then empty child dirs.
  static Future<void> deleteUnretainedDirectoryFiles(
    Directory directory, {
    required Set<String> retainedPaths,
  }) async {
    if (!directory.existsSync()) {
      return;
    }
    final retained = _normalizedRetainedPaths(retainedPaths);
    final childDirectories = <Directory>[];
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        await _deleteFileUnlessNormalizedRetained(entity.path, retained);
      } else if (entity is Directory) {
        childDirectories.add(entity);
      }
    }
    childDirectories.sort(
      (left, right) => right.path.length.compareTo(left.path.length),
    );
    for (final childDirectory in childDirectories) {
      try {
        await childDirectory.delete();
      } catch (_) {}
    }
  }

  static Set<String> _normalizedRetainedPaths(Set<String> retainedPaths) {
    final normalized = <String>{};
    for (final retainedPath in retainedPaths) {
      final path = LocalFilePathNormalizer.normalize(retainedPath);
      if (path.isNotEmpty) {
        normalized.add(path);
      }
    }
    return normalized;
  }

  static Future<void> _deleteFileUnlessNormalizedRetained(
    String path,
    Set<String> normalizedRetainedPaths,
  ) async {
    final localPath = LocalFilePathNormalizer.normalize(path);
    if (localPath.isEmpty || normalizedRetainedPaths.contains(localPath)) {
      return;
    }
    final file = File(localPath);
    if (!file.existsSync()) {
      return;
    }
    try {
      await file.delete();
    } catch (_) {}
  }
}
