import 'package:isar/isar.dart';

part 'isar_download_task_entity.g.dart';

@collection
class IsarDownloadTaskEntity {
  IsarDownloadTaskEntity({
    this.id = Isar.autoIncrement,
    required this.schemaVersion,
    required this.trackId,
    required this.status,
    required this.updatedAtMs,
    this.progress,
    this.localPath,
    this.artworkPath,
    this.lyricsPath,
    this.failureReason,
  });

  Id id;
  int schemaVersion;
  @Index(unique: true, replace: true)
  String trackId;
  String status;
  int updatedAtMs;
  double? progress;
  String? localPath;
  String? artworkPath;
  String? lyricsPath;
  String? failureReason;
}
