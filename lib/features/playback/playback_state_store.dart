import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

class PlaybackStateStore {
  const PlaybackStateStore();

  PlaybackRestoreState get restoreState {
    final snapshotJson =
        CacheBox.instance.get(playbackRestoreSnapshotSp) as String?;
    if ((snapshotJson ?? '').isEmpty) {
      return const PlaybackRestoreState();
    }
    return PlaybackRestoreState.fromJson(
      jsonDecode(snapshotJson!) as Map<String, Object?>,
    );
  }

  Future<void> saveRestoreState(PlaybackRestoreState state) {
    return CacheBox.instance.put(
      playbackRestoreSnapshotSp,
      jsonEncode(state.toJson()),
    );
  }

  /// 恢复态仍暂留在轻存储里，但写入口先统一到一个方法，
  /// 这样后续迁正式本地库时不需要再从多个调用点重新拼装恢复快照。
  Future<void> updateRestoreState({
    PlaybackMode? playbackMode,
    AudioServiceRepeatMode? repeatMode,
    List<String>? queue,
    String? currentSongId,
    String? playlistName,
    String? playlistHeader,
    Duration? position,
  }) async {
    final nextState = restoreState.copyWith(
      playbackMode: playbackMode,
      repeatMode: repeatMode,
      queue: queue,
      currentSongId: currentSongId,
      playlistName: playlistName,
      playlistHeader: playlistHeader,
      position: position,
    );
    await saveRestoreState(nextState);
  }
}
