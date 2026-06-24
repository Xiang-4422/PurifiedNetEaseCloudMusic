import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';

/// Centralizes local track resource availability and cache semantics.
class TrackResourceAvailability {
  const TrackResourceAvailability._();

  /// Audio origins that can be used directly by playback.
  static const Set<TrackResourceOrigin> playableAudioOrigins = {
    TrackResourceOrigin.localImport,
    TrackResourceOrigin.managedDownload,
    TrackResourceOrigin.playbackCache,
  };

  /// Audio origins that should be shown as cached in playback UI.
  static const Set<TrackResourceOrigin> cachedAudioOrigins = {
    TrackResourceOrigin.managedDownload,
    TrackResourceOrigin.playbackCache,
  };

  /// Audio origins that make a normal download request unnecessary.
  static const Set<TrackResourceOrigin> downloadSatisfiedAudioOrigins = {
    TrackResourceOrigin.localImport,
    TrackResourceOrigin.managedDownload,
  };

  /// Returns the precedence of a resource origin when multiple local facts race.
  static int originPriority(TrackResourceOrigin origin) {
    switch (origin) {
      case TrackResourceOrigin.localImport:
        return 3;
      case TrackResourceOrigin.managedDownload:
        return 2;
      case TrackResourceOrigin.playbackCache:
        return 1;
      case TrackResourceOrigin.artworkCache:
      case TrackResourceOrigin.none:
        return 0;
    }
  }

  /// Whether an existing indexed resource should stay over a new origin.
  static bool shouldKeepExistingResource(
    LocalResourceEntry? existing, {
    required TrackResourceOrigin newOrigin,
  }) {
    return existing != null && originPriority(existing.origin) > originPriority(newOrigin) && existingLocalPath(existing) != null;
  }

  /// Returns a normalized local path for an indexed resource, or null.
  static String? localPath(LocalResourceEntry? resource) {
    if (resource == null) {
      return null;
    }
    return _emptyToNull(LocalFilePathNormalizer.normalize(resource.path));
  }

  /// Returns an existing local file for a raw path or safe file URI.
  static File? existingFileForPath(String? rawPath) {
    final path = LocalFilePathNormalizer.normalize(rawPath);
    if (path.isEmpty) {
      return null;
    }
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  /// Returns an existing local resource path after optional kind/origin checks.
  static String? existingLocalPath(
    LocalResourceEntry? resource, {
    LocalResourceKind? kind,
    Set<TrackResourceOrigin>? allowedOrigins,
  }) {
    if (resource == null) {
      return null;
    }
    if (kind != null && resource.kind != kind) {
      return null;
    }
    if (allowedOrigins != null && !allowedOrigins.contains(resource.origin)) {
      return null;
    }
    return existingFileForPath(resource.path)?.path;
  }

  /// Whether an indexed audio resource can be used by playback.
  static bool isPlayableAudioResource(
    LocalResourceEntry? resource, {
    bool requireExistingFile = false,
  }) {
    return _isAudioResourceAvailable(
      resource,
      allowedOrigins: playableAudioOrigins,
      requireExistingFile: requireExistingFile,
    );
  }

  /// Whether an indexed audio resource should be displayed as cached.
  static bool isCachedAudioResource(
    LocalResourceEntry? resource, {
    bool requireExistingFile = false,
  }) {
    return _isAudioResourceAvailable(
      resource,
      allowedOrigins: cachedAudioOrigins,
      requireExistingFile: requireExistingFile,
    );
  }

  /// Whether a resource satisfies the download queue without another request.
  static bool isDownloadSatisfiedAudioResource(LocalResourceEntry? resource) {
    return isAvailableAudioResource(
      resource,
      allowedOrigins: downloadSatisfiedAudioOrigins,
    );
  }

  /// Whether an indexed audio resource exists and has an expected origin.
  static bool isAvailableAudioResource(
    LocalResourceEntry? resource, {
    required Set<TrackResourceOrigin> allowedOrigins,
  }) {
    return _isAudioResourceAvailable(
      resource,
      allowedOrigins: allowedOrigins,
      requireExistingFile: true,
    );
  }

  /// Returns the playback URL that may be safely serialized into a queue item.
  static String? queuePlaybackUrl(
    Track track,
    TrackResourceBundle resources,
  ) {
    if (isPlayableAudioResource(resources.audio)) {
      final audioPath = localPath(resources.audio);
      if (audioPath != null) {
        return audioPath;
      }
    }
    return _emptyToNull(LocalFilePathNormalizer.normalize(track.remoteUrl));
  }

  /// Returns the queue media type implied by local resources and track source.
  static MediaType queueMediaType(
    Track track,
    TrackResourceBundle resources, {
    MediaType? fallback,
  }) {
    final playbackUrl = queuePlaybackUrl(track, resources);
    if (playbackUrl != null && isPlayableAudioResource(resources.audio)) {
      return playbackUrl.endsWith('.uc!') ? MediaType.neteaseCache : MediaType.local;
    }
    if (track.sourceType == SourceType.local) {
      return MediaType.local;
    }
    return fallback ?? MediaType.playlist;
  }

  static bool _isAudioResourceAvailable(
    LocalResourceEntry? resource, {
    required Set<TrackResourceOrigin> allowedOrigins,
    required bool requireExistingFile,
  }) {
    if (resource == null || resource.kind != LocalResourceKind.audio || !allowedOrigins.contains(resource.origin)) {
      return false;
    }
    if (requireExistingFile) {
      return existingLocalPath(
            resource,
            kind: LocalResourceKind.audio,
            allowedOrigins: allowedOrigins,
          ) !=
          null;
    }
    return localPath(resource) != null;
  }

  static String? _emptyToNull(String value) {
    return value.isEmpty ? null : value;
  }
}
