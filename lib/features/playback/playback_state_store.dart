import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/key.dart' as key;
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

class PlaybackStateStore {
  const PlaybackStateStore();

  PlaybackRestoreState get restoreState => PlaybackRestoreState(
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

  Future<void> saveCurrentSongId(String songId) {
    return CacheBox.instance.put(curPlaySongId, songId);
  }

  Future<void> savePlaybackMode(PlaybackMode playbackMode) async {
    await CacheBox.instance.put(fmSp, playbackMode == PlaybackMode.roaming);
    await CacheBox.instance
        .put(heartBeatSp, playbackMode == PlaybackMode.heartbeat);
  }

  Future<void> saveRepeatMode(AudioServiceRepeatMode repeatMode) {
    return CacheBox.instance.put(repeatModeSp, repeatMode.name);
  }

  Future<void> savePlaylistMeta({
    required String playlistName,
    required String playlistHeader,
  }) async {
    await CacheBox.instance.put(key.playListName, playlistName);
    await CacheBox.instance.put(key.playListNameHeader, playlistHeader);
  }

  Future<void> saveQueue(List<String> queue) {
    return CacheBox.instance.put(playQueue, queue);
  }

  Future<void> savePlaybackPosition(Duration position) {
    return CacheBox.instance.put(playPosition, position.inMilliseconds);
  }

  // 现有歌词缓存 key 已经散落在多个版本里，先保持 key 兼容，
  // 避免重构存储入口时把旧缓存全部打失效。
  String lyricKey(String songId) => 'lyric_$songId';

  String lyricTranslationKey(String songId) => 'lyricTran_$songId';

  String? getLyric(String songId) {
    return CacheBox.instance.get(lyricKey(songId));
  }

  String? getTranslatedLyric(String songId) {
    return CacheBox.instance.get(lyricTranslationKey(songId));
  }

  Future<void> saveLyrics({
    required String songId,
    required String lyric,
    required String translatedLyric,
  }) async {
    await CacheBox.instance.put(lyricKey(songId), lyric);
    await CacheBox.instance.put(lyricTranslationKey(songId), translatedLyric);
  }
}
