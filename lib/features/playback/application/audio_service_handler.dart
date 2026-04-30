import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/features/playback/application/audio_service_queue_synchronizer.dart';
import 'package:bujuan/features/playback/application/playback_engine_adapter.dart';
import 'package:bujuan/features/playback/application/playback_notification_controls_presenter.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_adapter.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_repeat_mode_mapper.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:just_audio/just_audio.dart';

/// 承接 `audio_service` 层的播放状态与队列控制。
///
/// 页面和控制器不应直接复制这里的行为，否则播放状态、通知栏状态和
/// 本地恢复状态会很快分叉。
class AudioServiceHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  /// 创建 audio_service 播放处理器。
  AudioServiceHandler({
    required PlaybackQueueStore queueStore,
    required PlaybackRestoreCoordinator restoreCoordinator,
    required PlaybackSourceResolver sourceResolver,
    PlaybackEnginePort? engineAdapter,
    AudioServiceQueueSynchronizer? queueSynchronizer,
    PlaybackNotificationControlsPresenter? notificationControlsPresenter,
  })  : _queueStore = queueStore,
        _restoreCoordinator = restoreCoordinator,
        _sourceResolver = sourceResolver,
        _engine = engineAdapter ?? PlaybackEngineAdapter(),
        _queueSynchronizer =
            queueSynchronizer ?? AudioServiceQueueSynchronizer(),
        _notificationControlsPresenter = notificationControlsPresenter ??
            const PlaybackNotificationControlsPresenter() {
    _engine.playbackEventStream.listen((PlaybackEvent event) {
      playbackState.add(playbackState.value.copyWith(
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [1, 2, 3],
        processingState: _currentAudioProcessingState(),
        shuffleMode: (_engine.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: _engine.playing,
        updatePosition: _engine.position,
        bufferedPosition: _engine.bufferedPosition,
        speed: _engine.speed,
        queueIndex: _queueSynchronizer.currentIndex,
      ));
    });
    _updateMediaControls();
  }

  final PlaybackQueueStore _queueStore;
  final PlaybackRestoreCoordinator _restoreCoordinator;
  final PlaybackSourceResolver _sourceResolver;
  final PlaybackEnginePort _engine;
  final AudioServiceQueueSynchronizer _queueSynchronizer;
  final PlaybackNotificationControlsPresenter _notificationControlsPresenter;

  void Function(PlaybackMode mode)? _handleRestoredPlaybackMode;
  void Function(AudioServiceRepeatMode mode)? _handleRepeatModeChanged;
  void Function(String playlistName, String playlistHeader, bool isLikedSongs)?
      _handlePlaylistMetaChanged;
  bool Function()? _isHighQualityEnabled;
  Future<void> Function(MediaItem mediaItem)? _handleToggleLike;
  void Function(String message)? _handleToast;
  bool Function()? _isPlaylistMode;
  bool Function()? _isRoamingMode;
  Duration _pendingRestorePosition = Duration.zero;
  int _playIndexVersion = 0;
  Future<void> _sourceSwitchTail = Future<void>.value();
  bool _isResolvingCurrentSource = false;

  /// 当前通知栏和播放队列使用的循环模式。
  AudioServiceRepeatMode curRepeatMode = AudioServiceRepeatMode.all;

  /// 播放底层只通过显式回调同步上层状态，避免继续硬依赖控制器单例。
  void configure({
    void Function(PlaybackMode mode)? onRestorePlaybackMode,
    void Function(AudioServiceRepeatMode mode)? onRepeatModeChanged,
    void Function(
            String playlistName, String playlistHeader, bool isLikedSongs)?
        onPlaylistMetaChanged,
    bool Function()? isHighQualityEnabled,
    Future<void> Function(MediaItem mediaItem)? onToggleLike,
    void Function(String message)? onToast,
    bool Function()? isPlaylistMode,
    bool Function()? isRoamingMode,
  }) {
    _handleRestoredPlaybackMode = onRestorePlaybackMode;
    _handleRepeatModeChanged = onRepeatModeChanged;
    _handlePlaylistMetaChanged = onPlaylistMetaChanged;
    _isHighQualityEnabled = isHighQualityEnabled;
    _handleToggleLike = onToggleLike;
    _handleToast = onToast;
    _isPlaylistMode = isPlaylistMode;
    _isRoamingMode = isRoamingMode;
  }

  /// 恢复上一次的播放模式和队列。
  ///
  /// 当前仍有大量页面和控制器默认依赖“关闭应用后还能直接回到上一次队列”的行为，
  /// 所以恢复逻辑必须保留在音频服务入口，而不是交给页面自己拼。
  restoreLastPlayState() async {
    final restoreSnapshot = await _restoreCoordinator.loadSnapshot();
    _handleRestoredPlaybackMode?.call(restoreSnapshot.playbackMode);
    await changeRepeatMode(
      newRepeatMode: PlaybackRepeatModeMapper.toAudioService(
        restoreSnapshot.repeatMode,
      ),
    );
    if (restoreSnapshot.queue.isNotEmpty) {
      await changePlayList(
          PlaybackQueueItemAdapter.toMediaItems(restoreSnapshot.queue),
          index: restoreSnapshot.index,
          playListName: restoreSnapshot.playlistName,
          playListNameHeader: restoreSnapshot.playlistHeader,
          changePlayerSource: false,
          playNow: false,
          needStore: false);
      _pendingRestorePosition = restoreSnapshot.position;
    }
  }

  /// 切换或设置 audio_service 层循环模式。
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

    await _queueStore.saveRepeatMode(
      PlaybackRepeatModeMapper.fromAudioService(newRepeatMode),
    );
    _handleRepeatModeChanged?.call(newRepeatMode);
    _updateMediaControls();
  }

  /// 随机模式切换依赖原始顺序备份，否则来回切模式会不断
  /// 在已打乱结果上再次打乱，用户无法回到真正的原歌单顺序。
  reorderPlayList({bool shufflePlayList = false}) async {
    final playListCopy = _queueSynchronizer.reorder(
      currentQueue: queue.value,
      shuffle: shufflePlayList,
    );
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
    final playListCopy = _queueSynchronizer.buildPlayableQueue(
      queue: playList,
      index: index,
      shouldShuffle: curRepeatMode == AudioServiceRepeatMode.none &&
          (_isPlaylistMode?.call() ?? true),
    );
    index = _queueSynchronizer.currentIndex;
    await updateQueue(playListCopy);
    _handlePlaylistMetaChanged?.call(
      playListName,
      playListNameHeader,
      playListName == "喜欢的音乐",
    );
    if (changePlayerSource) {
      await playIndex(audioSourceIndex: index, playNow: playNow);
    } else {
      _queueSynchronizer.currentIndex = index;
      _publishPlaybackState();
    }
    if (needStore) {
      await _queueStore.saveQueueSnapshot(
        playlistName: playListName,
        playlistHeader: playListNameHeader,
        originalSongs: PlaybackQueueItemAdapter.fromMediaItems(
          _queueSynchronizer.originalSongs,
        ),
      );
    } else {
      await _queueStore.savePlaylistMeta(
        playlistName: playListName,
        playlistHeader: playListNameHeader,
      );
    }
  }

  /// 根据 `MediaItem` 的类型约定解析真实播放源。
  ///
  /// `MediaItem.extras['type']` 是通知栏和播放器之间的播放源契约，必须在
  /// 调用 `just_audio` 前完成源类型收敛。
  Future<bool> playIndex({
    required int audioSourceIndex,
    required bool playNow,
  }) async {
    if (audioSourceIndex < 0 || audioSourceIndex >= queue.value.length) {
      return false;
    }
    final requestVersion = ++_playIndexVersion;
    final previousIndex = _queueSynchronizer.currentIndex;
    final isNext = audioSourceIndex >= previousIndex;
    final newIndexMediaItem = queue.value[audioSourceIndex];
    _isResolvingCurrentSource = true;
    _publishPlaybackState(processingState: AudioProcessingState.loading);
    final source = await _sourceResolver.resolve(
      newIndexMediaItem,
      preferHighQuality: _isHighQualityEnabled?.call() ?? false,
    );
    if (!_isLatestPlayIndexRequest(requestVersion)) {
      return false;
    }
    final url = source.url;
    if (source.isEmpty) {
      if (playNow) {
        await (isNext ? skipToNext() : skipToPrevious());
        return false;
      } else if (_isLatestPlayIndexRequest(requestVersion)) {
        _isResolvingCurrentSource = false;
        _publishPlaybackState(processingState: AudioProcessingState.idle);
      }
      return false;
    }
    final switchOperation = _sourceSwitchTail.then((_) {
      return _applyResolvedSource(
        requestVersion: requestVersion,
        audioSourceIndex: audioSourceIndex,
        mediaItemToPlay: newIndexMediaItem,
        source: source,
        playNow: playNow,
        url: url,
      );
    });
    _sourceSwitchTail = switchOperation.then<void>((_) {}).catchError((_) {});
    try {
      return await switchOperation;
    } catch (_) {
      if (_isLatestPlayIndexRequest(requestVersion)) {
        _isResolvingCurrentSource = false;
        _publishPlaybackState(processingState: AudioProcessingState.idle);
        _handleToast?.call('当前歌曲暂时无法播放');
      }
      return false;
    }
  }

  Future<bool> _applyResolvedSource({
    required int requestVersion,
    required int audioSourceIndex,
    required MediaItem mediaItemToPlay,
    required PlaybackResolvedSource source,
    required bool playNow,
    required String url,
  }) async {
    if (!_isLatestPlayIndexRequest(requestVersion)) {
      return false;
    }
    final appliedSource = await _setSourceWithFallback(
      mediaItemToPlay,
      source,
      preferHighQuality: _isHighQualityEnabled?.call() ?? false,
    );
    if (!_isLatestPlayIndexRequest(requestVersion)) {
      return false;
    }
    final resolvedMediaItem = appliedSource.markAsCached
        ? _markMediaItemCached(mediaItemToPlay)
        : mediaItemToPlay;
    _isResolvingCurrentSource = false;
    _publishCurrentMediaItem(
      audioSourceIndex,
      resolvedMediaItem,
      processingState: AudioProcessingState.ready,
    );
    if (_pendingRestorePosition > Duration.zero) {
      await _engine.seek(_pendingRestorePosition);
      _pendingRestorePosition = Duration.zero;
    }
    if (playNow && url.isNotEmpty) {
      await play();
    }
    return true;
  }

  Future<PlaybackResolvedSource> _setSourceWithFallback(
    MediaItem mediaItem,
    PlaybackResolvedSource source, {
    required bool preferHighQuality,
  }) async {
    try {
      await _engine.setSource(source);
      return source;
    } catch (_) {
      if (source.kind != PlaybackResolvedSourceKind.filePath &&
          source.kind != PlaybackResolvedSourceKind.neteaseCacheStream) {
        rethrow;
      }
      final remoteSource = await _sourceResolver.resolveRemote(
        mediaItem,
        preferHighQuality: preferHighQuality,
      );
      if (remoteSource.isEmpty) {
        rethrow;
      }
      await _engine.setSource(remoteSource);
      return remoteSource;
    }
  }

  bool _isLatestPlayIndexRequest(int requestVersion) {
    return requestVersion == _playIndexVersion;
  }

  AudioProcessingState _currentAudioProcessingState() {
    if (_isResolvingCurrentSource) {
      return AudioProcessingState.loading;
    }
    return const {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[_engine.processingState]!;
  }

  void _publishCurrentMediaItem(
    int index,
    MediaItem item, {
    AudioProcessingState? processingState,
  }) {
    _queueSynchronizer.currentIndex = index;
    mediaItem.add(item);
    _publishPlaybackState(processingState: processingState);
  }

  void _publishPlaybackState({AudioProcessingState? processingState}) {
    playbackState.add(playbackState.value.copyWith(
      queueIndex: _queueSynchronizer.currentIndex,
      processingState: processingState ?? playbackState.value.processingState,
    ));
    _updateMediaControls();
  }

  MediaItem _markMediaItemCached(MediaItem item) {
    final extras = Map<String, dynamic>.from(item.extras ?? const {});
    extras['cache'] = true;
    return item.copyWith(extras: extras);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {}
  @override
  Future<void> removeQueueItemAt(int index) async {
    _queueSynchronizer.removeAt(index);
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> rewind() async {
    final mediaItem = queue.value[_queueSynchronizer.currentIndex];
    if (_handleToggleLike != null) {
      await _handleToggleLike!(mediaItem);
    }
  }

  @override
  Future<void> pause() async {
    await _engine.pause();
    _updateMediaControls();
  }

  @override
  Future<void> play() async {
    if (!_engine.hasAudioSource &&
        queue.value.isNotEmpty &&
        _queueSynchronizer.currentIndex >= 0 &&
        _queueSynchronizer.currentIndex < queue.value.length) {
      await playIndex(
        audioSourceIndex: _queueSynchronizer.currentIndex,
        playNow: true,
      );
      return;
    }
    await _engine.play();
    _updateMediaControls();
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    await super.updateMediaItem(mediaItem);
    _updateMediaControls();
  }

  @override
  Future<void> seek(Duration position) async {
    await _engine.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    int newIndex;
    if (curRepeatMode == AudioServiceRepeatMode.one) {
      newIndex = _queueSynchronizer.currentIndex;
    } else {
      newIndex = _queueSynchronizer.currentIndex + 1;
      if (newIndex == queue.value.length) {
        // 漫游模式的补队列是异步触发的，直接回环会把“加载中”和“切回第一首”
        // 混成同一个动作，结果会让队列状态和 UI 都更难解释。
        if (_isRoamingMode?.call() ?? false) {
          _handleToast?.call('正在加载漫游歌曲...');
          return;
        }
        newIndex = 0;
      }
    }
    await playIndex(audioSourceIndex: newIndex, playNow: true);
  }

  @override
  Future<void> skipToPrevious() async {
    int newIndex;
    if (curRepeatMode == AudioServiceRepeatMode.one) {
      newIndex = _queueSynchronizer.currentIndex;
    } else {
      newIndex = _queueSynchronizer.currentIndex - 1;
      if (newIndex < 0) {
        newIndex = queue.value.length - 1;
      }
    }
    await playIndex(audioSourceIndex: newIndex, playNow: true);
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
    await _engine.dispose();
  }

  /// 通知栏按钮仍以 `MediaItem.extras['liked']` 为准。
  ///
  /// 这里没有直接改成统一领域模型，是因为当前通知栏状态刷新仍跟着
  /// `audio_service` 的 `MediaItem` 流转，贸然拆开会先破坏现有按钮状态。
  _updateMediaControls() {
    final isLiked = mediaItem.value?.extras?['liked'] ?? false;
    playbackState.add(
      playbackState.value.copyWith(
        controls: _notificationControlsPresenter.buildControls(
          isPlaying: _engine.playing,
          isLiked: isLiked,
        ),
      ),
    );
  }
}
