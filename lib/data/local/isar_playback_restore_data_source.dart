import 'package:bujuan/core/database/isar_playback_restore_snapshot_entity.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';
import 'package:isar/isar.dart';

import 'playback_restore_data_source.dart';
import 'playback_restore_record_codec.dart';

class IsarPlaybackRestoreDataSource implements PlaybackRestoreDataSource {
  IsarPlaybackRestoreDataSource({required Isar isar}) : _isar = isar;

  final Isar _isar;

  @override
  Future<PlaybackRestoreState?> getRestoreState() async {
    final entity = await _isar.isarPlaybackRestoreSnapshotEntitys.get(0);
    if (entity == null) {
      return null;
    }
    return PlaybackRestoreRecordCodec.decodeEntity(entity);
  }

  @override
  Future<void> saveRestoreState(PlaybackRestoreState state) async {
    final entity = PlaybackRestoreRecordCodec.encodeEntity(state);
    await _isar.writeTxn(() async {
      await _isar.isarPlaybackRestoreSnapshotEntitys.put(entity);
    });
  }
}
