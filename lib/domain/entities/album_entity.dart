import 'source_type.dart';

class AlbumEntity {
  const AlbumEntity({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artworkUrl,
    this.artistNames = const [],
    this.description,
    this.trackCount,
    this.publishTime,
  });

  final String id;
  final SourceType sourceType;
  final String sourceId;
  final String title;
  final String? artworkUrl;
  final List<String> artistNames;
  final String? description;
  final int? trackCount;
  final int? publishTime;

  AlbumEntity copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? title,
    String? artworkUrl,
    List<String>? artistNames,
    String? description,
    int? trackCount,
    int? publishTime,
  }) {
    return AlbumEntity(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      artistNames: artistNames ?? this.artistNames,
      description: description ?? this.description,
      trackCount: trackCount ?? this.trackCount,
      publishTime: publishTime ?? this.publishTime,
    );
  }
}
