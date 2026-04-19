import 'package:audio_service/audio_service.dart';

/// 运行时播放状态描述“播放器此刻正在播放什么、队列在哪、进度到哪”。
///
/// 歌词、取色和面板展示动画仍保持独立，因为它们更新频率更高，也更偏视图层。
/// 这里先收口跨页面最常用的运行态，避免继续在控制器里分散维护多组 Rx 字段。
class PlaybackRuntimeState {
  final List<MediaItem> queue;
  final MediaItem currentSong;
  final int currentIndex;
  final Duration currentPosition;

  const PlaybackRuntimeState({
    this.queue = const <MediaItem>[],
    this.currentSong = const MediaItem(
      id: '',
      title: '暂无',
      duration: Duration(seconds: 10),
    ),
    this.currentIndex = 0,
    this.currentPosition = Duration.zero,
  });

  PlaybackRuntimeState copyWith({
    List<MediaItem>? queue,
    MediaItem? currentSong,
    int? currentIndex,
    Duration? currentPosition,
  }) {
    return PlaybackRuntimeState(
      queue: queue ?? this.queue,
      currentSong: currentSong ?? this.currentSong,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
