import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';

/// 播放会话状态描述“当前这次播放上下文是什么”，用于收口分散的播放展示态。
///
/// 这里只承载高频且跨页面共享的会话信息，避免把歌词、进度等瞬时状态一并塞进来。
class PlaybackSessionState {
  /// 当前播放模式。
  final PlaybackMode playbackMode;

  /// 当前重复播放模式。
  final PlaybackRepeatMode repeatMode;

  /// 当前队列名称。
  final String playlistName;

  /// 当前队列标题前缀。
  final String playlistHeader;

  /// 当前队列是否是喜欢歌曲队列。
  final bool isPlayingLikedSongs;

  /// 创建播放会话状态。
  const PlaybackSessionState({
    this.playbackMode = PlaybackMode.playlist,
    this.repeatMode = PlaybackRepeatMode.all,
    this.playlistName = '',
    this.playlistHeader = '',
    this.isPlayingLikedSongs = false,
  });

  /// 复制会话状态并替换指定字段。
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
