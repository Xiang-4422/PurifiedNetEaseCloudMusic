import 'dart:io';

import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/core/util/playback_url_expiry.dart';

/// Normalizes and validates concrete playback source references.
class PlaybackSourceReference {
  const PlaybackSourceReference._();

  /// Returns a trimmed HTTP(S) URL with an authority, or an empty string.
  static String remoteHttpUrl(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(trimmedValue);
    final scheme = uri?.scheme.toLowerCase();
    if ((scheme == 'http' || scheme == 'https') && uri?.host.isNotEmpty == true) {
      return trimmedValue;
    }
    return '';
  }

  /// Whether [value] is a valid remote HTTP(S) playback URL.
  static bool isRemoteHttpUrl(String? value) {
    return remoteHttpUrl(value).isNotEmpty;
  }

  /// Returns a valid non-expired remote HTTP(S) URL, or an empty string.
  static String freshRemoteHttpUrl(String? value, {DateTime? now}) {
    final remoteUrl = remoteHttpUrl(value);
    if (remoteUrl.isEmpty || PlaybackUrlExpiry.isExpired(remoteUrl, now: now)) {
      return '';
    }
    return remoteUrl;
  }

  /// Whether [value] is a valid non-expired remote HTTP(S) playback URL.
  static bool isFreshRemoteHttpUrl(String? value, {DateTime? now}) {
    return freshRemoteHttpUrl(value, now: now).isNotEmpty;
  }

  /// Returns a normalized local file-system path, or an empty string.
  static String localPath(String? value) {
    return LocalFilePathNormalizer.normalize(value);
  }

  /// Returns a normalized existing local file path, or an empty string.
  static String existingLocalPath(String? value) {
    final normalizedPath = localPath(value);
    if (normalizedPath.isEmpty || !File(normalizedPath).existsSync()) {
      return '';
    }
    return normalizedPath;
  }

  /// Whether [value] resolves to an existing local file.
  static bool isExistingLocalPath(String? value) {
    return existingLocalPath(value).isNotEmpty;
  }

  /// Returns a normalized playback reference usable by data-layer caches.
  static String playbackReference(String? value) {
    final remoteUrl = remoteHttpUrl(value);
    if (remoteUrl.isNotEmpty) {
      return remoteUrl;
    }
    return localPath(value);
  }
}
