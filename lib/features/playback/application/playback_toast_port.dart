/// 播放层提示消息端口。
class PlaybackToastPort {
  /// 创建播放提示端口。
  const PlaybackToastPort({
    required this.show,
  });

  /// 展示播放相关提示消息。
  final void Function(String message) show;
}
