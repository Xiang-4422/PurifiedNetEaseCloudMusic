import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';

/// 播放会话状态描述“当前这次播放上下文是什么”，用于收口分散的播放展示态。
///
/// 这里只承载高频且跨页面共享的会话信息，避免把歌词、进度等瞬时状态一并塞进来。
class PlaybackSessionState {
  final PlaybackMode playbackMode;
  final PlaybackRepeatMode repeatMode;
  final String playlistName;
  final String playlistHeader;
  final bool isPlayingLikedSongs;

  const PlaybackSessionState({
    this.playbackMode = PlaybackMode.playlist,
    this.repeatMode = PlaybackRepeatMode.all,
    this.playlistName = '',
    this.playlistHeader = '',
    this.isPlayingLikedSongs = false,
  });

  PlaybackSessionState copyWith({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
    String? playlistName,
    String? playlistHeader,
    bool? isPlayingLikedSongs,
  }) {
    return PlaybackSessionState(
      playbackMode: playbackMode ?? this.playbackMode,
      repeatMode: repeatMode ?? this.repeatMode,
      playlistName: playlistName ?? this.playlistName,
      playlistHeader: playlistHeader ?? this.playlistHeader,
      isPlayingLikedSongs: isPlayingLikedSongs ?? this.isPlayingLikedSongs,
    );
  }
}
