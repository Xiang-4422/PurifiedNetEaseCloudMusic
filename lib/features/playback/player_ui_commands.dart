part of 'player_controller.dart';

/// 播放控制器中只服务 UI 的轻量命令。
extension PlayerUiCommands on PlayerController {
  /// 返回当前重复或播放模式对应的图标。
  IconData getRepeatIcon() {
    IconData icon;
    if (playbackMode.value == PlaybackMode.roaming) {
      icon = TablerIcons.radio;
    } else if (playbackMode.value == PlaybackMode.heartbeat) {
      icon = TablerIcons.heartbeat;
    } else if (curOrderMode.value == PlaybackOrderMode.shuffle) {
      icon = TablerIcons.arrows_shuffle;
    } else {
      switch (curRepeatMode.value) {
        case PlaybackRepeatMode.one:
          icon = TablerIcons.repeat_once;
          break;
        case PlaybackRepeatMode.none:
          icon = TablerIcons.repeat_off;
          break;
        case PlaybackRepeatMode.all:
        case PlaybackRepeatMode.group:
          icon = TablerIcons.repeat;
          break;
      }
    }
    return icon;
  }

  /// 更新全屏歌词自动打开计时。
  void updateFullScreenLyricTimerCounter({bool cancelTimer = false}) {
    _lyricUiStateController.updateFullScreenLyricTimerCounter(
      isPlaying: isPlaying.value,
      setFullScreenLyricOpen: (value) => isFullScreenLyricOpen.value = value,
      cancelTimer: cancelTimer,
    );
  }
}
