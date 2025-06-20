import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
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

class BujuanAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler implements AudioPlayerHandler {

  final _player = GetIt.instance<AudioPlayer>();
  final Box _box = GetIt.instance<Box>();
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

  /// 当前原始播放列表
  final _playList = <MediaItem>[];
  /// 播放列表索引
  int _curIndex = -1;
  /// 播放模式（none表示随机模式）
  AudioServiceRepeatMode _audioServiceRepeatMode = AudioServiceRepeatMode.all;

  BujuanAudioHandler() {
    // 初始化
    _restoreAudioStateFromStorage();
    _addPlaybackEventListener();
    _addPlayerStateListener();
  }

  void _restoreAudioStateFromStorage() async {
    // 恢复播放模式
    String repeatMode = _box.get(repeatModeSp, defaultValue: 'all');
    _audioServiceRepeatMode = AudioServiceRepeatMode.values.firstWhereOrNull((element) => element.name == repeatMode)!;
    // 恢复当前播放歌曲索引
    _curIndex = _box.get(curPlaySongIndex, defaultValue: 0);
    // 恢复播放列表
    List<String> playList = _box.get(playQueue, defaultValue: <String>[]);
    if (playList.isNotEmpty) {
      List<MediaItem> items = await compute(getCachePlayList, RootIsolateData(rootIsolateToken, playlist: playList));
      await changeQueueLists(items, init: true, index: _curIndex);
    }
  }

  void _addPlaybackEventListener() {
    _player.playbackEventStream.listen((PlaybackEvent event) {

      if(event.processingState == ProcessingState.completed) skipToNext();

      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: buildMediaControls(isLiked: mediaItem.value?.extras?['liked'] ?? false, playing: playing),
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
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _curIndex,
      ));
    });
  }

  void _addPlayerStateListener() {
    _player.playerStateStream.listen((state) {

      switch (state.processingState) {
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          break;
        case ProcessingState.buffering:
          break;
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          break;
      }
    });
  }

  List<MediaControl> buildMediaControls({required bool isLiked, required bool playing}) => [
    PlatformUtils.isAndroid
        ? isLiked
          ? const MediaControl(label: 'fastForward', action: MediaAction.fastForward, androidIcon: 'drawable/audio_service_like')
          : const MediaControl(label: 'rewind', action: MediaAction.rewind, androidIcon: 'drawable/audio_service_unlike')
        : const MediaControl(label: 'setRating', action: MediaAction.setRating, androidIcon: 'drawable/audio_service_like'),
    MediaControl.skipToPrevious,
    if (playing) MediaControl.pause else MediaControl.play,
    MediaControl.skipToNext,
    MediaControl.stop,
  ];


  @override
  Future<void> addFmItems(List<MediaItem> mediaItems) async {
    print("FM: $mediaItem");
    // FM模式刷新歌曲
    if (HomePageController.to.isFmMode.value) {
      queue.value.removeRange(0, queue.value.length - 1);
      addQueueItems(mediaItems);
      _updateCurIndex(0);
    // 首次进入FM模式
    } else {
      changeQueueLists(mediaItems);
      playCurIndex();
      // 保存FM开启状态
      HomePageController.to.isFmMode.value = true;
      _box.put(fmSp, true);
    }
    List<String> playList = await compute(setCachePlayList, RootIsolateData(rootIsolateToken, items: mediaItems));
    queueTitle.value = 'Fm';
    _box.put(playQueue, playList);
  }
  @override
  Future<void> changeQueueLists(List<MediaItem> list, {int index = 0, bool init = false}) async {
    // 切歌单退出FM模式
    if (HomePageController.to.isFmMode.value) {
      HomePageController.to.isFmMode.value = false;
      _box.put(fmSp, false);
    }
    if (!init) {
      List<String> playList = await compute(setCachePlayList, RootIsolateData(rootIsolateToken, items: list));
      _box.put(playQueue, playList);
    }

    // 保存当前播放列表
    _playList..clear()..addAll(list);
    if (_audioServiceRepeatMode == AudioServiceRepeatMode.none) {
      var playListCopy = <MediaItem>[...list];
      playListCopy.shuffle();
      await updateQueue(playListCopy);
      index = playListCopy.indexWhere((element) => element.id == list[index].id);
    } else {
      await updateQueue(list);
    }
    _updateCurIndex(index);
  }

  @override
  Future<void> changeQueueListsRepeatMode() async {
    var playListCopy = <MediaItem>[..._playList];
    // 随机播放模式
    if (_audioServiceRepeatMode == AudioServiceRepeatMode.none) {
      // 播放列表随机打乱后的副本
      playListCopy.shuffle();
    }
    String songId = queue.value[_curIndex].id;
    await updateQueue(playListCopy);
    int curNewIndex = playListCopy.indexWhere((element) => element.id == songId);
    _updateCurIndex(curNewIndex);
  }
  @override
  Future<void> playIndex(int index) async {
    // 接收到下标
    _updateCurIndex(index);
    await playCurIndex();
  }
  @override
  Future<void> playCurIndex({bool isNext = true}) async {
    bool high = HomePageController.to.isHighSoundQualityOpen.value;
    // TODO YU4422 歌曲缓存功能
    bool isCacheOpen = HomePageController.to.isCacheOpen.value;

    // 这里是获取歌曲url
    if (queue.value.isEmpty) return;

    MediaItem song = queue.value[_curIndex];
    _box.put(curPlaySongId, song.id);
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
        _player.play();
        return;
      }
    // 在线获取
    } else {
      mediaItem.add(song);
      SongUrlListWrap songUrl = await NeteaseMusicApi().songDownloadUrl([song.id], level: high ? 'lossless' : 'exhigh');
      url = ((songUrl.data ?? [])[0].url ?? '').split('?')[0];
      // 如果获取不到URL就跳过
      if (url.isNotEmpty) {
        await _player.setUrl(url);
        _player.play();
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
  //更改为不喜欢按钮
  @override
  Future<void> fastForward() async {
    // updateMediaItem(mediaItem.value?.copyWith(extras: {'liked':'true'})??const MediaItem(id: 'id', title: 'title'));
    HomePageController.to.likeSong(liked: true);
  }
  //更改为喜欢按钮
  @override
  Future<void> rewind() async {
    HomePageController.to.likeSong(liked: false);
  }
  @override
  Future<void> pause() async => await _player.pause();
  @override
  Future<void> play() async => await _player.play();
  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
  @override
  Future<void> skipToQueueItem(int index) async {
    // TODO: implement skipToQueueItem
    // return super.skipToQueueItem(index);
  }
  @override
  Future<void> skipToNext() async {
    _updateCurIndexByRepeatMode(isSkipToNext: true);
    await playCurIndex();
  }
  @override
  Future<void> skipToPrevious() async {
    _updateCurIndexByRepeatMode();
    await playCurIndex(isNext: false);
  }
  @override
  Future<void> stop() async {
    await _player.stop();
  }
  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {}
  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    print('setRepeatMode: $repeatMode');
    // 更新播放列表
    _audioServiceRepeatMode = repeatMode;
    HomePageController.to.audioServiceRepeatMode.value = repeatMode;
    _box.put(repeatModeSp, repeatMode.name);
    // 根据循环模式更新播放列表
    await changeQueueListsRepeatMode();
  }
  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
  }

  /// 切换上一首、下一首的时候时候调用（列表循环）
  _updateCurIndexByRepeatMode({bool isSkipToNext = false}) {
    // 单曲循环模式直接返回
    if (_audioServiceRepeatMode == AudioServiceRepeatMode.one) return;

    int listLength = queue.value.length;

    int newIndex = isSkipToNext ? _curIndex + 1 : _curIndex - 1;
    // 如果超出索引范围，循环到列表的开始或结尾
    if (newIndex == listLength) {
      newIndex = 0;
    } else if (newIndex < 0) {
      newIndex = listLength - 1;
    }
    _updateCurIndex(newIndex);
  }

  void _updateCurIndex(int newIndex) {
    if (_curIndex == newIndex) return;
    _curIndex = newIndex;
    _box.put(curPlaySongIndex, _curIndex);

    // 私人FM模式 播放到最后一首拉取新的FM歌曲列表
    if (HomePageController.to.isFmMode.value && _curIndex == queue.value.length - 1) {
        HomePageController.to.getFmSongList();
    }

    // 更新UI
    bool isSkipToNext = newIndex > HomePageController.to.curPlayIndex.value;
    HomePageController.to.lastPlayIndex.value = HomePageController.to.curPlayIndex.value;
    HomePageController.to.curPlayIndex.value = newIndex;
    // 切换专辑封面
    if (HomePageController.to.isAlbumPageViewScrolling.isFalse) {
      if((HomePageController.to.lastPlayIndex.value - HomePageController.to.curPlayIndex.value).abs() == 1) {
        HomePageController.to.albumPageController.animateToPage(newIndex, duration: const Duration(milliseconds: 500), curve: Curves.linear);
      } else {
        HomePageController.to.albumPageController.jumpToPage(newIndex);
      }
    }
    // 切换标题
    if (HomePageController.to.panelFullyOpened.value) {
      HomePageController.to.changeAppBarTitle(
          title: HomePageController.to.curPlayList[_curIndex].title,
          subTitle: HomePageController.to.curPlayList[_curIndex].artist ?? "",
          direction: isSkipToNext ? NewAppBarTitleComingDirection.right : NewAppBarTitleComingDirection.left);
    }
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

class RootIsolateData {
  RootIsolateToken rootIsolateToken;
  List<String>? playlist;
  List<MediaItem>? items;

  RootIsolateData(this.rootIsolateToken, {this.playlist, this.items});
}

class MediaItemMessage {
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

  /// Creates a [MediaItemMessage].
  ///
  /// The [id] must be unique for each instance.
  const MediaItemMessage({
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

  /// Creates a [MediaItemMessage] from a map of key/value pairs corresponding to
  /// fields of this class.
  factory MediaItemMessage.fromMap(Map<String, dynamic> raw) => MediaItemMessage(
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
    extras: castMap(raw['extras'] as Map?),
  );

  /// Converts this [MediaItemMessage] to a map of key/value pairs corresponding to
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

Map<String, dynamic>? castMap(Map? map) => map?.cast<String, dynamic>();

Future<List<MediaItem>> getCachePlayList(RootIsolateData data) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);
  List<MediaItem> items = data.playlist?.map((e) {
    var map = MediaItemMessage.fromMap(jsonDecode(e));
    return MediaItem(
      id: map.id,
      duration: map.duration,
      artUri: map.artUri,
      extras: map.extras,
      title: map.title,
      artist: map.artist,
      album: map.album,
    );
  }).toList() ??
      [];
  return items;
}

Future<List<String>> setCachePlayList(RootIsolateData data) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);
  return data.items
      ?.map((e) => jsonEncode(MediaItemMessage(
    id: e.id,
    album: e.album,
    title: e.title,
    artist: e.artist,
    duration: e.duration,
    artUri: e.artUri,
    extras: e.extras,
  ).toMap()))
      .toList() ??
      [];
}
