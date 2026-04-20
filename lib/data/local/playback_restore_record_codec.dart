import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/core/database/isar_playback_restore_snapshot_entity.dart';
import 'package:bujuan/core/database/playback_restore_snapshot_record.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

class PlaybackRestoreRecordCodec {
  const PlaybackRestoreRecordCodec._();

  static const int schemaVersion = 1;

  static PlaybackRestoreSnapshotRecord encode(PlaybackRestoreState state) {
    return PlaybackRestoreSnapshotRecord(
      schemaVersion: schemaVersion,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      playbackMode: state.playbackMode.name,
      repeatMode: state.repeatMode.name,
      queue: state.queue,
      currentSongId: state.currentSongId,
      playlistName: state.playlistName,
      playlistHeader: state.playlistHeader,
      positionMs: state.position.inMilliseconds,
    );
  }

  static IsarPlaybackRestoreSnapshotEntity encodeEntity(
    PlaybackRestoreState state,
  ) {
    return IsarPlaybackRestoreSnapshotEntity(
      schemaVersion: schemaVersion,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      playbackMode: state.playbackMode.name,
      repeatMode: state.repeatMode.name,
      queue: state.queue,
      currentSongId: state.currentSongId,
      playlistName: state.playlistName,
      playlistHeader: state.playlistHeader,
      positionMs: state.position.inMilliseconds,
    );
  }

  static PlaybackRestoreState decode(PlaybackRestoreSnapshotRecord record) {
    return PlaybackRestoreState(
      playbackMode: PlaybackMode.values.firstWhere(
        (item) => item.name == record.playbackMode,
        orElse: () => PlaybackMode.playlist,
      ),
      repeatMode: AudioServiceRepeatMode.values.firstWhere(
        (item) => item.name == record.repeatMode,
        orElse: () => AudioServiceRepeatMode.all,
      ),
      queue: record.queue,
      currentSongId: record.currentSongId,
      playlistName: record.playlistName,
      playlistHeader: record.playlistHeader,
      position: Duration(milliseconds: record.positionMs),
    );
  }

  static PlaybackRestoreState decodeEntity(
    IsarPlaybackRestoreSnapshotEntity entity,
  ) {
    return PlaybackRestoreState(
      playbackMode: PlaybackMode.values.firstWhere(
        (item) => item.name == entity.playbackMode,
        orElse: () => PlaybackMode.playlist,
      ),
      repeatMode: AudioServiceRepeatMode.values.firstWhere(
        (item) => item.name == entity.repeatMode,
        orElse: () => AudioServiceRepeatMode.all,
      ),
      queue: entity.queue,
      currentSongId: entity.currentSongId,
      playlistName: entity.playlistName,
      playlistHeader: entity.playlistHeader,
      position: Duration(milliseconds: entity.positionMs),
    );
  }
}
