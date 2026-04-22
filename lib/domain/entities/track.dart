import 'source_type.dart';

enum TrackAvailability {
  unknown,
  playable,
  unavailable,
  localOnly,
}

enum DownloadState {
  none,
  queued,
  downloading,
  downloaded,
  failed,
}

enum TrackResourceOrigin {
  none,
  artworkCache,
  managedDownload,
  playbackCache,
  localImport,
}

class Track {
  static const Object _unset = Object();

  const Track({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artistNames = const [],
    this.albumTitle,
    this.durationMs,
    this.artworkUrl,
    this.remoteUrl,
    this.localPath,
    this.localArtworkPath,
    this.localLyricsPath,
    this.lyricKey,
    this.availability = TrackAvailability.unknown,
    this.downloadState = DownloadState.none,
    this.resourceOrigin = TrackResourceOrigin.none,
    this.downloadProgress,
    this.downloadFailureReason,
    this.metadata = const {},
  });

  final String id;
  final SourceType sourceType;
  final String sourceId;
  final String title;
  final List<String> artistNames;
  final String? albumTitle;
  final int? durationMs;
  final String? artworkUrl;
  final String? remoteUrl;
  final String? localPath;
  final String? localArtworkPath;
  final String? localLyricsPath;
  final String? lyricKey;
  final TrackAvailability availability;
  final DownloadState downloadState;
  final TrackResourceOrigin resourceOrigin;
  final double? downloadProgress;
  final String? downloadFailureReason;
  final Map<String, Object?> metadata;

  Track copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? title,
    List<String>? artistNames,
    Object? albumTitle = _unset,
    int? durationMs,
    Object? artworkUrl = _unset,
    Object? remoteUrl = _unset,
    Object? localPath = _unset,
    Object? localArtworkPath = _unset,
    Object? localLyricsPath = _unset,
    Object? lyricKey = _unset,
    TrackAvailability? availability,
    DownloadState? downloadState,
    TrackResourceOrigin? resourceOrigin,
    Object? downloadProgress = _unset,
    Object? downloadFailureReason = _unset,
    Map<String, Object?>? metadata,
  }) {
    return Track(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artistNames: artistNames ?? this.artistNames,
      albumTitle: identical(albumTitle, _unset)
          ? this.albumTitle
          : albumTitle as String?,
      durationMs: durationMs ?? this.durationMs,
      artworkUrl: identical(artworkUrl, _unset)
          ? this.artworkUrl
          : artworkUrl as String?,
      remoteUrl:
          identical(remoteUrl, _unset) ? this.remoteUrl : remoteUrl as String?,
      localPath:
          identical(localPath, _unset) ? this.localPath : localPath as String?,
      localArtworkPath: identical(localArtworkPath, _unset)
          ? this.localArtworkPath
          : localArtworkPath as String?,
      localLyricsPath: identical(localLyricsPath, _unset)
          ? this.localLyricsPath
          : localLyricsPath as String?,
      lyricKey:
          identical(lyricKey, _unset) ? this.lyricKey : lyricKey as String?,
      availability: availability ?? this.availability,
      downloadState: downloadState ?? this.downloadState,
      resourceOrigin: resourceOrigin ?? this.resourceOrigin,
      downloadProgress: identical(downloadProgress, _unset)
          ? this.downloadProgress
          : downloadProgress as double?,
      downloadFailureReason: identical(downloadFailureReason, _unset)
          ? this.downloadFailureReason
          : downloadFailureReason as String?,
      metadata: metadata ?? this.metadata,
    );
  }
}
