import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';

import 'constants/key.dart';
import 'constants/key.dart' as key;
import 'netease_api/src/api/play/bean.dart';
import 'netease_api/src/netease_api.dart';

class AudioServiceHandler extends BaseAudioHandler with SeekHandler, QueueHandler{
  late final AudioPlayer _player;
  Box box = GetIt.instance<Box>();

  /// 当前原始播放列表（用于随机和顺序播放模式切换用）
  final List<MediaItem> _originalSongs = <MediaItem>[];
  /// 播放列表索引（当前播放对应在正在播放的列表索引）
  int _curIndex = -1;
  /// 播放模式（none表示随机模式）
  AudioServiceRepeatMode curRepeatMode = AudioServiceRepeatMode.all;

  AudioServiceHandler() {
    _player = AudioPlayer();
    // 映射播放器状态
    _player.playbackEventStream.listen((PlaybackEvent event) {
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

  /// 打乱or恢复播放列表顺序
  restoreLastPlayState() async {
    // 恢复漫游模式状态
    AppController.to.isFmMode.value = box.get(fmSp, defaultValue: false);
    // 恢复心动模式状态
    AppController.to.isHeartBeatMode.value = box.get(heartBeatSp, defaultValue: false);
    // 恢复播放模式
    String repeatMode = box.get(repeatModeSp, defaultValue: 'all');
    changeRepeatMode(newRepeatMode: AudioServiceRepeatMode.values.firstWhereOrNull((element) => element.name == repeatMode) ?? AudioServiceRepeatMode.all);
    // 恢复播放列表
    List<String> stringPlayList = box.get(playQueue, defaultValue: <String>[]);
    String curSongId = box.get(curPlaySongId, defaultValue: '');
    if (stringPlayList.isNotEmpty) {
      List<MediaItem> playlist = await compute(stringToPlayList, stringPlayList);
      int index = playlist.indexWhere((element) => element.id == curSongId);
      await changePlayList(playlist, index: index, playListName: box.get(playListName, defaultValue: ''), playListNameHeader: box.get(playListNameHeader, defaultValue: ''), changePlayerSource: true, playNow: false, needStore: false);
    }
  }
  /// 改变循环模式
  changeRepeatMode({AudioServiceRepeatMode? newRepeatMode}) async {
    if (newRepeatMode == null) {
      switch (curRepeatMode) {
      // 单曲 -> 随机
        case AudioServiceRepeatMode.one:
          newRepeatMode = AudioServiceRepeatMode.none;
          await reorderPlayList(shufflePlayList: true);
          break;
      // 随机 -> 全部
        case AudioServiceRepeatMode.none:
          newRepeatMode = AudioServiceRepeatMode.all;
          await reorderPlayList(shufflePlayList: false);
          break;
      // 全部 -> 单曲
        case AudioServiceRepeatMode.all:
        case AudioServiceRepeatMode.group:
          newRepeatMode = AudioServiceRepeatMode.one;
          break;
      }
    }
    curRepeatMode = newRepeatMode;

    box.put(repeatModeSp, newRepeatMode.name);
    AppController.to.curRepeatMode.value = newRepeatMode;
    _updateMediaControls();
  }
  /// 打乱or恢复播放列表顺序
  reorderPlayList({bool shufflePlayList = false}) async {
    var playListCopy = <MediaItem>[..._originalSongs];
    if (shufflePlayList) playListCopy.shuffle();
    String curSongId = queue.value[_curIndex].id;
    int curNewIndex = playListCopy.indexWhere((element) => element.id == curSongId);
    _curIndex = curNewIndex;
    await updateQueue(playListCopy);
  }
  /// 在AudioHandle中打乱播放列表
  changePlayList(
      List<MediaItem> playList,
      {int index = 0,
        bool needStore = true,
        required String playListName,
        String playListNameHeader = "",
        required bool changePlayerSource,
        required bool playNow
      }
      ) async {
    // 保存当前播放列表(原始顺序列表)
    _originalSongs..clear()..addAll(playList);
    var playListCopy = <MediaItem>[...playList];
    // 随机播放模式，打乱播放列表，重新获取index
    if (curRepeatMode == AudioServiceRepeatMode.none && AppController.to.isFmMode.isFalse && AppController.to.isHeartBeatMode.isFalse) {
      playListCopy.shuffle();
      index = playListCopy.indexWhere((element) => element.id == playList[index].id);
    }
    // 播放器播放列表更新
    await updateQueue(playListCopy);
    AppController.to.curPlayListName.value = playListName;
    AppController.to.curPlayListNameHeader.value = playListNameHeader;
    AppController.to.isPlayingLikedSongs.value = playListName == "喜欢的音乐";
    box.put(key.playListName, playListName);
    box.put(key.playListNameHeader, playListNameHeader);

    // 是否更改当前播放源
    if (changePlayerSource) {
      // 是否直接开始播放
      await playIndex(audioSourceIndex: index, playNow: playNow);
    } else {
      _curIndex = index;
    }
    // 保存原始播放列表
    if (needStore) {
      box.put(playQueue, await compute(playListToString, _originalSongs));
    }
  }

  /// 这里Index是在 正在播放列表 中的索引
  playIndex({required int audioSourceIndex, required bool playNow}) async {
    // _player.stop();
    bool isNext = audioSourceIndex >= _curIndex;
    _curIndex = audioSourceIndex;
    // 获取歌曲资源
    MediaItem newIndexMediaItem = queue.value[audioSourceIndex];
    mediaItem.add(newIndexMediaItem);
    String url = "";
    // 本地歌曲
    if (newIndexMediaItem.extras?['type'] == MediaType.local.name) {
      url = newIndexMediaItem.extras?['url'] ?? '';
      if (url.isNotEmpty) {
        newIndexMediaItem.extras?.putIfAbsent('cache', () => true);
        await _player.setFilePath(url);
      }
    // 网易云缓存
    }else if (newIndexMediaItem.extras?['type'] == MediaType.neteaseCache.name){
      url = newIndexMediaItem.extras?['url'] ?? '';
      if (url.isNotEmpty) {
        newIndexMediaItem.extras?.putIfAbsent('cache', () => true);
        // 网易云缓存的音乐要解密哦
        await _player.setAudioSource(StreamSource(url, url.replaceAll('.uc!', '').split('.').last));
      }
    // 在线歌曲
    } else {
      bool highQuality = AppController.to.isHighSoundQualityOpen.value;
      SongUrlListWrap songUrl = await NeteaseMusicApi().songDownloadUrl([newIndexMediaItem.id], level: highQuality ? 'lossless' : 'exhigh');
      url = ((songUrl.data ?? [])[0].url ?? '').split('?')[0];
      // 如果获取不到URL就跳过
      if (url.isNotEmpty) {
        await _player.setUrl(url);
      }
    }
    // 根据配置决定是否立即播放
    if (playNow) {
      if (url.isNotEmpty) {
        await play();
      } else {
        isNext ? skipToNext() : skipToPrevious();
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
    int newIndex;
    // 单曲循环模式直接返回
    if (curRepeatMode == AudioServiceRepeatMode.one) {
      newIndex = _curIndex;
    } else {
      newIndex = _curIndex + 1;
      if (newIndex == queue.value.length) {
        newIndex = 0;
      }
    }
    playIndex(audioSourceIndex: newIndex, playNow: true);
  }
  @override
  Future<void> skipToPrevious() async {
    // 单曲循环模式直接返回
    int newIndex;
    if (curRepeatMode == AudioServiceRepeatMode.one) {
      newIndex = _curIndex;
    } else {
      newIndex = _curIndex - 1;
      if (newIndex < 0) {
        newIndex = queue.value.length - 1;
      }
    }
    playIndex(audioSourceIndex: newIndex, playNow: true);
  }
  @override
  Future<void> stop() async {
    await changeRepeatMode();
  }
  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
  }
  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
  }

  /// 更新状态栏控制按钮
  _updateMediaControls() {
    bool isLiked = mediaItem.value?.extras?['liked'] ?? false;
    playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl(label: 'rewind', action: MediaAction.rewind, androidIcon: isLiked ?'drawable/audio_service_like' : 'drawable/audio_service_unlike'),
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ]
    ));
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

class MediaItemBean {
  /// A unique id.
  final String id;

  /// The title of this media item.
  final String title;

  /// The album this media item belongs to.
  final String? album;

  /// The artist of this media item.
  final String? artist;

  /// The genre of this media item.
  final String? genre;

  /// The duration of this media item.
  final Duration? duration;

  /// The artwork for this media item as a uri.
  final Uri? artUri;

  /// Whether this is playable (i.e. not a folder).
  final bool? playable;

  /// Override the default title for display purposes.
  final String? displayTitle;

  /// Override the default subtitle for display purposes.
  final String? displaySubtitle;

  /// Override the default description for display purposes.
  final String? displayDescription;

  /// The rating of the MediaItemMessage.

  /// A map of additional metadata for the media item.
  ///
  /// The values must be integers or strings.
  final Map<String, dynamic>? extras;

  /// Creates a [MediaItemBean].
  ///
  /// The [id] must be unique for each instance.
  const MediaItemBean({
    required this.id,
    required this.title,
    this.album,
    this.artist,
    this.genre,
    this.duration,
    this.artUri,
    this.playable = true,
    this.displayTitle,
    this.displaySubtitle,
    this.displayDescription,
    this.extras,
  });

  /// Creates a [MediaItemBean] from a map of key/value pairs corresponding to
  /// fields of this class.
  factory MediaItemBean.fromMap(Map<String, dynamic> raw) => MediaItemBean(
    id: raw['id'] as String,
    title: raw['title'] as String,
    album: raw['album'] as String?,
    artist: raw['artist'] as String?,
    genre: raw['genre'] as String?,
    duration: raw['duration'] != null ? Duration(milliseconds: raw['duration'] as int) : null,
    artUri: raw['artUri'] != null ? Uri.parse(raw['artUri'] as String) : null,
    playable: raw['playable'] as bool?,
    displayTitle: raw['displayTitle'] as String?,
    displaySubtitle: raw['displaySubtitle'] as String?,
    displayDescription: raw['displayDescription'] as String?,
    extras: raw['extras'] as Map<String, dynamic>?,
  );

  /// Converts this [MediaItemBean] to a map of key/value pairs corresponding to
  /// the fields of this class.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'album': album,
    'artist': artist,
    'genre': genre,
    'duration': duration?.inMilliseconds,
    'artUri': artUri?.toString(),
    'playable': playable,
    'displayTitle': displayTitle,
    'displaySubtitle': displaySubtitle,
    'displayDescription': displayDescription,
    'extras': extras,
  };
}
Future<List<MediaItem>> stringToPlayList(List<String> cachedPlayList) async {
  return cachedPlayList.map((e) {
    var mediaItemBean = MediaItemBean.fromMap(jsonDecode(e));
    return MediaItem(
      id: mediaItemBean.id,
      duration: mediaItemBean.duration,
      artUri: mediaItemBean.artUri,
      extras: mediaItemBean.extras,
      title: mediaItemBean.title,
      artist: mediaItemBean.artist,
      album: mediaItemBean.album,
    );
  }).toList();
}
Future<List<String>> playListToString(List<MediaItem> playList) async {
  return playList.map((e) => jsonEncode(MediaItemBean(
    id: e.id,
    album: e.album,
    title: e.title,
    artist: e.artist,
    duration: e.duration,
    artUri: e.artUri,
    extras: e.extras,
  ).toMap())).toList();
}