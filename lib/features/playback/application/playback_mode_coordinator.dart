import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 承接播放模式切换时需要组合用户内容和播放队列的规则。
class PlaybackModeCoordinator {
  PlaybackModeCoordinator({
    required PlaybackService playbackService,
    required PlaybackUserContentPort userContentPort,
  })  : _playbackService = playbackService,
        _userContentPort = userContentPort;

  final PlaybackService _playbackService;
  final PlaybackUserContentPort _userContentPort;

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

    await _playbackService.changePlayList(
      playList,
      index: playIndex,
      playListName: '喜欢的音乐',
      playNow: false,
      changePlayerSource: false,
    );
  }

  Future<bool> startRoamingMode({
    required AudioServiceRepeatMode currentRepeatMode,
  }) async {
    final fmSongs = await _userContentPort.loadFmSongs();
    if (fmSongs.isEmpty) {
      return false;
    }

    await _playbackService.changePlayList(
      fmSongs,
      index: 0,
      playListName: '漫游模式',
      playListNameHeader: '漫游',
      playNow: true,
      changePlayerSource: true,
      needStore: false,
    );

    if (currentRepeatMode == AudioServiceRepeatMode.one) {
      await _playbackService.changeRepeatMode(
        newRepeatMode: AudioServiceRepeatMode.all,
      );
    }
    return true;
  }

  Future<bool> startHeartBeatMode({
    required String startSongId,
    required bool fromPlayAll,
    required AudioServiceRepeatMode currentRepeatMode,
  }) async {
    final songs = await _userContentPort.loadHeartBeatSongs(
      startSongId,
      _userContentPort.randomLikedSongId(),
      fromPlayAll,
    );
    if (songs.isEmpty) {
      return false;
    }

    await _playbackService.changePlayList(
      songs,
      index: 0,
      playListName: '心动模式',
      playListNameHeader: '心动',
      playNow: true,
      changePlayerSource: true,
      needStore: false,
    );

    if (currentRepeatMode == AudioServiceRepeatMode.one) {
      await _playbackService.changeRepeatMode(
        newRepeatMode: AudioServiceRepeatMode.all,
      );
    }
    return true;
  }
}
