import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/playback_service.dart';

class PlaybackUiCommandService {
  PlaybackUiCommandService({
    required PlaybackService playbackService,
    required PlaybackModeCoordinator modeCoordinator,
  })  : _playbackService = playbackService,
        _modeCoordinator = modeCoordinator;

  final PlaybackService _playbackService;
  final PlaybackModeCoordinator _modeCoordinator;

  Future<void> playOrPause({required bool isPlaying}) {
    return isPlaying ? _playbackService.pause() : _playbackService.play();
  }

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

  Future<void> playQueueIndex(int index) {
    return _playbackService.playIndex(audioSourceIndex: index, playNow: true);
  }

  Future<void> seekTo(Duration position) => _playbackService.seek(position);

  Future<void> skipToPreviousTrack() => _playbackService.skipToPrevious();

  Future<void> skipToNextTrack() => _playbackService.skipToNext();

  Future<void> setRepeatMode(PlaybackRepeatMode repeatMode) {
    return _playbackService.changeRepeatMode(newRepeatMode: repeatMode);
  }

  Future<void> cycleRepeatMode() => _playbackService.changeRepeatMode();

  Future<bool> startRoamingMode({
    required PlaybackRepeatMode currentRepeatMode,
  }) {
    return _modeCoordinator.startRoamingMode(
      currentRepeatMode: currentRepeatMode,
    );
  }

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

  Future<void> playLikedSongs({
    required PlaybackQueueItem currentSong,
  }) {
    return _modeCoordinator.playLikedSongs(currentSong: currentSong);
  }

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
