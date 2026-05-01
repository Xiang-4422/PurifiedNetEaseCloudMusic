import 'dart:async';
import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/domain/entities/playback_order_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_mode_command_service.dart';
import 'package:bujuan/core/diagnostics/playback_performance_logger.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_state_synchronizer.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_artwork_page_item.dart';
import 'package:bujuan/features/playback/playback_confirmed_state.dart';
import 'package:bujuan/features/playback/playback_display_state.dart';
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
    required PlaybackQueueService queueService,
    required PlaybackUiCommandService commandService,
    required PlaybackModeCommandService modeCommandService,
    required PlaybackStateSynchronizer stateSynchronizer,
    required PlaybackSelectionService selectionService,
    required PlaybackLyricUiStateController lyricUiStateController,
    required PlaybackUserContentPort userContentPort,
    required PlaybackArtworkPresenter artworkPresenter,
    required PlaybackSelectionUiEffectCoordinator selectionUiEffectCoordinator,
    required CurrentTrackDownloadUseCase downloadUseCase,
    required PlaybackToastPort toastPort,
  })  : _playbackService = playbackService,
        _queueStore = queueStore,
        _queueService = queueService,
        _commandService = commandService,
        _modeCommandService = modeCommandService,
        _stateSynchronizer = stateSynchronizer,
        _selectionService = selectionService,
        _lyricUiStateController = lyricUiStateController,
        _userContentPort = userContentPort,
        _artworkPresenter = artworkPresenter,
        _selectionUiEffectCoordinator = selectionUiEffectCoordinator,
        _downloadUseCase = downloadUseCase,
        _toastPort = toastPort;

  final PlaybackService _playbackService;
  final PlaybackQueueStore _queueStore;
  final PlaybackQueueService _queueService;
  final PlaybackUiCommandService _commandService;
  final PlaybackModeCommandService _modeCommandService;
  final PlaybackStateSynchronizer _stateSynchronizer;
  final PlaybackSelectionService _selectionService;
  final PlaybackLyricUiStateController _lyricUiStateController;
  final PlaybackUserContentPort _userContentPort;
  final PlaybackArtworkPresenter _artworkPresenter;
  final PlaybackSelectionUiEffectCoordinator _selectionUiEffectCoordinator;
  final CurrentTrackDownloadUseCase _downloadUseCase;
  final PlaybackToastPort _toastPort;
  StreamSubscription<PlaybackSelectionState>? _selectionSubscription;
  String? _lastSelectionErrorToastKey;

  /// 播放服务门面。
  PlaybackService get playbackService => _playbackService;

  /// 当前是否正在播放。
  RxBool isPlaying = false.obs;

  /// 当前重复播放模式。
  Rx<PlaybackRepeatMode> curRepeatMode = PlaybackRepeatMode.all.obs;

  /// 当前队列出队顺序模式。
  Rx<PlaybackOrderMode> curOrderMode = PlaybackOrderMode.sequential.obs;

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

  /// 当前 UI 展示播放状态。
  final Rx<PlaybackDisplayState> displayState =
      const PlaybackDisplayState().obs;

  /// 底层已确认播放状态。
  final Rx<PlaybackConfirmedState> confirmedState =
      const PlaybackConfirmedState().obs;

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

  /// UI 当前选中的歌曲，负责底部面板标题、封面和队列高亮。
  PlaybackQueueItem get selectedSong => selectionState.value.selectedItem;

  /// 底层播放器已经确认的歌曲，负责通知栏和真实播放事实。
  PlaybackQueueItem get confirmedSong => runtimeState.value.currentSong;

  /// UI 当前选中歌曲在 active queue 中的索引。
  int get selectedQueueIndex => selectionState.value.selectedIndex;

  /// 底层播放器确认歌曲在 active queue 中的索引。
  int get confirmedQueueIndex => runtimeState.value.currentIndex;

  /// 当前 UI selection 是否已经被底层播放器确认。
  bool get isSelectionConfirmed =>
      selectedSong.id.isNotEmpty && selectedSong.id == confirmedSong.id;

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
      setIsPlaying: _setIsPlaying,
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
    unawaited(_queueService.setPlaybackMode(nextState.playbackMode));
  }

  void _syncRuntimeState({
    List<PlaybackQueueItem>? queue,
    PlaybackQueueItem? currentSong,
    int? currentIndex,
    Duration? currentPosition,
  }) {
    final stopwatch = PlaybackPerformanceLogger.start();
    final nextState = runtimeState.value.copyWith(
      queue: queue,
      currentSong: currentSong,
      currentIndex: currentIndex,
      currentPosition: currentPosition,
    );
    runtimeState.value = nextState;
    confirmedState.value = PlaybackConfirmedState.fromRuntime(
      nextState,
      isPlaying: isPlaying.value,
    );
    if (currentSong != null && !selectionState.value.hasSelection) {
      currentSongState.value = currentSong;
    }
    if (currentPosition != null &&
        currentPositionState.value != currentPosition) {
      currentPositionState.value = currentPosition;
    }
    if (queue != null) {
      _syncQueueStateItems(queue);
      _syncArtworkPageItems(queue);
    }
    if (currentIndex != null &&
        !selectionState.value.hasSelection &&
        currentQueueIndex.value != currentIndex) {
      currentQueueIndex.value = currentIndex;
    }
    PlaybackPerformanceLogger.elapsed(
      'controller.syncRuntimeState',
      stopwatch,
      details:
          'queue=${queue?.length ?? '-'} song=${currentSong?.id ?? '-'} index=${currentIndex ?? '-'} position=${currentPosition != null}',
      warnAfterMs: 4,
    );
  }

  void _syncSelectionQueue(List<PlaybackQueueItem> queue, int selectedIndex) {
    _syncSelectionState(_selectionService.state);
  }

  void _syncSelectionState(PlaybackSelectionState nextState) {
    final stopwatch = PlaybackPerformanceLogger.start();
    selectionState.value = nextState;
    displayState.value = PlaybackDisplayState.fromSelection(nextState);
    curOrderMode.value = _queueService.state.orderMode;
    if (nextState.selectedItem.id.isNotEmpty) {
      currentSongState.value = nextState.selectedItem;
    }
    if (nextState.selectedIndex >= 0 &&
        currentQueueIndex.value != nextState.selectedIndex) {
      currentQueueIndex.value = nextState.selectedIndex;
    }
    _syncQueueStateItems(nextState.queue);
    _syncArtworkPageItems(nextState.queue);
    _scheduleSelectionUiSideEffects(nextState);
    _showSelectionSourceError(nextState);
    PlaybackPerformanceLogger.elapsed(
      'controller.syncSelectionState',
      stopwatch,
      details:
          'version=${nextState.selectionVersion} id=${nextState.selectedItem.id} index=${nextState.selectedIndex} queue=${nextState.queue.length} source=${nextState.sourceStatus.name}',
      warnAfterMs: 4,
    );
  }

  void _setIsPlaying(bool value) {
    isPlaying.value = value;
    confirmedState.value = PlaybackConfirmedState.fromRuntime(
      runtimeState.value,
      isPlaying: value,
    );
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
    _selectionUiEffectCoordinator.schedule(
      selection: selection,
      latestSelection: () => selectionState.value,
      syncLyricState: _syncLyricState,
      preloadImages: _preloadImages,
    );
  }

  void _showSelectionSourceError(PlaybackSelectionState selection) {
    final errorMessage = selection.sourceError;
    if (selection.sourceStatus != PlaybackSelectionSourceStatus.error ||
        errorMessage == null ||
        errorMessage.isEmpty) {
      return;
    }
    final toastKey =
        '${selection.selectionVersion}:${selection.selectedItem.id}:$errorMessage';
    if (_lastSelectionErrorToastKey == toastKey) {
      return;
    }
    _lastSelectionErrorToastKey = toastKey;
    _toastPort.show(errorMessage);
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
    await _queueService.updateQueueItem(item);
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

  /// 设置队列出队顺序模式。
  Future<void> setOrderMode(PlaybackOrderMode orderMode) {
    curOrderMode.value = orderMode;
    return _commandService.setOrderMode(orderMode);
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
      currentSong: selectionState.value.hasSelection
          ? selectionState.value.selectedItem
          : runtimeState.value.currentSong,
    );
  }

  /// 重复模式按钮的行为已经带上“退出心动模式并回到喜欢歌单”等业务规则，
  /// 放在页面里会持续复制分支并让播放模式判断再次散落。
  Future<void> handleRepeatModeTap() async {
    await _modeCommandService.handleRepeatModeTap(
      isFmMode: isFmModeValue,
      isHeartBeatMode: isHeartBeatModeValue,
      sessionState: sessionState.value,
      currentSong: selectionState.value.hasSelection
          ? selectionState.value.selectedItem
          : runtimeState.value.currentSong,
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
    } else if (curOrderMode.value == PlaybackOrderMode.shuffle) {
      icon = TablerIcons.arrows_shuffle;
    } else {
      switch (curRepeatMode.value) {
        case PlaybackRepeatMode.one:
          icon = TablerIcons.repeat_once;
          break;
        case PlaybackRepeatMode.none:
          icon = TablerIcons.repeat_off;
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
    await _queueService.updateQueueItem(updatedItem);
    _syncRuntimeState(
      queue: queue,
      currentSong: updatedItem,
    );
    await _playbackService.updateQueueItem(updatedItem);
  }

  void _syncArtworkPageItems(List<PlaybackQueueItem> queue) {
    final stopwatch = PlaybackPerformanceLogger.start();
    final nextItems = queue
        .map(PlaybackArtworkPageItem.fromQueueItem)
        .toList(growable: false);
    if (artworkPageItems.length != nextItems.length) {
      artworkPageItems.assignAll(nextItems);
      PlaybackPerformanceLogger.elapsed(
        'controller.syncArtworkPageItems.assignAll',
        stopwatch,
        details: 'count=${nextItems.length}',
        warnAfterMs: 2,
      );
      return;
    }
    var changedCount = 0;
    for (var index = 0; index < nextItems.length; index++) {
      if (!artworkPageItems[index].hasSameArtwork(nextItems[index])) {
        artworkPageItems[index] = nextItems[index];
        changedCount++;
      }
    }
    PlaybackPerformanceLogger.elapsed(
      'controller.syncArtworkPageItems.incremental',
      stopwatch,
      details: 'count=${nextItems.length} changed=$changedCount',
      warnAfterMs: 2,
    );
  }

  void _syncQueueStateItems(List<PlaybackQueueItem> queue) {
    final stopwatch = PlaybackPerformanceLogger.start();
    if (queueState.length != queue.length) {
      queueState.assignAll(queue);
      PlaybackPerformanceLogger.elapsed(
        'controller.syncQueueStateItems.assignAll',
        stopwatch,
        details: 'count=${queue.length}',
        warnAfterMs: 2,
      );
      return;
    }
    var changedCount = 0;
    for (var index = 0; index < queue.length; index++) {
      if (!_hasSameQueueItem(queueState[index], queue[index])) {
        queueState[index] = queue[index];
        changedCount++;
      }
    }
    PlaybackPerformanceLogger.elapsed(
      'controller.syncQueueStateItems.incremental',
      stopwatch,
      details: 'count=${queue.length} changed=$changedCount',
      warnAfterMs: 2,
    );
  }

  bool _hasSameQueueItem(
    PlaybackQueueItem current,
    PlaybackQueueItem next,
  ) {
    return current.id == next.id &&
        current.title == next.title &&
        current.artist == next.artist &&
        current.artworkUrl == next.artworkUrl &&
        current.localArtworkPath == next.localArtworkPath &&
        current.isLiked == next.isLiked &&
        current.isCached == next.isCached;
  }

  void _preloadImages() {
    if (isPlaying.isFalse) {
      return;
    }
    final stopwatch = PlaybackPerformanceLogger.start();
    _artworkPresenter.preloadQueueArtwork(
      queue: selectionState.value.queue,
      currentIndex: selectionState.value.selectedIndex,
      context: Get.context,
    );
    PlaybackPerformanceLogger.elapsed(
      'controller.preloadArtwork',
      stopwatch,
      details:
          'index=${selectionState.value.selectedIndex} queue=${selectionState.value.queue.length}',
      warnAfterMs: 2,
    );
  }

  @override
  void onClose() {
    _selectionUiEffectCoordinator.cancel();
    _selectionSubscription?.cancel();
    _stateSynchronizer.dispose();
    _lyricUiStateController.dispose();
    super.onClose();
  }
}
