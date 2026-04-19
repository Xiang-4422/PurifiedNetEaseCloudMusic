import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/common/lyric_parser/parser_lrc.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/playback/playback_state_store.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'package:bujuan/common/constants/other.dart';

/// 面向页面暴露播放状态和播放模式切换入口。
///
/// 底层播放细节仍由 `PlaybackService -> AudioServiceHandler` 承接，这里主要负责把
/// 音频服务、歌词状态、全屏歌词状态和用户侧模式切换组织成可绑定的 UI 状态。
class PlayerController extends GetxController {
  static PlayerController get to => Get.find();

  final PlaybackRepository _repository = PlaybackRepository();
  final PlaybackService _playbackService = Get.find<PlaybackService>();
  final PlaybackStateStore _stateStore = const PlaybackStateStore();

  PlaybackService get playbackService => _playbackService;

  RxBool isPlaying = false.obs;

  Rx<AudioServiceRepeatMode> curRepeatMode = AudioServiceRepeatMode.all.obs;

  Rx<PlaybackMode> playbackMode = PlaybackMode.playlist.obs;

  /// 旧页面还在直接订阅多个散落字段，这里先保留兼容字段，同时补一份统一会话状态。
  final Rx<PlaybackSessionState> sessionState =
      const PlaybackSessionState().obs;

  // 取色是高频但纯展示性质的操作，做小缓存可以明显减少切歌时的同步卡顿。
  final Map<String, Color> _albumColorCache = {};

  // 漫游模式的补队列是异步请求，锁住重复触发可以避免同一首歌附近连续补多次。
  bool _isFetchingFm = false;

  bool get isFmModeValue => playbackMode.value == PlaybackMode.roaming;
  RxBool get isFmMode => (playbackMode.value == PlaybackMode.roaming).obs;

  bool get isHeartBeatModeValue => playbackMode.value == PlaybackMode.heartbeat;
  RxBool get isHeartBeatMode =>
      (playbackMode.value == PlaybackMode.heartbeat).obs;

  RxBool isPlayingLikedSongs = false.obs;

  RxList<MediaItem> curPlayingSongs = <MediaItem>[].obs;
  RxString curPlayListName = "".obs;
  RxString curPlayListNameHeader = "".obs;

  Rx<MediaItem> curPlayingSong =
      const MediaItem(id: '', title: '暂无', duration: Duration(seconds: 10)).obs;

  RxInt curPlayIndex = 0.obs;

  Rx<Duration> curPlayDuration = Duration.zero.obs;

  RxList<LyricsLineModel> lyricsLineModels = <LyricsLineModel>[].obs;

  RxBool hasTransLyrics = false.obs;

  RxInt currLyricIndex = (-1).obs;

  Timer? _fullScreenLyricTimer;
  RxBool isFullScreenLyricOpen = false.obs;
  double _fullScreenLyricTimerCounter = 0.0;
  int _lastStoredPositionSecond = -1;

  @override
  void onReady() {
    super.onReady();
    _initAudioHandler();
  }

  /// 统一接管音频服务的状态流，避免页面各自监听 `AudioService` 形成重复副作用。
  Future<void> _initAudioHandler() async {
    _playbackService.bindControllerState(
      onRestorePlaybackMode: (mode) => _syncSessionState(playbackMode: mode),
      onRepeatModeChanged: (mode) => _syncSessionState(repeatMode: mode),
      onPlaylistMetaChanged: (playlistName, playlistHeader, isLikedSongs) {
        _syncSessionState(
          playlistName: playlistName,
          playlistHeader: playlistHeader,
          isPlayingLikedSongs: isLikedSongs,
        );
      },
      isHighQualityEnabled: () =>
          SettingsController.to.isHighSoundQualityOpen.value,
      onToggleLike: UserController.to.toggleLikeStatus,
      isPlaylistMode: () => playbackMode.value == PlaybackMode.playlist,
      isRoamingMode: () => playbackMode.value == PlaybackMode.roaming,
    );
    await _playbackService.ensureInitialized();

    _playbackService.queueStream.listen((mediaItems) async {
      curPlayingSongs
        ..clear()
        ..addAll(mediaItems);
      await _updateCurPlayIndex(curMediaItemUpdated: false);
    });

    _playbackService.mediaItemStream.listen((mediaItem) async {
      if (mediaItem == null) return;
      curPlayingSong.value = mediaItem;
      _stateStore.saveCurrentSongId(mediaItem.id);
      await _updateCurPlayIndex();

      int newIndex = curPlayingSongs
          .indexWhere((element) => element.id == curPlayingSong.value.id);

      if (playbackMode.value == PlaybackMode.roaming &&
          newIndex >= curPlayingSongs.length - 2 &&
          !_isFetchingFm) {
        _isFetchingFm = true;
        UserController.to.getFmSongs().then((newFmPlayList) async {
          if (playbackMode.value == PlaybackMode.roaming &&
              newFmPlayList.isNotEmpty) {
            final shouldAutoPlayNext = (newIndex ==
                    curPlayingSongs.length - 1) &&
                (_playbackService.handler.playbackState.value.processingState ==
                    AudioProcessingState.completed);

            await _playbackService.appendRoamingSongs(
              currentQueue: curPlayingSongs.toList(),
              incomingSongs: newFmPlayList,
              currentSongId: curPlayingSong.value.id,
              shouldAutoPlayNext: shouldAutoPlayNext,
              fallbackIndex: newIndex,
            );
          }
          _isFetchingFm = false;
        }).catchError((e) {
          _isFetchingFm = false;
        });
      }
    });

    _playbackService.playbackStateStream.listen((playbackState) {
      isPlaying.value = playbackState.playing;
      updateFullScreenLyricTimerCounter(cancelTimer: isPlaying.isFalse);
      if (playbackState.processingState == AudioProcessingState.completed) {
        _playbackService.skipToNext();
      }
    });

    // 进度流过密会把歌词滚动和面板动画一起拖慢，这里宁可牺牲一点歌词精度，
    // 也优先保证滑动和切歌时的流畅度。
    AudioService.createPositionStream(
            minPeriod: const Duration(milliseconds: 200), steps: 1000)
        .listen((newCurPlayingDuration) async {
      curPlayDuration.value = newCurPlayingDuration;
      final currentSecond = newCurPlayingDuration.inSeconds;
      if (currentSecond != _lastStoredPositionSecond) {
        _lastStoredPositionSecond = currentSecond;
        unawaited(_stateStore.savePlaybackPosition(newCurPlayingDuration));
      }
      int newLyricIndex = lyricsLineModels.lastIndexWhere((element) =>
          element.startTime! <= newCurPlayingDuration.inMilliseconds);

      if (newLyricIndex != currLyricIndex.value) {
        currLyricIndex.value = newLyricIndex;
      }
    });

    await _playbackService.restoreLastPlayState();
  }

  void _syncSessionState({
    PlaybackMode? playbackMode,
    AudioServiceRepeatMode? repeatMode,
    String? playlistName,
    String? playlistHeader,
    bool? isPlayingLikedSongs,
  }) {
    final nextState = sessionState.value.copyWith(
      playbackMode: playbackMode,
      repeatMode: repeatMode,
      playlistName: playlistName,
      playlistHeader: playlistHeader,
      isPlayingLikedSongs: isPlayingLikedSongs,
    );
    sessionState.value = nextState;
    this.playbackMode.value = nextState.playbackMode;
    curRepeatMode.value = nextState.repeatMode;
    curPlayListName.value = nextState.playlistName;
    curPlayListNameHeader.value = nextState.playlistHeader;
    this.isPlayingLikedSongs.value = nextState.isPlayingLikedSongs;
    unawaited(_stateStore.savePlaybackMode(nextState.playbackMode));
  }

  _updateCurPlayIndex({bool curMediaItemUpdated = true}) async {
    curPlayIndex.value = curPlayingSongs
        .indexWhere((element) => element.id == curPlayingSong.value.id);
    if (curMediaItemUpdated) {
      // 切歌时先让索引和主播放状态更新到 UI，再延后取色、歌词和图片预取，
      // 否则首页大面板和歌词页切换会先被这些耗时任务阻塞。
      Future.microtask(() async {
        _preloadImages();
        await _updateAlbumColor();
        await _updateLyric();
      });
    }
  }

  _updateAlbumColor() async {
    String? imageUrl = curPlayingSong.value.extras?['image'];
    if (imageUrl != null) {
      Color color;
      if (_albumColorCache.containsKey(imageUrl)) {
        color = _albumColorCache[imageUrl]!;
      } else {
        color = await OtherUtils.getImageColor(imageUrl);
        // 这里只做很小的缓存就够了，再大只会把“展示态颜色”变成长期驻留内存。
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

  /// 先读本地歌词缓存，再读下载后的本地歌词文件，最后才回退到远程歌词入口。
  ///
  /// 这个顺序直接决定离线可用性，不能为了“看起来统一”就把本地文件读取删掉。
  _updateLyric() async {
    lyricsLineModels.clear();
    hasTransLyrics.value = false;

    String songId = curPlayingSong.value.id;
    String lyric = _stateStore.getLyric(songId) ?? '';
    String lyricTran = _stateStore.getTranslatedLyric(songId) ?? '';
    if (lyric.isEmpty) {
      final localLyricsPath =
          curPlayingSong.value.extras?['localLyricsPath'] as String? ?? '';
      if (localLyricsPath.isNotEmpty && File(localLyricsPath).existsSync()) {
        lyric = await File(localLyricsPath).readAsString();
      }
    }
    if (lyric.isEmpty) {
      final lyrics =
          await _repository.fetchSongLyrics(curPlayingSong.value.id) ??
              const TrackLyrics();
      lyric = lyrics.main;
      lyricTran = lyrics.translated;
      await _stateStore.saveLyrics(
        songId: songId,
        lyric: lyric,
        translatedLyric: lyricTran,
      );
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
    isPlaying.value
        ? await _playbackService.pause()
        : await _playbackService.play();
  }

  /// 播放列表切换先统一走播放控制器，避免页面继续直接触碰 `audioHandler`
  /// 并各自处理模式退出逻辑。
  Future<void> playPlaylist(
    List<MediaItem> playList,
    int index, {
    String playListName = "无名歌单",
    String playListNameHeader = "",
  }) async {
    if (isFmMode.isTrue) {
      await quitFmMode(showToast: false);
    }
    if (isHeartBeatMode.isTrue) {
      await quitHeartBeatMode(showToast: false);
    }
    await _playbackService.playPlaylist(
      playList,
      index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
    );
  }

  Future<void> playQueueIndex(int index) {
    return _playbackService.playIndex(audioSourceIndex: index, playNow: true);
  }

  Future<void> seekTo(Duration position) {
    return _playbackService.seek(position);
  }

  Future<void> skipToPreviousTrack() {
    return _playbackService.skipToPrevious();
  }

  Future<void> skipToNextTrack() {
    return _playbackService.skipToNext();
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
    return _playbackService.changeRepeatMode(newRepeatMode: repeatMode);
  }

  Future<void> cycleRepeatMode() {
    return _playbackService.changeRepeatMode();
  }

  Future<void> openFmMode() async {
    await switchMode(PlaybackMode.roaming);
  }

  Future<void> quitFmMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出漫游模式');
    if (playbackMode.value == PlaybackMode.roaming) {
      _syncSessionState(playbackMode: PlaybackMode.playlist);
    }
  }

  Future<void> openHeartBeatMode(
    String startSongId, {
    required bool fromPlayAll,
  }) async {
    if (startSongId.isEmpty) return;
    await switchMode(
      PlaybackMode.heartbeat,
      contextData: {
        'startSongId': startSongId,
        'fromPlayAll': fromPlayAll,
      },
    );
  }

  Future<void> quitHeartBeatMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出心动模式');
    if (playbackMode.value == PlaybackMode.heartbeat) {
      _syncSessionState(playbackMode: PlaybackMode.playlist);
    }
  }

  Future<void> playUserLikedSongs() async {
    await _playbackService.playLikedSongs(
      likedSongs: UserController.to.likedSongs.toList(),
      likedSongIds: UserController.to.likedSongIds.toList(),
      currentSong: curPlayingSong.value,
    );
  }

  /// 重复模式按钮的行为已经带上“退出心动模式并回到喜欢歌单”等业务规则，
  /// 放在页面里会持续复制分支并让播放模式判断再次散落。
  Future<void> handleRepeatModeTap() async {
    if (isFmMode.isTrue) {
      return;
    }
    if (isHeartBeatMode.isTrue) {
      quitHeartBeatMode();
      await setRepeatMode(AudioServiceRepeatMode.all);
      await playUserLikedSongs();
      return;
    }
    if (isPlayingLikedSongs.isTrue &&
        _playbackService.handler.curRepeatMode == AudioServiceRepeatMode.none) {
      await openHeartBeatMode(
        curPlayingSong.value.id,
        fromPlayAll: false,
      );
      return;
    }
    await cycleRepeatMode();
  }

  Future<void> switchMode(PlaybackMode newMode, {dynamic contextData}) async {
    if (playbackMode.value == newMode && newMode != PlaybackMode.playlist) {
      if (isPlaying.isFalse) await playOrPause();
      return;
    }

    _syncSessionState(playbackMode: newMode);

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
        // 播放列表模式本身不需要额外初始化，真正的队列切换统一通过播放入口完成。
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

    final started = await _playbackService.startRoamingMode(
      fmSongs: fmSongs,
      currentRepeatMode: curRepeatMode.value,
    );
    if (!started) {
      // Fallback or error
      _syncSessionState(playbackMode: PlaybackMode.playlist);
    }
  }

  Future<void> _initHeartBeatMode(String startSongId, bool fromPlayAll) async {
    List<MediaItem> songs = await UserController.to.getHeartBeatSongs(
        startSongId, UserController.to.randomLikedSongId.value, fromPlayAll);

    final started = await _playbackService.startHeartBeatMode(
      songs: songs,
      currentRepeatMode: curRepeatMode.value,
    );
    if (!started) {
      _syncSessionState(playbackMode: PlaybackMode.playlist);
    }
  }

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
          // 预取失败只影响切歌时的观感，不能让展示层优化反过来干扰播放主链路。
        }
      }
    }
  }
}
