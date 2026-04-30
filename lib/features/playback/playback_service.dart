import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/audio_service_handler.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_adapter.dart';
import 'package:bujuan/features/playback/application/playback_repeat_mode_mapper.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:get/get.dart';

/// 统一持有音频服务实例和队列编排，避免页面直接操作底层播放器。
class PlaybackService extends GetxService {
  /// 创建播放服务。
  PlaybackService({
    required PlaybackQueueStore queueStore,
    required PlaybackRestoreCoordinator restoreCoordinator,
    required PlaybackSourceResolver sourceResolver,
  })  : _queueStore = queueStore,
        _restoreCoordinator = restoreCoordinator,
        _sourceResolver = sourceResolver;

  final PlaybackQueueStore _queueStore;
  final PlaybackRestoreCoordinator _restoreCoordinator;
  final PlaybackSourceResolver _sourceResolver;
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
      builder: () => AudioServiceHandler(
        queueStore: _queueStore,
        restoreCoordinator: _restoreCoordinator,
        sourceResolver: _sourceResolver,
      ),
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
  }) {
    _onRestorePlaybackMode = onRestorePlaybackMode;
    _onRepeatModeChanged = onRepeatModeChanged;
    _onPlaylistMetaChanged = onPlaylistMetaChanged;
    _isHighQualityEnabled = isHighQualityEnabled;
    _onToggleLike = onToggleLike;
    _onToast = onToast;
    _isPlaylistMode = isPlaylistMode;
    _isRoamingMode = isRoamingMode;
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
    );
  }

  /// 恢复上次播放状态。
  Future<void> restoreLastPlayState() => handler.restoreLastPlayState();

  /// 开始播放。
  Future<void> play() => handler.play();

  /// 暂停播放。
  Future<void> pause() => handler.pause();

  /// 切换播放队列。
  Future<void> changePlayList(
    List<PlaybackQueueItem> playList, {
    int index = 0,
    bool needStore = true,
    required String playListName,
    String playListNameHeader = "",
    required bool changePlayerSource,
    required bool playNow,
  }) {
    return handler.changePlayList(
      PlaybackQueueItemAdapter.toMediaItems(playList),
      index: index,
      needStore: needStore,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
      changePlayerSource: changePlayerSource,
      playNow: playNow,
    );
  }

  /// 播放队列中的指定索引。
  Future<bool> playIndex({
    required int audioSourceIndex,
    required bool playNow,
  }) {
    return handler.playIndex(
        audioSourceIndex: audioSourceIndex, playNow: playNow);
  }

  /// 跳转到指定播放进度。
  Future<void> seek(Duration position) => handler.seek(position);

  /// 跳到上一首。
  Future<void> skipToPrevious() => handler.skipToPrevious();

  /// 跳到下一首。
  Future<void> skipToNext() => handler.skipToNext();

  /// 切换或设置重复播放模式。
  Future<void> changeRepeatMode({PlaybackRepeatMode? newRepeatMode}) {
    return handler.changeRepeatMode(
      newRepeatMode: newRepeatMode == null
          ? null
          : PlaybackRepeatModeMapper.toAudioService(newRepeatMode),
    );
  }

  /// 更新队列中的单个媒体项。
  Future<void> updateQueueItem(PlaybackQueueItem item) {
    return handler.updateMediaItem(PlaybackQueueItemAdapter.toMediaItem(item));
  }

  /// 队列切换和播放源更新先统一收口在 service，避免控制器继续直接编排底层 handler。
  Future<void> playPlaylist(
    List<PlaybackQueueItem> playList,
    int index, {
    required String playListName,
    String playListNameHeader = "",
    bool playNow = true,
    bool changePlayerSource = true,
    bool needStore = true,
  }) {
    return changePlayList(
      playList,
      index: index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
      playNow: playNow,
      changePlayerSource: changePlayerSource,
      needStore: needStore,
    );
  }
}
