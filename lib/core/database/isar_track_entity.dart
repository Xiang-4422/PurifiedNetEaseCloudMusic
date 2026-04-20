import 'package:isar/isar.dart';

part 'isar_track_entity.g.dart';

@collection
class IsarTrackEntity {
  IsarTrackEntity({
    this.id = Isar.autoIncrement,
    required this.schemaVersion,
    required this.trackId,
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
    required this.availability,
    required this.downloadState,
    required this.resourceOrigin,
    this.downloadProgress,
    this.downloadFailureReason,
    required this.metadataJson,
  });

  Id id;
  int schemaVersion;
  @Index(unique: true, replace: true)
  String trackId;
  String sourceType;
  String sourceId;
  String title;
  List<String> artistNames;
  String? albumTitle;
  int? durationMs;
  String? artworkUrl;
  String? remoteUrl;
  String? localPath;
  String? localArtworkPath;
  String? localLyricsPath;
  String? lyricKey;
  String availability;
  String downloadState;
  String resourceOrigin;
  double? downloadProgress;
  String? downloadFailureReason;
  String metadataJson;
}
