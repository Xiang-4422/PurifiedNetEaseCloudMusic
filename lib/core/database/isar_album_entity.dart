import 'package:isar/isar.dart';

part 'isar_album_entity.g.dart';

@collection
class IsarAlbumEntity {
  IsarAlbumEntity({
    this.id = Isar.autoIncrement,
    required this.schemaVersion,
    required this.albumId,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artworkUrl,
    this.artistNames = const [],
    this.description,
    this.trackCount,
    this.publishTime,
  });

  Id id;
  int schemaVersion;
  @Index(unique: true, replace: true)
  String albumId;
  String sourceType;
  String sourceId;
  String title;
  String? artworkUrl;
  List<String> artistNames;
  String? description;
  int? trackCount;
  int? publishTime;
}
