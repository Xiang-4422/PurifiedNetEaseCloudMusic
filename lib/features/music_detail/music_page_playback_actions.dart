import 'dart:math';

import 'package:bujuan/core/entities/playback_order_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/player_controller.dart';

/// 打开播放面板的页面动作。
typedef PlaybackPanelOpener = void Function();

/// 详情类音乐页面的播放动作边界。
class MusicPagePlaybackActions {
  /// 创建详情页播放动作边界。
  MusicPagePlaybackActions({
    required PlayerController playerController,
    required PlaybackPanelOpener openPlaybackPanel,
    Random? random,
  })  : _playerController = playerController,
        _openPlaybackPanel = openPlaybackPanel,
        _random = random ?? Random();

  final PlayerController _playerController;
  final PlaybackPanelOpener _openPlaybackPanel;
  final Random _random;

  /// 播放指定队列项。
  Future<void> playPlaylist(
    List<PlaybackQueueItem> playList,
    int index, {
    String playListName = '无名歌单',
    String playListNameHeader = '',
  }) async {
    if (!_canPlayIndex(playList, index)) {
      return;
    }
    await _playerController.playPlaylist(
      playList,
      index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  /// 打开播放面板并播放指定队列项。
  Future<void> playPlaylistAndOpenPanel(
    List<PlaybackQueueItem> playList,
    int index, {
    String playListName = '无名歌单',
    String playListNameHeader = '',
  }) async {
    if (!_canPlayIndex(playList, index)) {
      return;
    }
    _openPlaybackPanel();
    await playPlaylist(
      playList,
      index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  /// 按顺序播放完整队列。
  Future<void> playSequentialPlaylist(
    List<PlaybackQueueItem> playList, {
    required String playListName,
    String playListNameHeader = '',
  }) async {
    if (playList.isEmpty) {
      return;
    }
    _openPlaybackPanel();
    await _playerController.setOrderMode(PlaybackOrderMode.sequential);
    await _playerController.setRepeatMode(PlaybackRepeatMode.all);
    await playPlaylist(
      playList,
      0,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  /// 随机播放完整队列。
  Future<void> playShuffledPlaylist(
    List<PlaybackQueueItem> playList, {
    required String playListName,
    String playListNameHeader = '',
  }) async {
    if (playList.isEmpty) {
      return;
    }
    _openPlaybackPanel();
    await _playerController.setOrderMode(PlaybackOrderMode.shuffle);
    await _playerController.setRepeatMode(PlaybackRepeatMode.all);
    await playPlaylist(
      playList,
      _random.nextInt(playList.length),
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  bool _canPlayIndex(List<PlaybackQueueItem> playList, int index) {
    return playList.isNotEmpty && index >= 0 && index < playList.length;
  }
}
