import 'source_type.dart';

enum TrackAvailability {
  unknown,
  playable,
  unavailable,
  localOnly,
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
    this.lyricKey,
    this.availability = TrackAvailability.unknown,
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
  final String? lyricKey;
  final TrackAvailability availability;
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
    Object? lyricKey = _unset,
    TrackAvailability? availability,
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
      lyricKey:
          identical(lyricKey, _unset) ? this.lyricKey : lyricKey as String?,
      availability: availability ?? this.availability,
      metadata: metadata ?? this.metadata,
    );
  }
}
