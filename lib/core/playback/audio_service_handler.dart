import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/features/playback/controller/player_controller.dart';
import 'package:bujuan/features/playback/repository/playback_repository.dart';
import 'package:bujuan/features/playback/repository/playback_state_store.dart';
import 'package:bujuan/features/settings/controller/settings_controller.dart';
import 'package:bujuan/features/user/controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// 承接 `audio_service` 层的播放状态与队列控制。
///
/// 这里保留的职责有两类：
/// 1. 平台播放器必须直接理解的播放行为与通知栏状态。
/// 2. 仍依赖历史 `MediaItem` 队列格式的恢复与兼容逻辑。
///
/// 页面和控制器不应直接复制这里的行为，否则播放状态、通知栏状态和
/// 本地恢复状态会很快分叉。
class AudioServiceHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late final AudioPlayer _player;
  final PlaybackRepository _playbackRepository = PlaybackRepository();
  final PlaybackStateStore _stateStore = const PlaybackStateStore();

  final List<MediaItem> _originalSongs = <MediaItem>[];

  int _curIndex = -1;

  AudioServiceRepeatMode curRepeatMode = AudioServiceRepeatMode.all;

  AudioServiceHandler() {
    _player = AudioPlayer();
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
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _curIndex,
      ));
    });
    _updateMediaControls();
  }

  /// 按历史缓存格式恢复上一次的播放模式和队列。
  ///
  /// 当前仍有大量页面和控制器默认依赖“关闭应用后还能直接回到上一次队列”的行为，
  /// 所以恢复逻辑必须保留在音频服务入口，而不是交给页面自己拼。
  restoreLastPlayState() async {
    bool isFm = _stateStore.isFmModeEnabled;
    bool isHeart = _stateStore.isHeartBeatModeEnabled;
    if (isFm) {
      PlayerController.to.playbackMode.value = PlaybackMode.roaming;
    } else if (isHeart) {
      PlayerController.to.playbackMode.value = PlaybackMode.heartbeat;
    } else {
      PlayerController.to.playbackMode.value = PlaybackMode.playlist;
    }
    String repeatMode = _stateStore.repeatModeName;
    changeRepeatMode(
        newRepeatMode: AudioServiceRepeatMode.values
                .firstWhereOrNull((element) => element.name == repeatMode) ??
            AudioServiceRepeatMode.all);
    List<String> stringPlayList = _stateStore.storedQueue;
    String curSongId = _stateStore.currentSongId;
    if (stringPlayList.isNotEmpty) {
      List<MediaItem> playlist =
          await compute(stringToPlayList, stringPlayList);
      int index = playlist.indexWhere((element) => element.id == curSongId);
      await changePlayList(playlist,
          index: index,
          playListName: _stateStore.storedPlaylistName,
          playListNameHeader: _stateStore.storedPlaylistHeader,
          changePlayerSource: true,
          playNow: false,
          needStore: false);
    }
  }

  changeRepeatMode({AudioServiceRepeatMode? newRepeatMode}) async {
    if (newRepeatMode == null) {
      switch (curRepeatMode) {
        case AudioServiceRepeatMode.one:
          newRepeatMode = AudioServiceRepeatMode.none;
          await reorderPlayList(shufflePlayList: true);
          break;
        case AudioServiceRepeatMode.none:
          newRepeatMode = AudioServiceRepeatMode.all;
          await reorderPlayList(shufflePlayList: false);
          break;
        case AudioServiceRepeatMode.all:
        case AudioServiceRepeatMode.group:
          newRepeatMode = AudioServiceRepeatMode.one;
          break;
      }
    }
    curRepeatMode = newRepeatMode;

    await _stateStore.saveRepeatMode(newRepeatMode);
    PlayerController.to.curRepeatMode.value = newRepeatMode;
    _updateMediaControls();
  }

  /// 随机模式切换依赖 `_originalSongs` 保留原始顺序，否则来回切模式会不断
  /// 在已打乱结果上再次打乱，用户无法回到真正的原歌单顺序。
  reorderPlayList({bool shufflePlayList = false}) async {
    var playListCopy = <MediaItem>[..._originalSongs];
    if (shufflePlayList) playListCopy.shuffle();
    String curSongId = queue.value[_curIndex].id;
    int curNewIndex =
        playListCopy.indexWhere((element) => element.id == curSongId);
    _curIndex = curNewIndex;
    await updateQueue(playListCopy);
  }

  /// 统一更新音频服务队列、播放列表元信息和持久化缓存。
  ///
  /// 当前项目仍有多种入口会切换播放列表，先把这些副作用收口在这里，
  /// 比让每个调用点各自改队列和缓存更稳。
  changePlayList(List<MediaItem> playList,
      {int index = 0,
      bool needStore = true,
      required String playListName,
      String playListNameHeader = "",
      required bool changePlayerSource,
      required bool playNow}) async {
    _originalSongs
      ..clear()
      ..addAll(playList);
    var playListCopy = <MediaItem>[...playList];
    if (curRepeatMode == AudioServiceRepeatMode.none &&
        PlayerController.to.playbackMode.value == PlaybackMode.playlist) {
      playListCopy.shuffle();
      index = playListCopy
          .indexWhere((element) => element.id == playList[index].id);
    }
    await updateQueue(playListCopy);
    PlayerController.to.curPlayListName.value = playListName;
    PlayerController.to.curPlayListNameHeader.value = playListNameHeader;
    PlayerController.to.isPlayingLikedSongs.value = playListName == "喜欢的音乐";
    await _stateStore.savePlaylistMeta(
      playlistName: playListName,
      playlistHeader: playListNameHeader,
    );

    if (changePlayerSource) {
      await playIndex(audioSourceIndex: index, playNow: playNow);
    } else {
      _curIndex = index;
    }
    if (needStore) {
      await _stateStore.saveQueue(
        await compute(playListToString, _originalSongs),
      );
    }
  }

  /// 根据 `MediaItem` 的历史类型约定解析真实播放源。
  ///
  /// 这里仍保留 `local / neteaseCache / playlist` 三种分支，是为了兼容
  /// 现有缓存队列和页面侧 extras 结构；在新的统一播放模型完全接管前，
  /// 不能直接把这层类型判断删掉。
  playIndex({required int audioSourceIndex, required bool playNow}) async {
    bool isNext = audioSourceIndex >= _curIndex;
    _curIndex = audioSourceIndex;
    MediaItem newIndexMediaItem = queue.value[audioSourceIndex];
    mediaItem.add(newIndexMediaItem);
    String url = "";
    if (newIndexMediaItem.extras?['type'] == MediaType.local.name) {
      url = newIndexMediaItem.extras?['url'] ?? '';
      if (url.isNotEmpty) {
        newIndexMediaItem.extras?.putIfAbsent('cache', () => true);
        await _player.setFilePath(url);
      }
    } else if (newIndexMediaItem.extras?['type'] ==
        MediaType.neteaseCache.name) {
      url = newIndexMediaItem.extras?['url'] ?? '';
      if (url.isNotEmpty) {
        newIndexMediaItem.extras?.putIfAbsent('cache', () => true);
        await _player.setAudioSource(
            StreamSource(url, url.replaceAll('.uc!', '').split('.').last));
      }
    } else {
      bool highQuality = SettingsController.to.isHighSoundQualityOpen.value;
      url = (await _playbackRepository.fetchPlaybackUrl(
                newIndexMediaItem.id,
                preferHighQuality: highQuality,
              ) ??
              '')
          .split('?')[0];
      if (url.isNotEmpty) {
        final localFile = File(url);
        if (localFile.existsSync()) {
          newIndexMediaItem.extras?.putIfAbsent('cache', () => true);
          await _player.setFilePath(url);
        } else {
          await _player.setUrl(url);
        }
      }
    }
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

  @override
  Future<void> rewind() async {
    UserController.to.toggleLikeStatus(queue.value[_curIndex]);
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
    if (curRepeatMode == AudioServiceRepeatMode.one) {
      newIndex = _curIndex;
    } else {
      newIndex = _curIndex + 1;
      if (newIndex == queue.value.length) {
        // 漫游模式的补队列是异步触发的，直接回环会把“加载中”和“切回第一首”
        // 混成同一个动作，结果会让队列状态和 UI 都更难解释。
        if (PlayerController.to.playbackMode.value == PlaybackMode.roaming) {
          WidgetUtil.showToast('正在加载漫游歌曲...');
          return;
        }
        newIndex = 0;
      }
    }
    playIndex(audioSourceIndex: newIndex, playNow: true);
  }

  @override
  Future<void> skipToPrevious() async {
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
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {}
  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
  }

  /// 通知栏按钮仍以 `MediaItem.extras['liked']` 为准。
  ///
  /// 这里没有直接改成统一领域模型，是因为当前通知栏状态刷新仍跟着
  /// `audio_service` 的 `MediaItem` 流转，贸然拆开会先破坏现有按钮状态。
  _updateMediaControls() {
    bool isLiked = mediaItem.value?.extras?['liked'] ?? false;
    playbackState.add(playbackState.value.copyWith(controls: [
      MediaControl(
          label: 'rewind',
          action: MediaAction.rewind,
          androidIcon: isLiked
              ? 'drawable/audio_service_like'
              : 'drawable/audio_service_unlike'),
      MediaControl.skipToPrevious,
      _player.playing ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ]));
  }
}

class StreamSource extends StreamAudioSource {
  String uri;
  String fileType;

  /// 仍保留 `.uc!` 解密读取，是为了兼容历史网易云缓存文件。
  StreamSource(this.uri, this.fileType);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // `.uc!` 缓存不是标准媒体文件，仍保留按字节异或的读取方式，
    // 否则现有本地缓存会在迁移期全部失效。
    Uint8List fileBytes = Uint8List.fromList(
        File(uri).readAsBytesSync().map((e) => e ^ 0xa3).toList());

    return StreamAudioResponse(
      sourceLength: fileBytes.length,
      contentLength: (start ?? 0) - (end ?? fileBytes.length),
      offset: start ?? 0,
      stream: Stream.fromIterable([fileBytes.sublist(start ?? 0, end)]),
      contentType: fileType,
    );
  }
}

/// `MediaItem` 的持久化过渡格式。
///
/// 当前播放队列仍通过字符串列表写入轻存储，先保留这层显式转换，
/// 避免直接把 `MediaItem` 的内部结构散落到多个调用点。
class MediaItemBean {
  final String id;
  final String title;
  final String? album;
  final String? artist;
  final String? genre;
  final Duration? duration;
  final Uri? artUri;
  final bool? playable;
  final String? displayTitle;
  final String? displaySubtitle;
  final String? displayDescription;
  final Map<String, dynamic>? extras;
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

  factory MediaItemBean.fromMap(Map<String, dynamic> raw) => MediaItemBean(
        id: raw['id'] as String,
        title: raw['title'] as String,
        album: raw['album'] as String?,
        artist: raw['artist'] as String?,
        genre: raw['genre'] as String?,
        duration: raw['duration'] != null
            ? Duration(milliseconds: raw['duration'] as int)
            : null,
        artUri:
            raw['artUri'] != null ? Uri.parse(raw['artUri'] as String) : null,
        playable: raw['playable'] as bool?,
        displayTitle: raw['displayTitle'] as String?,
        displaySubtitle: raw['displaySubtitle'] as String?,
        displayDescription: raw['displayDescription'] as String?,
        extras: raw['extras'] as Map<String, dynamic>?,
      );

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

/// 保留独立 isolate 转换，避免大队列恢复时把 JSON 解析全部压回主线程。
Future<List<MediaItem>> stringToPlayList(List<String> cachedPlayList) async {
  return compute(_stringToPlayListIsolate, cachedPlayList);
}

List<MediaItem> _stringToPlayListIsolate(List<String> cachedPlayList) {
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

/// 播放队列的持久化格式仍以字符串列表为准，先保持旧缓存兼容，
/// 后续统一播放队列模型接管后再整体替换。
Future<List<String>> playListToString(List<MediaItem> playList) async {
  return compute(_playListToStringIsolate, playList);
}

List<String> _playListToStringIsolate(List<MediaItem> data) {
  return data
      .map((e) => jsonEncode(MediaItemBean(
            id: e.id,
            album: e.album,
            title: e.title,
            artist: e.artist,
            duration: e.duration,
            artUri: e.artUri,
            extras: e.extras,
          ).toMap()))
      .toList();
}
