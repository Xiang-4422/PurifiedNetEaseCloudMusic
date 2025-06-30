import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/home/app_controller.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_player_handler.dart';
import 'constants/key.dart';
import 'constants/platform_utils.dart';
import 'netease_api/src/api/play/bean.dart';
import 'netease_api/src/netease_api.dart';

class BujuanAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler{

  late final AudioPlayer _player;

  /// 当前原始播放列表（用于随机和顺序播放模式切换用）
  final List<MediaItem> _originalPlayList = <MediaItem>[];
  /// 播放列表索引（当前播放对应在正在播放的列表索引）
  int _curIndex = -1;
  /// 播放模式（none表示随机模式）
  AudioServiceRepeatMode _curRepeatMode = AudioServiceRepeatMode.all;

  BujuanAudioHandler() {
    _player = AudioPlayer()
      ..playbackEventStream.listen((PlaybackEvent event) {
      // 监听并映射播放器状态
      playbackState.add(playbackState.value.copyWith(
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [1, 2, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        shuffleMode: (_player.shuffleModeEnabled) ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _curIndex,
      ));
    });
    _updateMediaControls();
  }

  /// 更新状态栏控制按钮
  _updateMediaControls() {
    bool isLiked = mediaItem.value?.extras?['liked'] ?? false;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        PlatformUtils.isAndroid
            ? MediaControl(label: 'rewind', action: MediaAction.rewind, androidIcon: isLiked ?'drawable/audio_service_like' : 'drawable/audio_service_unlike')
            : const MediaControl(label: 'setRating', action: MediaAction.setRating, androidIcon: 'drawable/audio_service_like'),
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ]
    ));
  }
  /// 更新当前索引（可以指定新Index，也可以通过跳过计算新Index）
  _updateCurIndex({int newIndex = -1, bool isSkip = false, bool isSkipToNext = false}) {
    // 上一曲或下一曲，计算Index
    if (isSkip) {
      // 单曲循环模式直接返回
      if (_curRepeatMode == AudioServiceRepeatMode.one) {
        newIndex = _curIndex;
      } else {
        newIndex = isSkipToNext ? _curIndex + 1 : _curIndex - 1;
        // 如果超出索引范围，循环到列表的开始或结尾
        int listLength = queue.value.length;
        if (newIndex == listLength) {
          newIndex = 0;
        } else if (newIndex < 0) {
          newIndex = listLength - 1;
        }
      }
    }
    // 更新Index
    if (_curIndex != newIndex) {
      _curIndex = newIndex;
      AppController.to.updateCurPlayIndex(newIndex);
    }
  }


  /// 打乱or恢复播放列表顺序
  Future<void> reorderPlayList({bool shufflePlayList = false}) async {
    var playListCopy = <MediaItem>[..._originalPlayList];
    if (shufflePlayList) playListCopy.shuffle();
    String curSongId = queue.value[_curIndex].id;
    int curNewIndex = playListCopy.indexWhere((element) => element.id == curSongId);
    await updateQueue(playListCopy);
    _updateCurIndex(newIndex: curNewIndex);
  }

  /// 在AudioHandle中打乱播放列表
  Future<void> changePlayList(List<MediaItem> list, int index) async {
    // 保存当前播放列表(原始顺序列表)
    _originalPlayList..clear()..addAll(list);
    // 更新播放列表到播放器
    if (AppController.to.isFmMode.isFalse && _curRepeatMode == AudioServiceRepeatMode.none) {
      // 随机播放模式，打乱播放列表，重新获取index
      var playListCopy = <MediaItem>[...list]..shuffle();
      index = playListCopy.indexWhere((element) => element.id == list[index].id);
      await updateQueue(playListCopy);
    } else {
      await updateQueue(list);
    }
    _updateCurIndex(newIndex: index);
  }
  /// 这里Index是在 正在播放列表 中的索引
  Future<void> playIndex(int index) async {
    // 接收到下标
    _updateCurIndex(newIndex: index);
    await changePlayerSource(playNow: true);
  }
  Future<void> changePlayerSource({bool isNext = true, required bool playNow}) async {
    bool highQuality = AppController.to.isHighSoundQualityOpen.value;
    // TODO YU4422 歌曲缓存功能
    bool isCacheOpen = AppController.to.isCacheOpen.value;

    // 这里是获取歌曲url
    if (queue.value.isEmpty) return;
    MediaItem song = queue.value[_curIndex];
    String? url;
    // 本地歌曲
    if (song.extras?['type'] == MediaType.local.name || song.extras?['type'] == MediaType.neteaseCache.name) {
      url = song.extras?['url'];
      if (url != null) {
        song.extras?.putIfAbsent('cache', () => true);
        mediaItem.add(song);
        //是本地音乐
        if (song.extras?['type'] == MediaType.local.name) {
          await _player.setFilePath(url);
        }
        //网易云缓存的音乐要解密哦
        if (song.extras?['type'] == MediaType.neteaseCache.name) {
          _player.setAudioSource(StreamSource(url, url.replaceAll('.uc!', '').split('.').last));
        }
        if (playNow) await play();
        return;
      }
    // 在线获取
    } else {
      mediaItem.add(song);
      SongUrlListWrap songUrl = await NeteaseMusicApi().songDownloadUrl([song.id], level: highQuality ? 'lossless' : 'exhigh');
      url = ((songUrl.data ?? [])[0].url ?? '').split('?')[0];
      // 如果获取不到URL就跳过
      if (url.isNotEmpty) {
        await _player.setUrl(url);
        if (playNow) await play();
      } else {
        await (isNext ? skipToNext() : skipToPrevious());
      }
    }
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {}
  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < _curIndex) _curIndex--;
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }
  //更改为喜欢按钮
  @override
  Future<void> rewind() async {
    AppController.to.toggleLikeStatus();
  }
  @override
  Future<void> pause() async {
    await _player.pause();
    _updateMediaControls();
  }
  @override
  Future<void> play() async {
    await _player.play();
    _updateMediaControls();
  }
  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    await super.updateMediaItem(mediaItem);
    _updateMediaControls();
  }
  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
  @override
  Future<void> skipToNext() async {
    _player.stop();
    _updateCurIndex(isSkip: true, isSkipToNext: true);
    await changePlayerSource(playNow: true);
  }
  @override
  Future<void> skipToPrevious() async {
    _player.stop();
    _updateCurIndex(isSkip: true, isSkipToNext: false);
    await changePlayerSource(isNext: false, playNow: true);
  }
  @override
  Future<void> stop() async {
    await _player.stop();
  }
  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // 更新播放列表
    _curRepeatMode = repeatMode;
  }
  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
  }
}

class StreamSource extends StreamAudioSource {
  String uri;
  String fileType;

  // Get the Android content uri and the corresponsing file type by using MediaStore API in android
  StreamSource(this.uri, this.fileType);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Use a method channel to read the file into a List of bytes
    Uint8List fileBytes = Uint8List.fromList(File(uri).readAsBytesSync().map((e) => e ^ 0xa3).toList());

    // Returning the stream audio response with the parameters
    return StreamAudioResponse(
      sourceLength: fileBytes.length,
      contentLength: (start ?? 0) - (end ?? fileBytes.length),
      offset: start ?? 0,
      stream: Stream.fromIterable([fileBytes.sublist(start ?? 0, end)]),
      contentType: fileType,
    );
  }
}

Map<String, dynamic>? castMap(Map? map) => map?.cast<String, dynamic>();
