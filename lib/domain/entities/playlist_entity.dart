import 'playlist_track_ref.dart';
import 'source_type.dart';

class PlaylistEntity {
  const PlaylistEntity({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.description,
    this.coverUrl,
    this.trackCount,
    this.trackRefs = const [],
  });

  final String id;
  final SourceType sourceType;
  final String sourceId;
  final String title;
  final String? description;
  final String? coverUrl;
  final int? trackCount;
  final List<PlaylistTrackRef> trackRefs;

  PlaylistEntity copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? title,
    String? description,
    String? coverUrl,
    int? trackCount,
    List<PlaylistTrackRef>? trackRefs,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      trackRefs: trackRefs ?? this.trackRefs,
    );
  }
}
