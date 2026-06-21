/// 心动模式切换所需的启动上下文。
class PlaybackHeartBeatModeContext {
  /// 创建心动模式切换上下文。
  const PlaybackHeartBeatModeContext({
    required this.startSongId,
    required this.fromPlayAll,
  });

  /// 启动心动模式使用的歌曲 id。
  final String startSongId;

  /// 是否从播放全部入口启动。
  final bool fromPlayAll;
}
