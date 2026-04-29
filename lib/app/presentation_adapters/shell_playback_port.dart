import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:get/get.dart';

/// Shell 访问播放展示状态的端口，避免壳层直接依赖播放控制器。
class ShellPlaybackPort {
  /// 创建 Shell 播放端口。
  const ShellPlaybackPort({
    required this.lyricState,
    required this.currentQueueIndex,
    required this.runtimeState,
    required this.isFullScreenLyricOpen,
    required this.updateFullScreenLyricTimerCounter,
    required this.playQueueIndex,
  });

  /// 当前歌词展示状态。
  final Rx<PlaybackLyricState> Function() lyricState;

  /// 当前播放队列索引。
  final RxInt Function() currentQueueIndex;

  /// 当前播放运行态快照。
  final PlaybackRuntimeState Function() runtimeState;

  /// 全屏歌词是否展开。
  final bool Function() isFullScreenLyricOpen;

  /// 更新全屏歌词自动收起计时器。
  final void Function({bool cancelTimer}) updateFullScreenLyricTimerCounter;

  /// 播放指定队列索引的歌曲。
  final Future<void> Function(int index) playQueueIndex;
}
