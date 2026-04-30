import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/audio_service_handler.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_adapter.dart';
import 'package:bujuan/features/playback/application/playback_repeat_mode_mapper.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:get/get.dart';

/// 统一持有音频服务实例和队列编排，避免页面直接操作底层播放器。
class PlaybackService extends GetxService {
  /// 创建播放服务。
  PlaybackService({
    required PlaybackRestoreCoordinator restoreCoordinator,
  }) : _restoreCoordinator = restoreCoordinator;

  final PlaybackRestoreCoordinator _restoreCoordinator;
  AudioServiceHandler? _handler;
  void Function(PlaybackMode mode)? _onRestorePlaybackMode;
  void Function(PlaybackRepeatMode mode)? _onRepeatModeChanged;
  void Function(String playlistName, String playlistHeader, bool isLikedSongs)?
      _onPlaylistMetaChanged;
  bool Function()? _isHighQualityEnabled;
  Future<void> Function(PlaybackQueueItem item)? _onToggleLike;
  void Function(String message)? _onToast;
  bool Function()? _isPlaylistMode;
  bool Function()? _isRoamingMode;
  Future<void> Function()? _onSkipToPrevious;
  Future<void> Function()? _onSkipToNext;

  /// 已初始化的 audio_service handler。
  AudioServiceHandler get handler {
    final handler = _handler;
    if (handler == null) {
      throw StateError('PlaybackService has not been initialized.');
    }
    return handler;
  }

  /// 播放队列流。
  Stream<List<PlaybackQueueItem>> get queueStream =>
      handler.queue.map(PlaybackQueueItemAdapter.fromMediaItems);

  /// 当前 audio_service active queue 快照。
  List<PlaybackQueueItem> get activeQueue =>
      PlaybackQueueItemAdapter.fromMediaItems(handler.queue.value);

  /// 底层播放器是否已经拥有可播放 source。
  bool get hasAudioSource => handler.hasAudioSource;

  /// 当前媒体项流。
  Stream<PlaybackQueueItem?> get mediaItemStream => handler.mediaItem.map(
        (mediaItem) => mediaItem == null
            ? null
            : PlaybackQueueItemAdapter.fromMediaItem(mediaItem),
      );

  /// 底层播放状态流。
  Stream<PlaybackState> get playbackStateStream => handler.playbackState;

  /// 初始化 audio_service handler。
  Future<AudioServiceHandler> ensureInitialized() async {
    if (_handler != null) {
      return _handler!;
    }
    _handler = await AudioService.init(
      builder: () => AudioServiceHandler(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.yu4422.purrr.channel.audio',
        androidNotificationChannelName: 'Music playback',
        androidNotificationIcon: 'drawable/audio_service_like',
      ),
    );
    _applyHandlerBindings();
    return _handler!;
  }

  /// 当前是否优先高音质。
  bool isHighQualityEnabled() => _isHighQualityEnabled?.call() ?? false;

  /// 控制器状态仍由上层持有，但底层播放器通过这组回调显式同步，避免反向依赖控制器单例。
  void bindControllerState({
    void Function(PlaybackMode mode)? onRestorePlaybackMode,
    void Function(PlaybackRepeatMode mode)? onRepeatModeChanged,
    void Function(
            String playlistName, String playlistHeader, bool isLikedSongs)?
        onPlaylistMetaChanged,
    bool Function()? isHighQualityEnabled,
    Future<void> Function(PlaybackQueueItem item)? onToggleLike,
    void Function(String message)? onToast,
    bool Function()? isPlaylistMode,
    bool Function()? isRoamingMode,
    Future<void> Function()? onSkipToPrevious,
    Future<void> Function()? onSkipToNext,
  }) {
    _onRestorePlaybackMode = onRestorePlaybackMode;
    _onRepeatModeChanged = onRepeatModeChanged;
    _onPlaylistMetaChanged = onPlaylistMetaChanged;
    _isHighQualityEnabled = isHighQualityEnabled;
    _onToggleLike = onToggleLike;
    _onToast = onToast;
    _isPlaylistMode = isPlaylistMode;
    _isRoamingMode = isRoamingMode;
    _onSkipToPrevious = onSkipToPrevious;
    _onSkipToNext = onSkipToNext;
    _applyHandlerBindings();
  }

  void _applyHandlerBindings() {
    _handler?.configure(
      onRestorePlaybackMode: _onRestorePlaybackMode,
      onRepeatModeChanged: _onRepeatModeChanged == null
          ? null
          : (mode) => _onRepeatModeChanged!(
                PlaybackRepeatModeMapper.fromAudioService(mode),
              ),
      onPlaylistMetaChanged: _onPlaylistMetaChanged,
      isHighQualityEnabled: _isHighQualityEnabled,
      onToggleLike: _onToggleLike == null
          ? null
          : (mediaItem) =>
              _onToggleLike!(PlaybackQueueItemAdapter.fromMediaItem(mediaItem)),
      onToast: _onToast,
      isPlaylistMode: _isPlaylistMode,
      isRoamingMode: _isRoamingMode,
      onSkipToPrevious: _onSkipToPrevious,
      onSkipToNext: _onSkipToNext,
    );
  }

  /// 恢复上次播放状态。
  Future<void> restoreLastPlayState() async {}

  /// 读取上次播放恢复快照。
  Future<PlaybackRestoreSnapshot> loadRestoreSnapshot() {
    return _restoreCoordinator.loadSnapshot();
  }

  /// 设置等待音源确认后恢复的播放进度。
  Future<void> setPendingRestorePosition(Duration position) {
    return handler.setPendingRestorePosition(position);
  }

  /// 开始播放。
  Future<void> play() => handler.play();

  /// 暂停播放。
  Future<void> pause() => handler.pause();

  /// 更新 audio_service 通知栏队列，不触发播放源切换。
  Future<void> setNotificationQueue(
    List<PlaybackQueueItem> queue, {
    required int currentIndex,
    required String playlistName,
    required String playlistHeader,
  }) {
    return handler.setNotificationQueue(
      PlaybackQueueItemAdapter.toMediaItems(queue),
      currentIndex: currentIndex,
      playListName: playlistName,
      playListNameHeader: playlistHeader,
    );
  }

  /// 为 active queue 中的指定歌曲设置底层播放源。
  Future<bool> replaceSourceForQueueItem({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackResolvedSource source,
    required bool playNow,
  }) async {
    if (activeIndex < 0 || activeIndex >= queue.length) {
      return false;
    }
    if (queue[activeIndex].id != item.id) {
      return false;
    }
    await _ensureHandlerQueueForSource(queue, activeIndex);
    return handler.replaceSource(
      audioSourceIndex: activeIndex,
      mediaItemToPlay: PlaybackQueueItemAdapter.toMediaItem(item),
      source: source,
      playNow: playNow,
    );
  }

  Future<void> _ensureHandlerQueueForSource(
    List<PlaybackQueueItem> queue,
    int fallbackIndex,
  ) async {
    final handlerQueue = activeQueue;
    if (_hasSameQueueIds(handlerQueue, queue)) {
      return;
    }
    final confirmedItemId = handler.mediaItem.value?.id ?? '';
    final confirmedIndex = confirmedItemId.isEmpty
        ? -1
        : queue.indexWhere((queueItem) => queueItem.id == confirmedItemId);
    await handler.setSourceQueue(
      PlaybackQueueItemAdapter.toMediaItems(queue),
      currentIndex: confirmedIndex >= 0 ? confirmedIndex : fallbackIndex,
    );
  }

  bool _hasSameQueueIds(
    List<PlaybackQueueItem> left,
    List<PlaybackQueueItem> right,
  ) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index].id != right[index].id) {
        return false;
      }
    }
    return true;
  }

  /// 跳转到指定播放进度。
  Future<void> seek(Duration position) => handler.seek(position);

  /// 跳到上一首。
  Future<void> skipToPrevious() => handler.skipToPrevious();

  /// 跳到下一首。
  Future<void> skipToNext() => handler.skipToNext();

  /// 切换或设置重复播放模式。
  Future<void> changeRepeatMode({PlaybackRepeatMode? newRepeatMode}) {
    if (newRepeatMode == null) return Future<void>.value();
    return handler.changeRepeatMode(
      PlaybackRepeatModeMapper.toAudioService(newRepeatMode),
    );
  }

  /// 更新队列中的单个媒体项。
  Future<void> updateQueueItem(PlaybackQueueItem item) {
    return handler.updateMediaItem(PlaybackQueueItemAdapter.toMediaItem(item));
  }
}
