import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

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
    return PlaybackRestoreState.fromJson(
      jsonDecode(snapshotJson!) as Map<String, Object?>,
    );
  }

  @override
  Future<void> saveRestoreState(PlaybackRestoreState state) {
    return CacheBox.instance.put(
      playbackRestoreSnapshotSp,
      jsonEncode(state.toJson()),
    );
  }
}
