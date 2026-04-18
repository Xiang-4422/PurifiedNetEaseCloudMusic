import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/common/lyric_parser/parser_lrc.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/features/playback/repository/playback_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bujuan/common/constants/other.dart';
import 'settings_controller.dart';
import 'user_controller.dart';

/// 播放控制器
/// 负责音频播放、进度、歌词、循环模式等
class PlayerController extends GetxController {
  static PlayerController get to => Get.find();

  Box box = GetIt.instance<Box>();
  final PlaybackRepository _repository = PlaybackRepository();
  late final AudioServiceHandler audioHandler;

  /// 播放状态
  RxBool isPlaying = false.obs;

  /// 循环方式
  Rx<AudioServiceRepeatMode> curRepeatMode = AudioServiceRepeatMode.all.obs;

  /// 当前播放模式
  Rx<PlaybackMode> playbackMode = PlaybackMode.playlist.obs;

  // Album color cache
  final Map<String, Color> _albumColorCache = {};

  // Roaming Mode fetch lock
  bool _isFetchingFm = false;

  // Forward compatibility getters
  bool get isFmModeValue => playbackMode.value == PlaybackMode.roaming;
  RxBool get isFmMode => (playbackMode.value == PlaybackMode.roaming).obs;

  bool get isHeartBeatModeValue => playbackMode.value == PlaybackMode.heartbeat;
  RxBool get isHeartBeatMode =>
      (playbackMode.value == PlaybackMode.heartbeat).obs;

  /// 正在播放喜欢的音乐
  RxBool isPlayingLikedSongs = false.obs;

  /// 当前播放列表
  RxList<MediaItem> curPlayingSongs = <MediaItem>[].obs;
  RxString curPlayListName = "".obs;
  RxString curPlayListNameHeader = "".obs;

  /// 当前播放歌曲
  Rx<MediaItem> curPlayingSong =
      const MediaItem(id: '', title: '暂无', duration: Duration(seconds: 10)).obs;

  /// 当前播放索引
  RxInt curPlayIndex = 0.obs;

  /// 当前播放进度
  Rx<Duration> curPlayDuration = Duration.zero.obs;

  // --- 歌词 ---
  /// 解析后的歌词数组
  RxList<LyricsLineModel> lyricsLineModels = <LyricsLineModel>[].obs;

  /// 是否有翻译歌词
  RxBool hasTransLyrics = false.obs;

  /// 当前歌词下标
  RxInt currLyricIndex = (-1).obs;

  /// 沉浸式歌词相关
  Timer? _fullScreenLyricTimer;
  RxBool isFullScreenLyricOpen = false.obs;
  double _fullScreenLyricTimerCounter = 0.0;

  @override
  void onReady() {
    super.onReady();
    _initAudioHandler();
  }

  Future<void> _initAudioHandler() async {
    audioHandler = await AudioService.init(
      builder: () => AudioServiceHandler(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.yu4422.purrr.channel.audio',
        androidNotificationChannelName: 'Music playback',
        androidNotificationIcon: 'drawable/audio_service_like',
      ),
    );

    // --- 初始化监听 ---

    // 监听播放列表切换
    audioHandler.queue.listen((mediaItems) async {
      curPlayingSongs
        ..clear()
        ..addAll(mediaItems);
      // 处理仅更新播放列表的情况，重新计算并更新curPlayIndex
      await _updateCurPlayIndex(curMediaItemUpdated: false);
    });

    // 监听歌曲切换
    audioHandler.mediaItem.listen((mediaItem) async {
      // 更新当前歌曲信息
      if (mediaItem == null) return;
      curPlayingSong.value = mediaItem;
      // 本地保存当前播放状态
      box.put(curPlaySongId, mediaItem.id);
      await _updateCurPlayIndex();

      // 播放模式自动拉取逻辑
      int newIndex = curPlayingSongs
          .indexWhere((element) => element.id == curPlayingSong.value.id);

      // Roaming Mode Fetching
      if (playbackMode.value == PlaybackMode.roaming &&
          newIndex >= curPlayingSongs.length - 2 &&
          !_isFetchingFm) {
        _isFetchingFm = true;
        UserController.to.getFmSongs().then((newFmPlayList) async {
          if (playbackMode.value == PlaybackMode.roaming &&
              newFmPlayList.isNotEmpty) {
            // Deduplicate
            var existingIds = curPlayingSongs.map((e) => e.id).toSet();
            newFmPlayList.removeWhere((item) => existingIds.contains(item.id));

            if (newFmPlayList.isNotEmpty) {
              List<MediaItem> combined = [...curPlayingSongs, ...newFmPlayList];
              // Optional: keep last 100 as history if queue gets too long
              if (combined.length > 200) {
                combined.removeRange(0, combined.length - 150);
              }

              // Find current index in new list (it might have shifted if we trimmed history)
              int updatedIndex =
                  combined.indexWhere((e) => e.id == curPlayingSong.value.id);

              // If we were at the very end and playback completed, we should trigger the next one after adding
              bool shouldAutoPlayNext =
                  (newIndex == curPlayingSongs.length - 1) &&
                      (audioHandler.playbackState.value.processingState ==
                          AudioProcessingState.completed);

              await audioHandler.changePlayList(combined,
                  index: updatedIndex != -1 ? updatedIndex : newIndex,
                  playListName: "漫游模式",
                  playListNameHeader: "漫游",
                  playNow: false,
                  changePlayerSource: false,
                  needStore: false);

              if (shouldAutoPlayNext) {
                // Get the new index again as it might have been set by changePlayList
                int nextIndex =
                    (updatedIndex != -1 ? updatedIndex : newIndex) + 1;
                if (nextIndex < combined.length) {
                  audioHandler.playIndex(
                      audioSourceIndex: nextIndex, playNow: true);
                }
              }
            }
          }
          _isFetchingFm = false;
        }).catchError((e) {
          _isFetchingFm = false;
        });
      }

      // Heartbeat Mode Fetching (To be implemented or migrated strictly here if needed)
      // Currently assuming similar behavior or handled by initial fetch,
      // but logic can be added here for infinite scroll in heartbeat mode.
    });

    // 监听播放状态变化
    audioHandler.playbackState.listen((playbackState) {
      isPlaying.value = playbackState.playing;
      updateFullScreenLyricTimerCounter(cancelTimer: isPlaying.isFalse);
      if (playbackState.processingState == AudioProcessingState.completed) {
        audioHandler.skipToNext();
      }
    });

    // 监听播放进度变化
    // 监听播放进度变化 - 降低频率 (从 800us 改为 200ms) 以释放 UI 线程
    AudioService.createPositionStream(
            minPeriod: const Duration(milliseconds: 200), steps: 1000)
        .listen((newCurPlayingDuration) async {
      curPlayDuration.value = newCurPlayingDuration;
      // 找不到当前时间对应的歌词，此时newLyricIndex为-1，表示为前奏阶段，刚好显示空白
      int newLyricIndex = lyricsLineModels.lastIndexWhere((element) =>
          element.startTime! <= newCurPlayingDuration.inMilliseconds);

      if (newLyricIndex != currLyricIndex.value) {
        currLyricIndex.value = newLyricIndex;
      }
    });

    // --- 从本地恢复上次关闭播放状态 ---
    await audioHandler.restoreLastPlayState();
  }

  /// 监听歌单和歌曲变化时更新当前播放索引
  _updateCurPlayIndex({bool curMediaItemUpdated = true}) async {
    curPlayIndex.value = curPlayingSongs
        .indexWhere((element) => element.id == curPlayingSong.value.id);
    if (curMediaItemUpdated) {
      // 关键优化：使用 microtask 或延迟执行耗时任务，让 PageView 动画能先跑起来
      Future.microtask(() async {
        // 预加载接下来几首歌的封面
        _preloadImages();
        // 更新背景颜色 - 委托给 SettingsController
        await _updateAlbumColor();
        // 更新歌词
        await _updateLyric();
      });
    }
  }

  /// 获取专辑颜色 (更新 SettingsController)
  _updateAlbumColor() async {
    String? imageUrl = curPlayingSong.value.extras?['image'];
    if (imageUrl != null) {
      Color color;
      if (_albumColorCache.containsKey(imageUrl)) {
        color = _albumColorCache[imageUrl]!;
      } else {
        color = await OtherUtils.getImageColor(imageUrl);
        // Simple cache size limit
        if (_albumColorCache.length > 20) {
          _albumColorCache.remove(_albumColorCache.keys.first);
        }
        _albumColorCache[imageUrl] = color;
      }

      SettingsController.to.albumColor.value = color;
      SettingsController.to.panelWidgetColor.value =
          color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }
  }

  _updateLyric() async {
    lyricsLineModels.clear();
    hasTransLyrics.value = false;

    String songId = curPlayingSong.value.id;
    String lyric = box.get('lyric_$songId') ?? '';
    String lyricTran = box.get('lyricTran_$songId') ?? '';
    if (lyric.isEmpty) {
      SongLyricWrap songLyricWrap =
          await _repository.fetchSongLyric(curPlayingSong.value.id);
      lyric = songLyricWrap.lrc.lyric ?? "";
      lyricTran = songLyricWrap.tlyric.lyric ?? "";
      box.put('lyric_$songId', lyric);
      box.put('lyricTran_$songId', lyricTran);
    }
    if (lyric.isNotEmpty) {
      var mainLyricsLineModels = ParserLrc(lyric).parseLines();
      if (lyricTran.isNotEmpty) {
        hasTransLyrics.value = true;
        var extLyricsLineModels = ParserLrc(lyricTran).parseLines();
        for (LyricsLineModel lyricsLineModel in extLyricsLineModels) {
          int index = mainLyricsLineModels.indexWhere(
              (element) => element.startTime == lyricsLineModel.startTime);
          if (index != -1) {
            mainLyricsLineModels[index].extText = lyricsLineModel.mainText;
          }
        }
      }
      lyricsLineModels.addAll(mainLyricsLineModels);
    } else {
      lyricsLineModels.add(LyricsLineModel()
        ..mainText = "没歌词哦～"
        ..startTime = 0);
    }

    currLyricIndex.value = -1;
  }

  playOrPause() async {
    isPlaying.value ? await audioHandler.pause() : await audioHandler.play();
  }

  Future<void> switchMode(PlaybackMode newMode, {dynamic contextData}) async {
    if (playbackMode.value == newMode && newMode != PlaybackMode.playlist) {
      if (isPlaying.isFalse) await playOrPause();
      return;
    }

    playbackMode.value = newMode;

    switch (newMode) {
      case PlaybackMode.roaming:
        await _initRoamingMode();
        break;
      case PlaybackMode.heartbeat:
        if (contextData is Map && contextData.containsKey('startSongId')) {
          await _initHeartBeatMode(
              contextData['startSongId'], contextData['fromPlayAll'] ?? true);
        }
        break;
      case PlaybackMode.playlist:
        // Playlist switching is usually handled by `playNewPlayList` directly calling audioHandler.
        // We might want to centralize that here too eventually.
        break;
    }
  }

  Future<void> _initRoamingMode() async {
    List<MediaItem> fmSongs = [];
    if (UserController.to.fmSongs.isNotEmpty) {
      fmSongs.addAll(UserController.to.fmSongs);
    } else {
      fmSongs.addAll(await UserController.to.getFmSongs());
    }

    if (fmSongs.isNotEmpty) {
      await audioHandler.changePlayList(fmSongs,
          index: 0,
          playListName: "漫游模式",
          playListNameHeader: "漫游",
          changePlayerSource: true,
          playNow: true,
          needStore: false);
      // Force repeat all for continuous fetch
      if (curRepeatMode.value == AudioServiceRepeatMode.one) {
        await audioHandler.changeRepeatMode(
            newRepeatMode: AudioServiceRepeatMode.all);
      }
    } else {
      // Fallback or error
      playbackMode.value = PlaybackMode.playlist;
    }
  }

  Future<void> _initHeartBeatMode(String startSongId, bool fromPlayAll) async {
    List<MediaItem> songs = await UserController.to.getHeartBeatSongs(
        startSongId, UserController.to.randomLikedSongId.value, fromPlayAll);

    if (songs.isNotEmpty) {
      await audioHandler.changePlayList(songs,
          index: 0,
          playListName: "心动模式",
          playListNameHeader: "心动",
          changePlayerSource: true,
          playNow: true,
          needStore: false);
      if (curRepeatMode.value == AudioServiceRepeatMode.one) {
        await audioHandler.changeRepeatMode(
            newRepeatMode: AudioServiceRepeatMode.all);
      }
    } else {
      playbackMode.value = PlaybackMode.playlist;
    }
  }

  /// 获取当前循环icon
  IconData getRepeatIcon() {
    IconData icon;
    if (playbackMode.value == PlaybackMode.roaming) {
      icon = TablerIcons.radio;
    } else if (playbackMode.value == PlaybackMode.heartbeat) {
      icon = TablerIcons.heartbeat;
    } else {
      switch (curRepeatMode.value) {
        case AudioServiceRepeatMode.one:
          icon = TablerIcons.repeat_once;
          break;
        case AudioServiceRepeatMode.none:
          icon = TablerIcons.arrows_shuffle;
          break;
        case AudioServiceRepeatMode.all:
        case AudioServiceRepeatMode.group:
          icon = TablerIcons.repeat;
          break;
      }
    }
    return icon;
  }

  updateFullScreenLyricTimerCounter({bool cancelTimer = false}) {
    double closeTime = 5000;
    if (cancelTimer) {
      _fullScreenLyricTimerCounter = 0;
      if (_fullScreenLyricTimer != null) _fullScreenLyricTimer!.cancel();
      isFullScreenLyricOpen.value = false;
    } else if (isPlaying.isTrue) {
      if (_fullScreenLyricTimer == null || !_fullScreenLyricTimer!.isActive) {
        _fullScreenLyricTimerCounter = closeTime;
        _fullScreenLyricTimer =
            Timer.periodic(const Duration(milliseconds: 50), (timer) {
          _fullScreenLyricTimerCounter -= 50;
          if (_fullScreenLyricTimerCounter <= 0) {
            _fullScreenLyricTimerCounter = 0;
            timer.cancel();
            isFullScreenLyricOpen.value = true;
          }
        });
      } else {
        _fullScreenLyricTimerCounter = closeTime;
      }
    }
  }

  void _preloadImages() {
    if (curPlayingSongs.isEmpty) return;
    int currentIndex = curPlayIndex.value;
    if (currentIndex < 0) return;

    List<int> indicesToPreload = [];
    for (int i = 1; i <= 3; i++) {
      indicesToPreload.add((currentIndex + i) % curPlayingSongs.length);
      indicesToPreload.add(
          (currentIndex - i + curPlayingSongs.length) % curPlayingSongs.length);
    }

    for (int index in indicesToPreload) {
      String? imageUrl = curPlayingSongs[index].extras?['image'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        String fullUrl = '$imageUrl?param=500y500';
        try {
          precacheImage(
              CachedNetworkImageProvider(fullUrl, headers: const {
                'User-Agent':
                    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 Edg/117.0.2045.35'
              }),
              Get.context!);
        } catch (_) {
          // 封面预取只影响滚动流畅度，不应该打断播放或页面渲染。
        }
      }
    }
  }

}
