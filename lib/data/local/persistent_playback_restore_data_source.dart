import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/database/playback_restore_snapshot_record.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

import 'playback_restore_record_codec.dart';
import 'playback_restore_data_source.dart';

class PersistentPlaybackRestoreDataSource
    implements PlaybackRestoreDataSource {
  const PersistentPlaybackRestoreDataSource();

  @override
  Future<PlaybackRestoreState?> getRestoreState() async {
    final snapshotJson =
        CacheBox.instance.get(playbackRestoreSnapshotSp) as String?;
    if ((snapshotJson ?? '').isEmpty) {
      return null;
    }
    final record = PlaybackRestoreSnapshotRecord.fromMap(
      jsonDecode(snapshotJson!) as Map<String, Object?>,
    );
    return PlaybackRestoreRecordCodec.decode(record);
  }

  @override
  Future<void> saveRestoreState(PlaybackRestoreState state) {
    final record = PlaybackRestoreRecordCodec.encode(state);
    return CacheBox.instance.put(
      playbackRestoreSnapshotSp,
      jsonEncode(record.toMap()),
    );
  }
}
