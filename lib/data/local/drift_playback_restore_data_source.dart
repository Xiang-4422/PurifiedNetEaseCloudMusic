import 'dart:convert';

import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/core/database/drift_database.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/domain/entities/playback_restore_state.dart';
import 'package:drift/drift.dart' as drift;

import 'playback_restore_data_source.dart';

/// Drift 实现的播放恢复数据源。
class DriftPlaybackRestoreDataSource implements PlaybackRestoreDataSource {
  /// 创建 Drift 播放恢复数据源。
  DriftPlaybackRestoreDataSource({required BujuanDriftDatabase database})
      : _database = database;

  final BujuanDriftDatabase _database;

  @override
  Future<PlaybackRestoreState?> getRestoreState() async {
    final row = await (_database.select(_database.playbackRestoreSnapshots)
          ..where((tbl) => tbl.id.equals(0)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final queue = (jsonDecode(row.queueJson) as List?)?.cast<String>() ??
        const <String>[];
    return PlaybackRestoreState(
      playbackMode: PlaybackMode.values.firstWhere(
        (item) => item.name == row.playbackMode,
        orElse: () => PlaybackMode.playlist,
      ),
      repeatMode: PlaybackRepeatMode.values.firstWhere(
        (item) => item.name == row.repeatMode,
        orElse: () => PlaybackRepeatMode.all,
      ),
      queue: queue,
      currentSongId: row.currentSongId,
      playlistName: row.playlistName,
      playlistHeader: row.playlistHeader,
      position: Duration(milliseconds: row.positionMs),
    );
  }

  @override
  Future<void> saveRestoreState(PlaybackRestoreState state) {
    return _database
        .into(_database.playbackRestoreSnapshots)
        .insertOnConflictUpdate(
          PlaybackRestoreSnapshotsCompanion(
            id: const drift.Value(0),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
            playbackMode: drift.Value(state.playbackMode.name),
            repeatMode: drift.Value(state.repeatMode.name),
            queueJson: drift.Value(jsonEncode(state.queue)),
            currentSongId: drift.Value(state.currentSongId),
            playlistName: drift.Value(state.playlistName),
            playlistHeader: drift.Value(state.playlistHeader),
            positionMs: drift.Value(state.position.inMilliseconds),
          ),
        );
  }
}
