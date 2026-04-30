import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/features/playback/application/audio_service_queue_synchronizer.dart';
import 'package:bujuan/features/playback/application/playback_engine_adapter.dart';
import 'package:bujuan/features/playback/application/playback_notification_controls_presenter.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:just_audio/just_audio.dart';

/// 承接 `audio_service` 层的播放状态与队列控制。
///
/// 页面和控制器不应直接复制这里的行为，否则播放状态、通知栏状态和
/// 本地恢复状态会很快分叉。
class AudioServiceHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  /// 创建 audio_service 播放处理器。
  AudioServiceHandler({
    PlaybackEnginePort? engineAdapter,
    AudioServiceQueueSynchronizer? queueSynchronizer,
    PlaybackNotificationControlsPresenter? notificationControlsPresenter,
  })  : _engine = engineAdapter ?? PlaybackEngineAdapter(),
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

  final PlaybackEnginePort _engine;
  final AudioServiceQueueSynchronizer _queueSynchronizer;
  final PlaybackNotificationControlsPresenter _notificationControlsPresenter;

  void Function(AudioServiceRepeatMode mode)? _handleRepeatModeChanged;
  void Function(String playlistName, String playlistHeader, bool isLikedSongs)?
      _handlePlaylistMetaChanged;
  Future<void> Function(MediaItem mediaItem)? _handleToggleLike;
  Future<void> Function()? _handleSkipToPrevious;
  Future<void> Function()? _handleSkipToNext;
  Duration _pendingRestorePosition = Duration.zero;
  bool _isReplacingSource = false;

  /// 当前通知栏和播放队列使用的循环模式。
  AudioServiceRepeatMode curRepeatMode = AudioServiceRepeatMode.all;

  /// 底层播放器是否已经拥有可播放 source。
  bool get hasAudioSource => _engine.hasAudioSource;

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
    Future<void> Function()? onSkipToPrevious,
    Future<void> Function()? onSkipToNext,
  }) {
    _handleRepeatModeChanged = onRepeatModeChanged;
    _handlePlaylistMetaChanged = onPlaylistMetaChanged;
    _handleToggleLike = onToggleLike;
    _handleSkipToPrevious = onSkipToPrevious;
    _handleSkipToNext = onSkipToNext;
  }

  /// 设置等待下一次音源确认后恢复的播放进度。
  Future<void> setPendingRestorePosition(Duration position) async {
    _pendingRestorePosition = position;
  }

  /// 设置 audio_service 层循环模式。
  Future<void> changeRepeatMode(AudioServiceRepeatMode newRepeatMode) async {
    curRepeatMode = newRepeatMode;
    _handleRepeatModeChanged?.call(newRepeatMode);
    _updateMediaControls();
  }

  /// 更新通知栏队列，不触发播放源解析或队列重排。
  Future<void> setNotificationQueue(
    List<MediaItem> playList, {
    required int currentIndex,
    required String playListName,
    required String playListNameHeader,
  }) async {
    _queueSynchronizer.replaceQueue(playList);
    _queueSynchronizer.currentIndex = _clampQueueIndex(
      currentIndex,
      playList.length,
    );
    await updateQueue(List<MediaItem>.unmodifiable(playList));
    _handlePlaylistMetaChanged?.call(
      playListName,
      playListNameHeader,
      playListName == "喜欢的音乐",
    );
    _publishPlaybackState();
  }

  /// 更新底层切源使用的队列，不修改播放列表展示元信息。
  Future<void> setSourceQueue(
    List<MediaItem> playList, {
    required int currentIndex,
  }) async {
    _queueSynchronizer.replaceQueue(playList);
    _queueSynchronizer.currentIndex = _clampQueueIndex(
      currentIndex,
      playList.length,
    );
    await updateQueue(List<MediaItem>.unmodifiable(playList));
    _publishPlaybackState();
  }

  /// 使用已经解析好的播放源替换底层播放器 source。
  Future<bool> replaceSource({
    required int audioSourceIndex,
    required MediaItem mediaItemToPlay,
    required PlaybackResolvedSource source,
    required bool playNow,
  }) async {
    if (audioSourceIndex < 0 || audioSourceIndex >= queue.value.length) {
      return false;
    }
    _isReplacingSource = true;
    _publishPlaybackState(processingState: AudioProcessingState.loading);
    final url = source.url;
    if (source.isEmpty) {
      _isReplacingSource = false;
      _publishPlaybackState(processingState: AudioProcessingState.idle);
      return false;
    }
    try {
      if (playNow && _engine.playing) {
        await _engine.pause();
      }
      await _engine.setSource(source);
      final resolvedMediaItem = source.markAsCached
          ? _markMediaItemCached(mediaItemToPlay)
          : mediaItemToPlay;
      _isReplacingSource = false;
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
    } catch (_) {
      _isReplacingSource = false;
      _publishPlaybackState(processingState: AudioProcessingState.idle);
      return false;
    }
  }

  int _clampQueueIndex(int index, int queueLength) {
    if (queueLength <= 0) {
      return -1;
    }
    if (index < 0) {
      return -1;
    }
    if (index >= queueLength) {
      return queueLength - 1;
    }
    return index;
  }

  AudioProcessingState _currentAudioProcessingState() {
    if (_isReplacingSource) {
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
      playing: _engine.playing,
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
    if (!_engine.hasAudioSource) return;
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
    await _handleSkipToNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    await _handleSkipToPrevious?.call();
  }

  @override
  Future<void> stop() async {
    await _engine.pause();
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
