import 'package:isar/isar.dart';

part 'isar_artist_entity.g.dart';

@collection
class IsarArtistEntity {
  IsarArtistEntity({
    this.id = Isar.autoIncrement,
    required this.schemaVersion,
    required this.artistId,
    required this.sourceType,
    required this.sourceId,
    required this.name,
    this.artworkUrl,
    this.description,
  });

  Id id;
  int schemaVersion;
  @Index(unique: true, replace: true)
  String artistId;
  String sourceType;
  String sourceId;
  String name;
  String? artworkUrl;
  String? description;
}
