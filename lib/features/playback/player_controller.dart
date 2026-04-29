import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_artwork_presenter.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
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

  PlayerController({
    required PlaybackService playbackService,
    required PlaybackQueueStore queueStore,
    required PlaybackQueueCoordinator queueCoordinator,
    required PlaybackModeCoordinator modeCoordinator,
    required PlaybackUserContentPort userContentPort,
    required PlaybackLyricsPresenter lyricsPresenter,
    required PlaybackArtworkPresenter artworkPresenter,
    required CurrentTrackDownloadUseCase downloadUseCase,
  })  : _playbackService = playbackService,
        _queueStore = queueStore,
        _queueCoordinator = queueCoordinator,
        _modeCoordinator = modeCoordinator,
        _userContentPort = userContentPort,
        _lyricsPresenter = lyricsPresenter,
        _artworkPresenter = artworkPresenter,
        _downloadUseCase = downloadUseCase;

  final PlaybackService _playbackService;
  final PlaybackQueueStore _queueStore;
  final PlaybackQueueCoordinator _queueCoordinator;
  final PlaybackModeCoordinator _modeCoordinator;
  final PlaybackUserContentPort _userContentPort;
  final PlaybackLyricsPresenter _lyricsPresenter;
  final PlaybackArtworkPresenter _artworkPresenter;
  final CurrentTrackDownloadUseCase _downloadUseCase;

  PlaybackService get playbackService => _playbackService;

  RxBool isPlaying = false.obs;

  Rx<AudioServiceRepeatMode> curRepeatMode = AudioServiceRepeatMode.all.obs;

  Rx<PlaybackMode> playbackMode = PlaybackMode.playlist.obs;

  final Rx<PlaybackSessionState> sessionState =
      const PlaybackSessionState().obs;
  final Rx<PlaybackRuntimeState> runtimeState =
      const PlaybackRuntimeState().obs;
  final Rx<PlaybackLyricState> lyricState = const PlaybackLyricState().obs;
  final Rx<PlaybackQueueItem> currentSongState =
      const PlaybackQueueItem.empty().obs;
  final Rx<Duration> currentPositionState = Duration.zero.obs;
  final RxList<PlaybackQueueItem> queueState = <PlaybackQueueItem>[].obs;
  final RxInt currentQueueIndex = (-1).obs;

  // 漫游模式的补队列是异步请求，锁住重复触发可以避免同一首歌附近连续补多次。
  bool _isFetchingFm = false;

  bool get isFmModeValue => playbackMode.value == PlaybackMode.roaming;
  RxBool get isFmMode => (playbackMode.value == PlaybackMode.roaming).obs;

  bool get isHeartBeatModeValue => playbackMode.value == PlaybackMode.heartbeat;
  RxBool get isHeartBeatMode =>
      (playbackMode.value == PlaybackMode.heartbeat).obs;

  Timer? _fullScreenLyricTimer;
  RxBool isFullScreenLyricOpen = false.obs;
  double _fullScreenLyricTimerCounter = 0.0;
  int _lastStoredPositionSecond = -1;
  bool _restoringPlaybackState = false;

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initAudioHandler());
    });
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
      onToggleLike: _toggleLikeFromPlayback,
      isPlaylistMode: () => playbackMode.value == PlaybackMode.playlist,
      isRoamingMode: () => playbackMode.value == PlaybackMode.roaming,
    );
    await _playbackService.ensureInitialized();

    _playbackService.queueStream.listen((queueItems) async {
      _syncRuntimeState(queue: queueItems);
      await _updateCurPlayIndex(currentItemUpdated: false);
    });

    _playbackService.mediaItemStream.listen((queueItem) async {
      if (queueItem == null) return;
      _syncRuntimeState(currentSong: queueItem);
      unawaited(_queueStore.saveCurrentSong(queueItem.id));
      unawaited(_cacheCurrentTrackForPlayback(queueItem));
      await _updateCurPlayIndex(
        currentItemUpdated: !_restoringPlaybackState,
      );
      unawaited(_ensureCurrentTrackArtwork(queueItem));

      final currentRuntimeState = runtimeState.value;
      int newIndex = currentRuntimeState.queue.indexWhere(
          (element) => element.id == currentRuntimeState.currentSong.id);

      if (playbackMode.value == PlaybackMode.roaming &&
          newIndex >= currentRuntimeState.queue.length - 2 &&
          !_isFetchingFm) {
        _isFetchingFm = true;
        _userContentPort.loadFmSongs().then((newFmPlayList) async {
          if (playbackMode.value == PlaybackMode.roaming &&
              newFmPlayList.isNotEmpty) {
            final shouldAutoPlayNext = (newIndex ==
                    currentRuntimeState.queue.length - 1) &&
                (_playbackService.handler.playbackState.value.processingState ==
                    AudioProcessingState.completed);

            await _queueCoordinator.appendRoamingSongs(
              currentQueue: currentRuntimeState.queue,
              incomingSongs: newFmPlayList,
              currentSongId: currentRuntimeState.currentSong.id,
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
      _syncRuntimeState(currentPosition: newCurPlayingDuration);
      final currentSecond = newCurPlayingDuration.inSeconds;
      if (currentSecond != _lastStoredPositionSecond) {
        _lastStoredPositionSecond = currentSecond;
        unawaited(
          _queueStore.savePosition(newCurPlayingDuration),
        );
      }
      int newLyricIndex = lyricState.value.lines.lastIndexWhere((element) =>
          element.startTime! <= newCurPlayingDuration.inMilliseconds);

      if (newLyricIndex != lyricState.value.currentIndex) {
        _syncLyricState(currentIndex: newLyricIndex);
      }
    });

    _restoringPlaybackState = true;
    await _playbackService.restoreLastPlayState();
    _restoringPlaybackState = false;
    await _updateCurPlayIndex();
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
    unawaited(
      _queueStore.savePlaybackMode(nextState.playbackMode),
    );
  }

  void _syncRuntimeState({
    List<PlaybackQueueItem>? queue,
    PlaybackQueueItem? currentSong,
    int? currentIndex,
    Duration? currentPosition,
  }) {
    final nextState = runtimeState.value.copyWith(
      queue: queue,
      currentSong: currentSong,
      currentIndex: currentIndex,
      currentPosition: currentPosition,
    );
    runtimeState.value = nextState;
    if (currentSong != null) {
      currentSongState.value = currentSong;
    }
    if (currentPosition != null &&
        currentPositionState.value != currentPosition) {
      currentPositionState.value = currentPosition;
    }
    if (queue != null) {
      queueState.assignAll(queue);
    }
    if (currentIndex != null && currentQueueIndex.value != currentIndex) {
      currentQueueIndex.value = currentIndex;
    }
  }

  void _syncLyricState({
    List<LyricsLineModel>? lines,
    int? currentIndex,
    bool? hasTranslatedLyrics,
  }) {
    final nextState = lyricState.value.copyWith(
      lines: lines,
      currentIndex: currentIndex,
      hasTranslatedLyrics: hasTranslatedLyrics,
    );
    lyricState.value = nextState;
  }

  _updateCurPlayIndex({bool currentItemUpdated = true}) async {
    final currentRuntimeState = runtimeState.value;
    final currentIndex = currentRuntimeState.queue.indexWhere(
      (element) => element.id == currentRuntimeState.currentSong.id,
    );
    _syncRuntimeState(currentIndex: currentIndex);
    if (currentItemUpdated) {
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
    final currentSong = runtimeState.value.currentSong;
    try {
      final color = await _artworkPresenter.resolveDominantColor(currentSong);
      if (color == null) {
        return;
      }
      SettingsController.to.albumColor.value = color;
      SettingsController.to.panelWidgetColor.value =
          color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    } catch (_) {
      // 取色失败只影响播放器氛围色，不能阻断后续歌词等展示态更新。
    }
  }

  /// 先读本地歌词缓存，再读下载后的本地歌词文件，最后才回退到远程歌词入口。
  ///
  /// 这个顺序直接决定离线可用性；歌词内容现在走媒体库存储，不再继续塞进恢复态轻存储。
  _updateLyric() async {
    _syncLyricState(lines: const [], hasTranslatedLyrics: false);
    lyricState.value =
        await _lyricsPresenter.loadLyrics(runtimeState.value.currentSong);
  }

  playOrPause() async {
    isPlaying.value
        ? await _playbackService.pause()
        : await _playbackService.play();
  }

  /// 播放列表切换先统一走播放控制器，避免页面继续直接触碰 `audioHandler`
  /// 并各自处理模式退出逻辑。
  Future<void> playPlaylist(
    List<PlaybackQueueItem> playList,
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

  Future<void> updatePlaybackQueueItem(PlaybackQueueItem item) async {
    final queue = runtimeState.value.queue
        .map((queueItem) => queueItem.id == item.id ? item : queueItem)
        .toList(growable: false);
    _syncRuntimeState(
      queue: queue,
      currentSong: runtimeState.value.currentSong.id == item.id ? item : null,
    );
    await _playbackService.updateQueueItem(item);
  }

  Future<void> _toggleLikeFromPlayback(PlaybackQueueItem item) async {
    final updatedItem = await _userContentPort.toggleLikeStatus(item);
    if (updatedItem != null) {
      await updatePlaybackQueueItem(updatedItem);
    }
  }

  /// 下载入口直接挂在播放控制器，是为了让“当前播放歌曲”的下载状态与播放 UI
  /// 保持同一条事实链路；否则下载完成后页面仍会继续展示旧的远程资源状态。
  Future<Track?> downloadCurrentTrack({
    bool preferHighQuality = true,
  }) async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return downloadTrackById(
      currentSong.id,
      preferHighQuality: preferHighQuality,
    );
  }

  Future<Track?> removeCurrentTrackDownload() async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return removeDownloadedTrackById(currentSong.id);
  }

  Future<Track?> cancelCurrentTrackDownload() async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return cancelTrackDownloadById(currentSong.id);
  }

  Future<Track?> retryCurrentTrackDownload({
    bool preferHighQuality = true,
  }) async {
    final currentSong = runtimeState.value.currentSong;
    if (currentSong.id.isEmpty) {
      return null;
    }
    return retryTrackDownloadById(
      currentSong.id,
      preferHighQuality: preferHighQuality,
    );
  }

  Future<Track?> downloadTrackById(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final result = await _downloadUseCase.downloadTrackById(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<Track?> removeDownloadedTrackById(String trackId) async {
    final result = await _downloadUseCase.removeDownloadedTrackById(trackId);
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<Track?> cancelTrackDownloadById(String trackId) async {
    final result = await _downloadUseCase.cancelTrackDownloadById(trackId);
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<Track?> retryTrackDownloadById(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final result = await _downloadUseCase.retryTrackDownloadById(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    await _syncDownloadResultIfCurrent(result);
    return result?.track;
  }

  Future<void> queueTrackDownloads(
    Iterable<String> trackIds, {
    bool preferHighQuality = true,
  }) {
    return _downloadUseCase.queueTrackDownloads(
      trackIds,
      preferHighQuality: preferHighQuality,
    );
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
    await _modeCoordinator.playLikedSongs(
      currentSong: runtimeState.value.currentSong,
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
    if (sessionState.value.isPlayingLikedSongs &&
        _playbackService.handler.curRepeatMode == AudioServiceRepeatMode.none) {
      await openHeartBeatMode(
        runtimeState.value.currentSong.id,
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
    final started = await _modeCoordinator.startRoamingMode(
      currentRepeatMode: sessionState.value.repeatMode,
    );
    if (!started) {
      // Fallback or error
      _syncSessionState(playbackMode: PlaybackMode.playlist);
    }
  }

  Future<void> _initHeartBeatMode(String startSongId, bool fromPlayAll) async {
    final started = await _modeCoordinator.startHeartBeatMode(
      startSongId: startSongId,
      fromPlayAll: fromPlayAll,
      currentRepeatMode: sessionState.value.repeatMode,
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

  Future<void> _syncDownloadResultIfCurrent(
    CurrentTrackDownloadResult? result,
  ) async {
    if (result == null ||
        runtimeState.value.currentSong.id != result.track.id ||
        result.queueItem == null) {
      return;
    }
    await _syncCurrentQueueItem(result.queueItem!);
  }

  Future<void> _ensureCurrentTrackArtwork(PlaybackQueueItem item) async {
    final updatedItem = await _artworkPresenter.resolveMissingArtwork(item);
    if (updatedItem == null || runtimeState.value.currentSong.id != item.id) {
      return;
    }
    await _syncCurrentQueueItem(updatedItem);
    await _updateAlbumColor();
  }

  Future<void> _syncCurrentQueueItem(PlaybackQueueItem updatedItem) async {
    final queue = runtimeState.value.queue
        .map((item) => item.id == updatedItem.id ? updatedItem : item)
        .toList(growable: false);
    _syncRuntimeState(
      queue: queue,
      currentSong: updatedItem,
    );
    await _playbackService.updateQueueItem(updatedItem);
  }

  Future<void> _cacheCurrentTrackForPlayback(PlaybackQueueItem item) async {
    if (item.id.isEmpty ||
        item.mediaType == MediaType.local ||
        item.mediaType == MediaType.neteaseCache) {
      return;
    }
    final updatedItem = await _downloadUseCase.cacheTrackForPlayback(
      item.id,
      preferHighQuality: _isHighQualityEnabled(),
    );
    if (updatedItem != null && runtimeState.value.currentSong.id == item.id) {
      await _syncCurrentQueueItem(updatedItem);
    }
  }

  bool _isHighQualityEnabled() {
    return SettingsController.to.isHighSoundQualityOpen.value;
  }

  void _preloadImages() {
    if (isPlaying.isFalse) {
      return;
    }
    final currentRuntimeState = runtimeState.value;
    _artworkPresenter.preloadQueueArtwork(
      queue: currentRuntimeState.queue,
      currentIndex: currentRuntimeState.currentIndex,
      context: Get.context,
    );
  }
}
