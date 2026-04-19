import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

class PlaybackStateStore {
  const PlaybackStateStore();

  PlaybackRestoreState get restoreState {
    final snapshotJson =
        CacheBox.instance.get(playbackRestoreSnapshotSp) as String?;
    if ((snapshotJson ?? '').isNotEmpty) {
      return PlaybackRestoreState.fromJson(
        jsonDecode(snapshotJson!) as Map<String, Object?>,
      );
    }
    return PlaybackRestoreState(
      playbackMode: isFmModeEnabled
          ? PlaybackMode.roaming
          : isHeartBeatModeEnabled
              ? PlaybackMode.heartbeat
              : PlaybackMode.playlist,
      repeatMode: AudioServiceRepeatMode.values.firstWhere(
        (element) => element.name == repeatModeName,
        orElse: () => AudioServiceRepeatMode.all,
      ),
      queue: storedQueue,
      currentSongId: currentSongId,
      playlistName: storedPlaylistName,
      playlistHeader: storedPlaylistHeader,
      position: storedPosition,
    );
  }

  bool get isFmModeEnabled =>
      CacheBox.instance.get(fmSp, defaultValue: false) ?? false;

  bool get isHeartBeatModeEnabled =>
      CacheBox.instance.get(heartBeatSp, defaultValue: false) ?? false;

  String get repeatModeName =>
      CacheBox.instance.get(repeatModeSp, defaultValue: 'all') ?? 'all';

  List<String> get storedQueue =>
      CacheBox.instance
          .get(playQueue, defaultValue: <String>[])?.cast<String>() ??
      <String>[];

  String get currentSongId =>
      CacheBox.instance.get(curPlaySongId, defaultValue: '') ?? '';

  String get storedPlaylistName =>
      CacheBox.instance.get(playListName, defaultValue: '') ?? '';

  String get storedPlaylistHeader =>
      CacheBox.instance.get(playListNameHeader, defaultValue: '') ?? '';

  Duration get storedPosition => Duration(
      milliseconds: CacheBox.instance.get(playPosition, defaultValue: 0) ?? 0);

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
    await CacheBox.instance.put(
      playbackRestoreSnapshotSp,
      jsonEncode(nextState.toJson()),
    );
  }

  // 旧歌词缓存曾直接挂在轻存储里，这里只保留一次性迁移读取，
  // 避免现有用户在切换到媒体库存储后立即丢掉已缓存歌词。
  TrackLyrics? getLegacyLyrics(String songId) {
    final lyric = CacheBox.instance.get('lyric_$songId') as String?;
    final translatedLyric =
        CacheBox.instance.get('lyricTran_$songId') as String?;
    if ((lyric ?? '').isEmpty && (translatedLyric ?? '').isEmpty) {
      return null;
    }
    return TrackLyrics(
      main: lyric ?? '',
      translated: translatedLyric ?? '',
    );
  }
}
