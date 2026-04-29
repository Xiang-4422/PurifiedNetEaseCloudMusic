import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// PlaybackUiCommandService。
class PlaybackUiCommandService {
  /// 创建 PlaybackUiCommandService。
  PlaybackUiCommandService({
    required PlaybackService playbackService,
    required PlaybackModeCoordinator modeCoordinator,
  })  : _playbackService = playbackService,
        _modeCoordinator = modeCoordinator;

  final PlaybackService _playbackService;
  final PlaybackModeCoordinator _modeCoordinator;

  /// playOrPause。
  Future<void> playOrPause({required bool isPlaying}) {
    return isPlaying ? _playbackService.pause() : _playbackService.play();
  }

  /// playPlaylist。
  Future<void> playPlaylist(
    List<PlaybackQueueItem> playList,
    int index, {
    required String playListName,
    String playListNameHeader = '',
    required bool isFmMode,
    required bool isHeartBeatMode,
    required Future<void> Function({bool showToast}) quitFmMode,
    required Future<void> Function({bool showToast}) quitHeartBeatMode,
  }) async {
    if (isFmMode) {
      await quitFmMode(showToast: false);
    }
    if (isHeartBeatMode) {
      await quitHeartBeatMode(showToast: false);
    }
    await _playbackService.playPlaylist(
      playList,
      index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  /// playQueueIndex。
  Future<void> playQueueIndex(int index) {
    return _playbackService.playIndex(audioSourceIndex: index, playNow: true);
  }

  /// seekTo。
  Future<void> seekTo(Duration position) => _playbackService.seek(position);

  /// skipToPreviousTrack。
  Future<void> skipToPreviousTrack() => _playbackService.skipToPrevious();

  /// skipToNextTrack。
  Future<void> skipToNextTrack() => _playbackService.skipToNext();

  /// setRepeatMode。
  Future<void> setRepeatMode(PlaybackRepeatMode repeatMode) {
    return _playbackService.changeRepeatMode(newRepeatMode: repeatMode);
  }

  /// cycleRepeatMode。
  Future<void> cycleRepeatMode() => _playbackService.changeRepeatMode();

  /// startRoamingMode。
  Future<bool> startRoamingMode({
    required PlaybackRepeatMode currentRepeatMode,
  }) {
    return _modeCoordinator.startRoamingMode(
      currentRepeatMode: currentRepeatMode,
    );
  }

  /// startHeartBeatMode。
  Future<bool> startHeartBeatMode({
    required String startSongId,
    required bool fromPlayAll,
    required PlaybackRepeatMode currentRepeatMode,
  }) {
    return _modeCoordinator.startHeartBeatMode(
      startSongId: startSongId,
      fromPlayAll: fromPlayAll,
      currentRepeatMode: currentRepeatMode,
    );
  }

  /// playLikedSongs。
  Future<void> playLikedSongs({
    required PlaybackQueueItem currentSong,
  }) {
    return _modeCoordinator.playLikedSongs(currentSong: currentSong);
  }

  /// switchMode。
  Future<void> switchMode({
    required PlaybackMode currentMode,
    required PlaybackMode newMode,
    required bool isPlaying,
    required Future<void> Function(PlaybackMode mode) syncMode,
    required Future<void> Function() playOrPauseWhenPaused,
    required Future<bool> Function() startRoaming,
    required Future<bool> Function(String startSongId, bool fromPlayAll)
        startHeartBeat,
    dynamic contextData,
  }) async {
    if (currentMode == newMode && newMode != PlaybackMode.playlist) {
      if (!isPlaying) {
        await playOrPauseWhenPaused();
      }
      return;
    }

    await syncMode(newMode);

    switch (newMode) {
      case PlaybackMode.roaming:
        if (!await startRoaming()) {
          await syncMode(PlaybackMode.playlist);
        }
        break;
      case PlaybackMode.heartbeat:
        if (contextData is Map && contextData.containsKey('startSongId')) {
          final started = await startHeartBeat(
            contextData['startSongId'] as String,
            contextData['fromPlayAll'] as bool? ?? true,
          );
          if (!started) {
            await syncMode(PlaybackMode.playlist);
          }
        }
        break;
      case PlaybackMode.playlist:
        break;
    }
  }
}
