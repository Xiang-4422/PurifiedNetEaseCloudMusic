import 'dart:math';

import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_action_port.dart';

/// 歌单播放入口用例。
///
/// 页面只提交用户意图；顺序、随机和点击指定歌曲的 repeat/起始索引规则统一放在这里。
class PlaylistPlaybackUseCase {
  /// 创建歌单播放用例。
  PlaylistPlaybackUseCase({required PlaybackActionPort playbackAction})
      : _playbackAction = playbackAction;

  final PlaybackActionPort _playbackAction;
  final Random _random = Random();

  /// 顺序播放整个歌单。
  Future<void> playSequential(
    List<PlaybackQueueItem> playlist, {
    required String playListName,
    String playListNameHeader = '',
  }) async {
    if (playlist.isEmpty) {
      return;
    }
    await _playbackAction.setRepeatMode(PlaybackRepeatMode.all);
    await _playbackAction.playPlaylist(
      playlist,
      0,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  /// 随机播放整个歌单。
  Future<void> playShuffle(
    List<PlaybackQueueItem> playlist, {
    required String playListName,
    String playListNameHeader = '',
  }) async {
    if (playlist.isEmpty) {
      return;
    }
    await _playbackAction.setRepeatMode(PlaybackRepeatMode.none);
    await _playbackAction.playPlaylist(
      playlist,
      _random.nextInt(playlist.length),
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  /// 播放歌单中的指定歌曲。
  Future<void> playAt(
    List<PlaybackQueueItem> playlist,
    int index, {
    String playListName = '无名歌单',
    String playListNameHeader = '',
  }) async {
    if (playlist.isEmpty) {
      return;
    }
    await _playbackAction.playPlaylist(
      playlist,
      index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }
}
