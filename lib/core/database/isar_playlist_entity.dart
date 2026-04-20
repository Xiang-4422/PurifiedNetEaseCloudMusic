import 'package:isar/isar.dart';

part 'isar_playlist_entity.g.dart';

@collection
class IsarPlaylistEntity {
  IsarPlaylistEntity({
    this.id = Isar.autoIncrement,
    required this.schemaVersion,
    required this.playlistId,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.description,
    this.coverUrl,
    this.trackCount,
    required this.trackRefsJson,
  });

  Id id;
  int schemaVersion;
  @Index(unique: true, replace: true)
  String playlistId;
  String sourceType;
  String sourceId;
  String title;
  String? description;
  String? coverUrl;
  int? trackCount;
  String trackRefsJson;
}
