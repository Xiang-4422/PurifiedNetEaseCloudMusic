import 'source_type.dart';

class ArtistEntity {
  const ArtistEntity({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.name,
    this.artworkUrl,
    this.description,
  });

  final String id;
  final SourceType sourceType;
  final String sourceId;
  final String name;
  final String? artworkUrl;
  final String? description;

  ArtistEntity copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? name,
    String? artworkUrl,
    String? description,
  }) {
    return ArtistEntity(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      description: description ?? this.description,
    );
  }
}
