import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';

class PlaybackActionPort {
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

  final Future<void> Function(
    List<PlaybackQueueItem> playList,
    int index, {
    String playListName,
    String playListNameHeader,
  }) playPlaylist;
  final Future<void> Function() playOrPause;
  final Future<void> Function() skipToPrevious;
  final Future<void> Function() skipToNext;
  final Future<void> Function(Duration position) seekTo;
  final Future<void> Function(PlaybackRepeatMode repeatMode) setRepeatMode;
  final Future<void> Function() openFmMode;
  final Future<void> Function(
    String startSongId, {
    required bool fromPlayAll,
  }) openHeartBeatMode;
  final PlaybackQueueItem Function() currentSong;
  final bool Function() isPlaying;
  final bool Function() isFmMode;
  final bool Function() isHeartBeatMode;
  final PlaybackSessionState Function() sessionState;

  PlaybackMode get playbackMode => sessionState().playbackMode;
}
