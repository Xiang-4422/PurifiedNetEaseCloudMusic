import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';

/// 播放动作端口，供非播放 feature 触发播放并读取最小播放态。
class PlaybackActionPort {
  /// 创建播放动作端口。
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

  /// 播放或暂停当前歌曲。
  final Future<void> Function() playOrPause;

  /// 跳到上一首。
  final Future<void> Function() skipToPrevious;

  /// 跳到下一首。
  final Future<void> Function() skipToNext;

  /// 跳转到指定播放进度。
  final Future<void> Function(Duration position) seekTo;

  /// 设置重复播放模式。
  final Future<void> Function(PlaybackRepeatMode repeatMode) setRepeatMode;

  /// 打开私人 FM 模式。
  final Future<void> Function() openFmMode;

  /// 打开心动模式。
  final Future<void> Function(
    String startSongId, {
    required bool fromPlayAll,
  }) openHeartBeatMode;

  /// 当前播放歌曲。
  final PlaybackQueueItem Function() currentSong;

  /// 当前是否正在播放。
  final bool Function() isPlaying;

  /// 当前是否是私人 FM 模式。
  final bool Function() isFmMode;

  /// 当前是否是心动模式。
  final bool Function() isHeartBeatMode;

  /// 当前播放会话状态。
  final PlaybackSessionState Function() sessionState;

  /// 当前播放模式。
  PlaybackMode get playbackMode => sessionState().playbackMode;
}
