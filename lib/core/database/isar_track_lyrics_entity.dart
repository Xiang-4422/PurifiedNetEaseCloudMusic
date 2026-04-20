import 'package:isar/isar.dart';

part 'isar_track_lyrics_entity.g.dart';

@collection
class IsarTrackLyricsEntity {
  IsarTrackLyricsEntity({
    this.id = Isar.autoIncrement,
    required this.schemaVersion,
    required this.trackId,
    required this.main,
    required this.translated,
  });

  Id id;
  int schemaVersion;
  @Index(unique: true, replace: true)
  String trackId;
  String main;
  String translated;
}
