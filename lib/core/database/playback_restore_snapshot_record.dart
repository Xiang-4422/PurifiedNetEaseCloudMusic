class PlaybackRestoreSnapshotRecord {
  const PlaybackRestoreSnapshotRecord({
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

  final int schemaVersion;
  final int updatedAtMs;
  final String playbackMode;
  final String repeatMode;
  final List<String> queue;
  final String currentSongId;
  final String playlistName;
  final String playlistHeader;
  final int positionMs;

  Map<String, Object?> toMap() {
    return {
      'schemaVersion': schemaVersion,
      'updatedAtMs': updatedAtMs,
      'playbackMode': playbackMode,
      'repeatMode': repeatMode,
      'queue': queue,
      'currentSongId': currentSongId,
      'playlistName': playlistName,
      'playlistHeader': playlistHeader,
      'positionMs': positionMs,
    };
  }

  factory PlaybackRestoreSnapshotRecord.fromMap(Map<String, Object?> map) {
    return PlaybackRestoreSnapshotRecord(
      schemaVersion: map['schemaVersion'] as int? ?? 1,
      updatedAtMs: map['updatedAtMs'] as int? ?? 0,
      playbackMode: map['playbackMode'] as String? ?? '',
      repeatMode: map['repeatMode'] as String? ?? '',
      queue: (map['queue'] as List?)?.cast<String>() ?? const <String>[],
      currentSongId: map['currentSongId'] as String? ?? '',
      playlistName: map['playlistName'] as String? ?? '',
      playlistHeader: map['playlistHeader'] as String? ?? '',
      positionMs: map['positionMs'] as int? ?? 0,
    );
  }
}
