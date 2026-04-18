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

class Track {
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
    this.lyricKey,
    this.availability = TrackAvailability.unknown,
    this.downloadState = DownloadState.none,
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
  final String? lyricKey;
  final TrackAvailability availability;
  final DownloadState downloadState;
  final Map<String, Object?> metadata;

  Track copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? title,
    List<String>? artistNames,
    String? albumTitle,
    int? durationMs,
    String? artworkUrl,
    String? remoteUrl,
    String? localPath,
    String? lyricKey,
    TrackAvailability? availability,
    DownloadState? downloadState,
    Map<String, Object?>? metadata,
  }) {
    return Track(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artistNames: artistNames ?? this.artistNames,
      albumTitle: albumTitle ?? this.albumTitle,
      durationMs: durationMs ?? this.durationMs,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      lyricKey: lyricKey ?? this.lyricKey,
      availability: availability ?? this.availability,
      downloadState: downloadState ?? this.downloadState,
      metadata: metadata ?? this.metadata,
    );
  }
}
