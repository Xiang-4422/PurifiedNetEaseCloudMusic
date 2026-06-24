import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';

/// Calculates which indexed local resource files must be retained.
class LocalResourceRetentionPolicy {
  const LocalResourceRetentionPolicy._();

  /// Returns normalized paths that remain retained after removing matching resources.
  static Set<String> retainedPathsAfterRemoving(
    Iterable<LocalResourceEntry> indexedResources, {
    required bool Function(LocalResourceEntry resource) shouldRemove,
  }) {
    final retainedPaths = <String>{};
    for (final resource in indexedResources) {
      if (shouldRemove(resource)) {
        continue;
      }
      final path = normalizedPath(resource);
      if (path.isNotEmpty) {
        retainedPaths.add(path);
      }
    }
    return retainedPaths;
  }

  /// Whether [resource]'s file can be deleted under the current retention set.
  static bool shouldDeleteResourceFile(
    LocalResourceEntry? resource,
    Set<String> retainedPaths, {
    required bool deleteSourceFiles,
  }) {
    if (!deleteSourceFiles || resource == null) {
      return false;
    }
    final path = normalizedPath(resource);
    if (path.isEmpty) {
      return false;
    }
    return !_normalizedRetainedPaths(retainedPaths).contains(path);
  }

  /// Normalizes a local resource path and rejects remote or unsafe URI values.
  static String normalizedPath(LocalResourceEntry resource) {
    return LocalFilePathNormalizer.normalize(resource.path);
  }

  static Set<String> _normalizedRetainedPaths(Set<String> retainedPaths) {
    return retainedPaths.map(LocalFilePathNormalizer.normalize).where((path) => path.isNotEmpty).toSet();
  }
}
