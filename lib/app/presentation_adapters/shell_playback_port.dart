import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:get/get.dart';

class ShellPlaybackPort {
  const ShellPlaybackPort({
    required this.lyricState,
    required this.currentQueueIndex,
    required this.runtimeState,
    required this.isFullScreenLyricOpen,
    required this.updateFullScreenLyricTimerCounter,
    required this.playQueueIndex,
  });

  final Rx<PlaybackLyricState> Function() lyricState;
  final RxInt Function() currentQueueIndex;
  final PlaybackRuntimeState Function() runtimeState;
  final bool Function() isFullScreenLyricOpen;
  final void Function({bool cancelTimer}) updateFullScreenLyricTimerCounter;
  final Future<void> Function(int index) playQueueIndex;
}
