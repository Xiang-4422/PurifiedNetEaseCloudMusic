import 'package:isar/isar.dart';

part 'isar_playback_restore_snapshot_entity.g.dart';

@collection
class IsarPlaybackRestoreSnapshotEntity {
  IsarPlaybackRestoreSnapshotEntity({
    this.id = 0,
    required this.schemaVersion,
    required this.updatedAtMs,
    required this.playbackMode,
    required this.repeatMode,
    required this.queue,
    required this.currentSongId,
    required this.playlistName,
    required this.playlistHeader,
    required this.positionMs,
  });

  Id id;
  int schemaVersion;
  int updatedAtMs;
  String playbackMode;
  String repeatMode;
  List<String> queue;
  String currentSongId;
  String playlistName;
  String playlistHeader;
  int positionMs;
}
