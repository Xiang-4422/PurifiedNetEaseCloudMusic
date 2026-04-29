import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';

/// PlaybackModeCommandService。
class PlaybackModeCommandService {
  /// 创建 PlaybackModeCommandService。
  PlaybackModeCommandService({
    required PlaybackUiCommandService commandService,
    required PlaybackToastPort toastPort,
  })  : _commandService = commandService,
        _toastPort = toastPort;

  final PlaybackUiCommandService _commandService;
  final PlaybackToastPort _toastPort;

  /// quitFmMode。
  Future<void> quitFmMode({
    required PlaybackMode currentMode,
    required Future<void> Function(PlaybackMode mode) syncMode,
    bool showToast = true,
  }) async {
    if (showToast) _toastPort.show('已经退出漫游模式');
    if (currentMode == PlaybackMode.roaming) {
      await syncMode(PlaybackMode.playlist);
    }
  }

  /// quitHeartBeatMode。
  Future<void> quitHeartBeatMode({
    required PlaybackMode currentMode,
    required Future<void> Function(PlaybackMode mode) syncMode,
    bool showToast = true,
  }) async {
    if (showToast) _toastPort.show('已经退出心动模式');
    if (currentMode == PlaybackMode.heartbeat) {
      await syncMode(PlaybackMode.playlist);
    }
  }

  /// handleRepeatModeTap。
  Future<void> handleRepeatModeTap({
    required bool isFmMode,
    required bool isHeartBeatMode,
    required PlaybackSessionState sessionState,
    required PlaybackQueueItem currentSong,
    required Future<void> Function({bool showToast}) quitHeartBeatMode,
    required Future<void> Function(PlaybackRepeatMode repeatMode) setRepeatMode,
    required Future<void> Function(String startSongId,
            {required bool fromPlayAll})
        openHeartBeatMode,
  }) async {
    if (isFmMode) {
      return;
    }
    if (isHeartBeatMode) {
      await quitHeartBeatMode();
      await setRepeatMode(PlaybackRepeatMode.all);
      await _commandService.playLikedSongs(currentSong: currentSong);
      return;
    }
    if (sessionState.isPlayingLikedSongs &&
        sessionState.repeatMode == PlaybackRepeatMode.none) {
      await openHeartBeatMode(
        currentSong.id,
        fromPlayAll: false,
      );
      return;
    }
    await _commandService.cycleRepeatMode();
  }

  /// switchMode。
  Future<void> switchMode({
    required PlaybackMode currentMode,
    required PlaybackMode newMode,
    required bool isPlaying,
    required PlaybackRepeatMode currentRepeatMode,
    required Future<void> Function(PlaybackMode mode) syncMode,
    required Future<void> Function() playOrPauseWhenPaused,
    dynamic contextData,
  }) {
    return _commandService.switchMode(
      currentMode: currentMode,
      newMode: newMode,
      isPlaying: isPlaying,
      syncMode: syncMode,
      playOrPauseWhenPaused: playOrPauseWhenPaused,
      startRoaming: () => _commandService.startRoamingMode(
        currentRepeatMode: currentRepeatMode,
      ),
      startHeartBeat: (startSongId, fromPlayAll) =>
          _commandService.startHeartBeatMode(
        startSongId: startSongId,
        fromPlayAll: fromPlayAll,
        currentRepeatMode: currentRepeatMode,
      ),
      contextData: contextData,
    );
  }
}
