import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 播放 UI 命令服务，承接控制器转发的用户播放操作。
class PlaybackUiCommandService {
  /// 创建播放 UI 命令服务。
  PlaybackUiCommandService({
    required PlaybackService playbackService,
    required PlaybackModeCoordinator modeCoordinator,
  })  : _playbackService = playbackService,
        _modeCoordinator = modeCoordinator;

  final PlaybackService _playbackService;
  final PlaybackModeCoordinator _modeCoordinator;

  /// 根据当前播放状态执行播放或暂停。
  Future<void> playOrPause({required bool isPlaying}) {
    return isPlaying ? _playbackService.pause() : _playbackService.play();
  }

  /// 播放指定队列，并在必要时退出 FM 或心动模式。
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

  /// 播放队列中的指定索引。
  Future<void> playQueueIndex(int index) {
    return _playbackService.playIndex(audioSourceIndex: index, playNow: true);
  }

  /// 跳转到指定播放进度。
  Future<void> seekTo(Duration position) => _playbackService.seek(position);

  /// 跳到上一首。
  Future<void> skipToPreviousTrack() => _playbackService.skipToPrevious();

  /// 跳到下一首。
  Future<void> skipToNextTrack() => _playbackService.skipToNext();

  /// 设置重复播放模式。
  Future<void> setRepeatMode(PlaybackRepeatMode repeatMode) {
    return _playbackService.changeRepeatMode(newRepeatMode: repeatMode);
  }

  /// 循环切换重复播放模式。
  Future<void> cycleRepeatMode() => _playbackService.changeRepeatMode();

  /// 启动漫游模式。
  Future<bool> startRoamingMode({
    required PlaybackRepeatMode currentRepeatMode,
  }) {
    return _modeCoordinator.startRoamingMode(
      currentRepeatMode: currentRepeatMode,
    );
  }

  /// 启动心动模式。
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

  /// 播放喜欢歌曲列表。
  Future<void> playLikedSongs({
    required PlaybackQueueItem currentSong,
  }) {
    return _modeCoordinator.playLikedSongs(currentSong: currentSong);
  }

  /// 切换播放模式，并在失败时回退到普通列表模式。
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
