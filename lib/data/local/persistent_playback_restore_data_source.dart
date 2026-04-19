import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/database/playback_restore_snapshot_record.dart';
import 'package:bujuan/core/storage/cache_box_storage_adapter.dart';
import 'package:bujuan/core/storage/key_value_storage_adapter.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

import 'playback_restore_record_codec.dart';
import 'playback_restore_data_source.dart';

class PersistentPlaybackRestoreDataSource
    implements PlaybackRestoreDataSource {
  PersistentPlaybackRestoreDataSource({
    KeyValueStorageAdapter? storageAdapter,
  }) : _storageAdapter = storageAdapter ?? const CacheBoxStorageAdapter();

  final KeyValueStorageAdapter _storageAdapter;

  @override
  Future<PlaybackRestoreState?> getRestoreState() async {
    final snapshotJson = _storageAdapter.get<String>(playbackRestoreSnapshotSp);
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
    return _storageAdapter.put(
      playbackRestoreSnapshotSp,
      jsonEncode(record.toMap()),
    );
  }
}
