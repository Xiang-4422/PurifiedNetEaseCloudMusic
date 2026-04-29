import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';

/// PlaybackActionPort。
class PlaybackActionPort {
  /// 创建 PlaybackActionPort。
  const PlaybackActionPort({
    required this.playPlaylist,
    required this.playOrPause,
    required this.skipToPrevious,
    required this.skipToNext,
    required this.seekTo,
    required this.setRepeatMode,
    required this.openFmMode,
    required this.openHeartBeatMode,
    required this.currentSong,
    required this.isPlaying,
    required this.isFmMode,
    required this.isHeartBeatMode,
    required this.sessionState,
  });

  /// 播放指定队列。
  final Future<void> Function(
    List<PlaybackQueueItem> playList,
    int index, {
    String playListName,
    String playListNameHeader,
  }) playPlaylist;

  /// Function。
  final Future<void> Function() playOrPause;

  /// Function。
  final Future<void> Function() skipToPrevious;

  /// Function。
  final Future<void> Function() skipToNext;

  /// Function。
  final Future<void> Function(Duration position) seekTo;

  /// Function。
  final Future<void> Function(PlaybackRepeatMode repeatMode) setRepeatMode;

  /// Function。
  final Future<void> Function() openFmMode;

  /// 打开心动模式。
  final Future<void> Function(
    String startSongId, {
    required bool fromPlayAll,
  }) openHeartBeatMode;

  /// Function。
  final PlaybackQueueItem Function() currentSong;

  /// Function。
  final bool Function() isPlaying;

  /// Function。
  final bool Function() isFmMode;

  /// Function。
  final bool Function() isHeartBeatMode;

  /// Function。
  final PlaybackSessionState Function() sessionState;

  /// playbackMode。
  PlaybackMode get playbackMode => sessionState().playbackMode;
}
