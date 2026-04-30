import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 承接播放模式切换时需要组合用户内容和播放队列的规则。
class PlaybackModeCoordinator {
  /// 创建播放模式协调器。
  PlaybackModeCoordinator({
    required PlaybackService playbackService,
    required PlaybackUserContentPort userContentPort,
    required PlaybackSelectionService selectionService,
  })  : _playbackService = playbackService,
        _userContentPort = userContentPort,
        _selectionService = selectionService;

  final PlaybackService _playbackService;
  final PlaybackUserContentPort _userContentPort;
  final PlaybackSelectionService _selectionService;

  /// 构建并切换到喜欢歌曲播放队列。
  Future<void> playLikedSongs({
    required PlaybackQueueItem currentSong,
  }) async {
    await _userContentPort.ensureLikedSongsLoaded();
    final likedSongs = _userContentPort.likedSongs();
    final likedSongIds = _userContentPort.likedSongIds();
    int playIndex;
    final playList = [...likedSongs];
    if (likedSongIds.contains(int.tryParse(currentSong.sourceId))) {
      playIndex = likedSongs.indexWhere((song) => song.id == currentSong.id);
    } else {
      playIndex = 0;
      playList.insert(0, currentSong);
    }

    await _selectionService.selectQueue(
      playList,
      playIndex,
      playListName: '喜欢的音乐',
      trigger: PlaybackSwitchTrigger.userSelect,
      playNow: false,
    );
  }

  /// 加载 FM 候选歌曲并进入漫游模式。
  Future<bool> startRoamingMode({
    required PlaybackRepeatMode currentRepeatMode,
  }) async {
    final fmSongs = await _userContentPort.loadFmSongs();
    if (fmSongs.isEmpty) {
      return false;
    }

    await _selectionService.selectQueue(
      fmSongs,
      0,
      playListName: '漫游模式',
      playListNameHeader: '漫游',
      trigger: PlaybackSwitchTrigger.modeAutoAdvance,
      playNow: true,
      needStore: false,
    );

    if (currentRepeatMode == PlaybackRepeatMode.one) {
      await _playbackService.changeRepeatMode(
        newRepeatMode: PlaybackRepeatMode.all,
      );
    }
    return true;
  }

  /// 加载心动模式歌曲并切换播放队列。
  Future<bool> startHeartBeatMode({
    required String startSongId,
    required bool fromPlayAll,
    required PlaybackRepeatMode currentRepeatMode,
  }) async {
    final songs = await _userContentPort.loadHeartBeatSongs(
      startSongId,
      _userContentPort.randomLikedSongId(),
      fromPlayAll,
    );
    if (songs.isEmpty) {
      return false;
    }

    await _selectionService.selectQueue(
      songs,
      0,
      playListName: '心动模式',
      playListNameHeader: '心动',
      trigger: PlaybackSwitchTrigger.modeAutoAdvance,
      playNow: true,
      needStore: false,
    );

    if (currentRepeatMode == PlaybackRepeatMode.one) {
      await _playbackService.changeRepeatMode(
        newRepeatMode: PlaybackRepeatMode.all,
      );
    }
    return true;
  }
}
