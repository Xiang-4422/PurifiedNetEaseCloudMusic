import 'dart:io';

/// Normalizes app-owned local file references before file-system operations.
class LocalFilePathNormalizer {
  const LocalFilePathNormalizer._();

  /// Returns a local file-system path, or an empty string when [value] is not a
  /// safe local file reference.
  static String normalize(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return '';
    }

    final pathCandidate = trimmedValue.split('?').first;
    if (_looksLikeWindowsDrivePath(pathCandidate)) {
      return pathCandidate;
    }

    final uri = Uri.tryParse(trimmedValue);
    final scheme = uri?.scheme.toLowerCase();
    if (uri != null && scheme == 'file') {
      final host = uri.host.toLowerCase();
      if (!Platform.isWindows && host.isNotEmpty && host != 'localhost') {
        return '';
      }
      return Uri(
        scheme: 'file',
        host: Platform.isWindows && host.isNotEmpty && host != 'localhost' ? uri.host : null,
        path: uri.path,
      ).toFilePath(windows: Platform.isWindows);
    }
    if (scheme != null && scheme.isNotEmpty) {
      return '';
    }
    return pathCandidate;
  }

  static bool _looksLikeWindowsDrivePath(String value) {
    return RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);
  }
}
