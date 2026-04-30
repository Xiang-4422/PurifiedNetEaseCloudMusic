import 'dart:async';
import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_theme_port.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/application/playback_mode_command_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_state_synchronizer.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_artwork_page_item.dart';
import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:bujuan/features/playback/playback_session_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

part 'player_download_commands.dart';

/// 面向页面暴露播放状态和播放模式切换入口。
///
/// 底层播放细节仍由 `PlaybackService -> AudioServiceHandler` 承接，这里主要负责把
/// 音频服务、歌词状态、全屏歌词状态和用户侧模式切换组织成可绑定的 UI 状态。
class PlayerController extends GetxController {
  /// 当前播放控制器实例。
  static PlayerController get to => Get.find();

  /// 创建播放控制器。
  PlayerController({
    required PlaybackService playbackService,
    required PlaybackQueueStore queueStore,
    required PlaybackUiCommandService commandService,
    required PlaybackModeCommandService modeCommandService,
    required PlaybackStateSynchronizer stateSynchronizer,
    required PlaybackSelectionService selectionService,
    required CurrentTrackSideEffectCoordinator sideEffectCoordinator,
    required PlaybackLyricUiStateController lyricUiStateController,
    required PlaybackUserContentPort userContentPort,
    required PlaybackLyricsPresenter lyricsPresenter,
    required PlaybackArtworkPresenter artworkPresenter,
    required CurrentTrackDownloadUseCase downloadUseCase,
    required PlaybackThemePort themePort,
  })  : _playbackService = playbackService,
        _queueStore = queueStore,
        _commandService = commandService,
        _modeCommandService = modeCommandService,
        _stateSynchronizer = stateSynchronizer,
        _selectionService = selectionService,
        _sideEffectCoordinator = sideEffectCoordinator,
        _lyricUiStateController = lyricUiStateController,
        _userContentPort = userContentPort,
        _lyricsPresenter = lyricsPresenter,
        _artworkPresenter = artworkPresenter,
        _downloadUseCase = downloadUseCase,
        _themePort = themePort;

  final PlaybackService _playbackService;
  final PlaybackQueueStore _queueStore;
  final PlaybackUiCommandService _commandService;
  final PlaybackModeCommandService _modeCommandService;
  final PlaybackStateSynchronizer _stateSynchronizer;
  final PlaybackSelectionService _selectionService;
  final CurrentTrackSideEffectCoordinator _sideEffectCoordinator;
  final PlaybackLyricUiStateController _lyricUiStateController;
  final PlaybackUserContentPort _userContentPort;
  final PlaybackLyricsPresenter _lyricsPresenter;
  final PlaybackArtworkPresenter _artworkPresenter;
  final CurrentTrackDownloadUseCase _downloadUseCase;
  final PlaybackThemePort _themePort;
  StreamSubscription<PlaybackSelectionState>? _selectionSubscription;
  String? _lastSelectionUiSideEffectKey;

  /// 播放服务门面。
  PlaybackService get playbackService => _playbackService;

  /// 当前是否正在播放。
  RxBool isPlaying = false.obs;

  /// 当前重复播放模式。
  Rx<PlaybackRepeatMode> curRepeatMode = PlaybackRepeatMode.all.obs;

  /// 当前播放模式。
  Rx<PlaybackMode> playbackMode = PlaybackMode.playlist.obs;

  /// 当前播放会话状态。
  final Rx<PlaybackSessionState> sessionState =
      const PlaybackSessionState().obs;

  /// 当前播放运行态。
  final Rx<PlaybackRuntimeState> runtimeState =
      const PlaybackRuntimeState().obs;

  /// 当前 UI 播放选择态。
  final Rx<PlaybackSelectionState> selectionState =
      const PlaybackSelectionState().obs;

  /// 当前歌词状态。
  final Rx<PlaybackLyricState> lyricState = const PlaybackLyricState().obs;

  /// 当前播放歌曲状态。
  final Rx<PlaybackQueueItem> currentSongState =
      const PlaybackQueueItem.empty().obs;

  /// 当前播放进度状态。
  final Rx<Duration> currentPositionState = Duration.zero.obs;

  /// 当前播放队列状态。
  final RxList<PlaybackQueueItem> queueState = <PlaybackQueueItem>[].obs;

  /// 底部封面分页使用的轻量展示队列。
  final RxList<PlaybackArtworkPageItem> artworkPageItems =
      <PlaybackArtworkPageItem>[].obs;

  /// 当前播放队列索引。
  final RxInt currentQueueIndex = (-1).obs;

  /// 当前是否是 FM 模式。
  bool get isFmModeValue => playbackMode.value == PlaybackMode.roaming;

  /// 当前是否是 FM 模式的响应式兼容 getter。
  RxBool get isFmMode => (playbackMode.value == PlaybackMode.roaming).obs;

  /// 当前是否是心动模式。
  bool get isHeartBeatModeValue => playbackMode.value == PlaybackMode.heartbeat;

  /// 当前是否是心动模式的响应式兼容 getter。
  RxBool get isHeartBeatMode =>
      (playbackMode.value == PlaybackMode.heartbeat).obs;

  /// 全屏歌词是否打开。
  RxBool isFullScreenLyricOpen = false.obs;

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initAudioHandler());
    });
  }

  /// 统一接管音频服务的状态流，避免页面各自监听 `AudioService` 形成重复副作用。
  Future<void> _initAudioHandler() async {
    await _stateSynchronizer.start(
      syncSessionState: _syncSessionState,
      syncRuntimeState: _syncRuntimeState,
      syncLyricState: _syncLyricState,
      syncSelectionQueue: _syncSelectionQueue,
      updateCurrentPlayIndex: _updateCurPlayIndex,
      toggleLike: _toggleLikeFromPlayback,
      ensureCurrentTrackArtwork: _ensureCurrentTrackArtwork,
      syncCurrentQueueItem: _syncCurrentQueueItem,
      runtimeState: () => runtimeState.value,
      lyricState: () => lyricState.value,
      playbackMode: () => playbackMode.value,
      setIsPlaying: (value) => isPlaying.value = value,
      isPlaying: () => isPlaying.value,
      setFullScreenLyricOpen: (value) => isFullScreenLyricOpen.value = value,
    );
    _selectionService.configure(
      repeatMode: () => curRepeatMode.value,
      playbackMode: () => playbackMode.value,
    );
    _selectionSubscription ??= _selectionService.stream.listen(
      _syncSelectionState,
    );
    _syncSelectionState(_selectionService.state);
  }

  void _syncSessionState({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
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
    if (currentSong != null && !selectionState.value.hasSelection) {
      currentSongState.value = currentSong;
    }
    if (currentPosition != null &&
        currentPositionState.value != currentPosition) {
      currentPositionState.value = currentPosition;
    }
    if (queue != null) {
      queueState.assignAll(queue);
      _syncArtworkPageItems(queue);
    }
    if (currentIndex != null &&
        !selectionState.value.hasSelection &&
        currentQueueIndex.value != currentIndex) {
      currentQueueIndex.value = currentIndex;
    }
  }

  void _syncSelectionQueue(List<PlaybackQueueItem> queue, int selectedIndex) {
    _syncSelectionState(_selectionService.state);
  }

  void _syncSelectionState(PlaybackSelectionState nextState) {
    selectionState.value = nextState;
    if (nextState.selectedItem.id.isNotEmpty) {
      currentSongState.value = nextState.selectedItem;
    }
    if (nextState.selectedIndex >= 0 &&
        currentQueueIndex.value != nextState.selectedIndex) {
      currentQueueIndex.value = nextState.selectedIndex;
    }
    queueState.assignAll(nextState.queue);
    _syncArtworkPageItems(nextState.queue);
    _scheduleSelectionUiSideEffects(nextState);
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

  Future<void> _updateCurPlayIndex({bool currentItemUpdated = true}) async {
    final currentRuntimeState = runtimeState.value;
    final currentIndex = currentRuntimeState.queue.indexWhere(
      (element) => element.id == currentRuntimeState.currentSong.id,
    );
    _syncRuntimeState(currentIndex: currentIndex);
  }

  void _scheduleSelectionUiSideEffects(PlaybackSelectionState selection) {
    if (!selection.hasSelection) {
      return;
    }
    final key = '${selection.selectionVersion}:${selection.selectedItem.id}';
    if (_lastSelectionUiSideEffectKey == key) {
      return;
    }
    _lastSelectionUiSideEffectKey = key;
    final selectedSong = selection.selectedItem;
    _syncLyricState(
      lines: const [],
      currentIndex: -1,
      hasTranslatedLyrics: false,
    );
    // 歌词、取色和封面预取属于 UI 展示态，跟随 selection 而不是等底层播放确认。
    _sideEffectCoordinator.schedule(
      channel: 'playback-ui-lyric-artwork',
      delay: const Duration(milliseconds: 180),
      trackId: selectedSong.id,
      isStillCurrent: (trackId) =>
          selectionState.value.selectedItem.id == trackId,
      run: () async {
        _preloadImages();
        await _updateAlbumColor(selectedSong);
        if (selectionState.value.selectedItem.id != selectedSong.id) {
          return;
        }
        await _updateLyric(selectedSong);
      },
    );
  }

  Future<void> _updateAlbumColor(PlaybackQueueItem currentSong) async {
    try {
      final color = await _artworkPresenter.resolveDominantColor(currentSong);
      if (color == null) {
        return;
      }
      _themePort.applyDominantColor(color);
    } catch (_) {
      // 取色失败只影响播放器氛围色，不能阻断后续歌词等展示态更新。
    }
  }

  /// 先读本地歌词缓存，再读下载后的本地歌词文件，最后才回退到远程歌词入口。
  ///
  /// 这个顺序直接决定离线可用性；歌词内容现在走媒体库存储，不再继续塞进恢复态轻存储。
  Future<void> _updateLyric(PlaybackQueueItem currentSong) async {
    _syncLyricState(lines: const [], hasTranslatedLyrics: false);
    final nextLyricState = await _lyricsPresenter.loadLyrics(currentSong);
    if (selectionState.value.selectedItem.id != currentSong.id) {
      return;
    }
    lyricState.value = nextLyricState;
  }

  /// 播放或暂停当前歌曲。
  Future<void> playOrPause() async {
    await _commandService.playOrPause(isPlaying: isPlaying.value);
  }

  /// 播放列表切换先统一走播放控制器，避免页面继续直接触碰 `audioHandler`
  /// 并各自处理模式退出逻辑。
  Future<void> playPlaylist(
    List<PlaybackQueueItem> playList,
    int index, {
    String playListName = "无名歌单",
    String playListNameHeader = "",
  }) async {
    await _commandService.playPlaylist(
      playList,
      index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
      isFmMode: isFmModeValue,
      isHeartBeatMode: isHeartBeatModeValue,
      quitFmMode: quitFmMode,
      quitHeartBeatMode: quitHeartBeatMode,
    );
  }

  /// 播放队列中的指定索引。
  Future<void> playQueueIndex(int index) {
    return _commandService.playQueueIndex(index);
  }

  /// 更新播放队列中的指定队列项。
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

  /// 跳转到指定播放进度。
  Future<void> seekTo(Duration position) {
    return _commandService.seekTo(position);
  }

  /// 跳到上一首。
  Future<void> skipToPreviousTrack() {
    return _commandService.skipToPreviousTrack();
  }

  /// 跳到下一首。
  Future<void> skipToNextTrack() {
    return _commandService.skipToNextTrack();
  }

  /// 设置重复播放模式。
  Future<void> setRepeatMode(PlaybackRepeatMode repeatMode) {
    return _commandService.setRepeatMode(repeatMode);
  }

  /// 循环切换重复播放模式。
  Future<void> cycleRepeatMode() {
    return _commandService.cycleRepeatMode();
  }

  /// 打开 FM 漫游模式。
  Future<void> openFmMode() async {
    await switchMode(PlaybackMode.roaming);
  }

  /// 退出 FM 漫游模式。
  Future<void> quitFmMode({bool showToast = true}) async {
    await _modeCommandService.quitFmMode(
      currentMode: playbackMode.value,
      syncMode: (mode) async => _syncSessionState(playbackMode: mode),
      showToast: showToast,
    );
  }

  /// 打开心动模式。
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

  /// 退出心动模式。
  Future<void> quitHeartBeatMode({bool showToast = true}) async {
    await _modeCommandService.quitHeartBeatMode(
      currentMode: playbackMode.value,
      syncMode: (mode) async => _syncSessionState(playbackMode: mode),
      showToast: showToast,
    );
  }

  /// 播放当前用户喜欢歌曲列表。
  Future<void> playUserLikedSongs() async {
    await _commandService.playLikedSongs(
      currentSong: runtimeState.value.currentSong,
    );
  }

  /// 重复模式按钮的行为已经带上“退出心动模式并回到喜欢歌单”等业务规则，
  /// 放在页面里会持续复制分支并让播放模式判断再次散落。
  Future<void> handleRepeatModeTap() async {
    await _modeCommandService.handleRepeatModeTap(
      isFmMode: isFmModeValue,
      isHeartBeatMode: isHeartBeatModeValue,
      sessionState: sessionState.value,
      currentSong: runtimeState.value.currentSong,
      quitHeartBeatMode: quitHeartBeatMode,
      setRepeatMode: setRepeatMode,
      openHeartBeatMode: openHeartBeatMode,
    );
  }

  /// 切换播放模式。
  Future<void> switchMode(PlaybackMode newMode, {dynamic contextData}) async {
    await _modeCommandService.switchMode(
      currentMode: playbackMode.value,
      newMode: newMode,
      isPlaying: isPlaying.value,
      currentRepeatMode: sessionState.value.repeatMode,
      syncMode: (mode) async => _syncSessionState(playbackMode: mode),
      playOrPauseWhenPaused: playOrPause,
      contextData: contextData,
    );
  }

  /// 返回当前重复或播放模式对应的图标。
  IconData getRepeatIcon() {
    IconData icon;
    if (playbackMode.value == PlaybackMode.roaming) {
      icon = TablerIcons.radio;
    } else if (playbackMode.value == PlaybackMode.heartbeat) {
      icon = TablerIcons.heartbeat;
    } else {
      switch (curRepeatMode.value) {
        case PlaybackRepeatMode.one:
          icon = TablerIcons.repeat_once;
          break;
        case PlaybackRepeatMode.none:
          icon = TablerIcons.arrows_shuffle;
          break;
        case PlaybackRepeatMode.all:
        case PlaybackRepeatMode.group:
          icon = TablerIcons.repeat;
          break;
      }
    }
    return icon;
  }

  /// 更新全屏歌词自动打开计时。
  void updateFullScreenLyricTimerCounter({bool cancelTimer = false}) {
    _lyricUiStateController.updateFullScreenLyricTimerCounter(
      isPlaying: isPlaying.value,
      setFullScreenLyricOpen: (value) => isFullScreenLyricOpen.value = value,
      cancelTimer: cancelTimer,
    );
  }

  Future<void> _ensureCurrentTrackArtwork(PlaybackQueueItem item) async {
    final updatedItem = await _artworkPresenter.resolveMissingArtwork(item);
    if (updatedItem == null || runtimeState.value.currentSong.id != item.id) {
      return;
    }
    await _syncCurrentQueueItem(updatedItem);
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

  void _syncArtworkPageItems(List<PlaybackQueueItem> queue) {
    final nextItems = queue
        .map(PlaybackArtworkPageItem.fromQueueItem)
        .toList(growable: false);
    if (_hasSameArtworkPageItems(nextItems)) {
      return;
    }
    artworkPageItems.assignAll(nextItems);
  }

  bool _hasSameArtworkPageItems(List<PlaybackArtworkPageItem> nextItems) {
    if (artworkPageItems.length != nextItems.length) {
      return false;
    }
    for (var index = 0; index < nextItems.length; index++) {
      if (!artworkPageItems[index].hasSameArtwork(nextItems[index])) {
        return false;
      }
    }
    return true;
  }

  void _preloadImages() {
    if (isPlaying.isFalse) {
      return;
    }
    _artworkPresenter.preloadQueueArtwork(
      queue: selectionState.value.queue,
      currentIndex: selectionState.value.selectedIndex,
      context: Get.context,
    );
  }

  @override
  void onClose() {
    _sideEffectCoordinator.cancel('playback-ui-lyric-artwork');
    _selectionSubscription?.cancel();
    _stateSynchronizer.dispose();
    _lyricUiStateController.dispose();
    super.onClose();
  }
}
