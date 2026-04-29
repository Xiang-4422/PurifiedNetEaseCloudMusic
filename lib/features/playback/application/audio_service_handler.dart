import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/other.dart';
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
  AudioServiceHandler({
    required PlaybackQueueStore queueStore,
    required PlaybackRestoreCoordinator restoreCoordinator,
    required PlaybackSourceResolver sourceResolver,
  })  : _queueStore = queueStore,
        _restoreCoordinator = restoreCoordinator,
        _sourceResolver = sourceResolver {
    _player = AudioPlayer();
    _player.playbackEventStream.listen((PlaybackEvent event) {
      playbackState.add(playbackState.value.copyWith(
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
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _curIndex,
      ));
    });
    _updateMediaControls();
  }

  late final AudioPlayer _player;
  final PlaybackQueueStore _queueStore;
  final PlaybackRestoreCoordinator _restoreCoordinator;
  final PlaybackSourceResolver _sourceResolver;

  final List<MediaItem> _originalSongs = <MediaItem>[];
  void Function(PlaybackMode mode)? _handleRestoredPlaybackMode;
  void Function(AudioServiceRepeatMode mode)? _handleRepeatModeChanged;
  void Function(String playlistName, String playlistHeader, bool isLikedSongs)?
      _handlePlaylistMetaChanged;
  bool Function()? _isHighQualityEnabled;
  Future<void> Function(MediaItem mediaItem)? _handleToggleLike;
  bool Function()? _isPlaylistMode;
  bool Function()? _isRoamingMode;
  Duration _pendingRestorePosition = Duration.zero;

  int _curIndex = -1;

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
    bool Function()? isPlaylistMode,
    bool Function()? isRoamingMode,
  }) {
    _handleRestoredPlaybackMode = onRestorePlaybackMode;
    _handleRepeatModeChanged = onRepeatModeChanged;
    _handlePlaylistMetaChanged = onPlaylistMetaChanged;
    _isHighQualityEnabled = isHighQualityEnabled;
    _handleToggleLike = onToggleLike;
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

  /// 随机模式切换依赖 `_originalSongs` 保留原始顺序，否则来回切模式会不断
  /// 在已打乱结果上再次打乱，用户无法回到真正的原歌单顺序。
  reorderPlayList({bool shufflePlayList = false}) async {
    var playListCopy = <MediaItem>[..._originalSongs];
    if (shufflePlayList) playListCopy.shuffle();
    String curSongId = queue.value[_curIndex].id;
    int curNewIndex =
        playListCopy.indexWhere((element) => element.id == curSongId);
    _curIndex = curNewIndex;
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
    _originalSongs
      ..clear()
      ..addAll(playList);
    var playListCopy = <MediaItem>[...playList];
    if (curRepeatMode == AudioServiceRepeatMode.none &&
        (_isPlaylistMode?.call() ?? true)) {
      playListCopy.shuffle();
      index = playListCopy
          .indexWhere((element) => element.id == playList[index].id);
    }
    await updateQueue(playListCopy);
    _handlePlaylistMetaChanged?.call(
      playListName,
      playListNameHeader,
      playListName == "喜欢的音乐",
    );
    if (changePlayerSource) {
      await playIndex(audioSourceIndex: index, playNow: playNow);
    } else {
      _curIndex = index;
      if (_curIndex >= 0 && _curIndex < playListCopy.length) {
        mediaItem.add(playListCopy[_curIndex]);
        playbackState.add(playbackState.value.copyWith(queueIndex: _curIndex));
        _updateMediaControls();
      }
    }
    if (needStore) {
      await _queueStore.saveQueueSnapshot(
        playlistName: playListName,
        playlistHeader: playListNameHeader,
        originalSongs: PlaybackQueueItemAdapter.fromMediaItems(_originalSongs),
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
  playIndex({required int audioSourceIndex, required bool playNow}) async {
    bool isNext = audioSourceIndex >= _curIndex;
    _curIndex = audioSourceIndex;
    MediaItem newIndexMediaItem = queue.value[audioSourceIndex];
    mediaItem.add(newIndexMediaItem);
    final source = await _sourceResolver.resolve(
      newIndexMediaItem,
      preferHighQuality: _isHighQualityEnabled?.call() ?? false,
    );
    final url = source.url;
    if (source.markAsCached) {
      newIndexMediaItem.extras?.putIfAbsent('cache', () => true);
    }
    switch (source.kind) {
      case PlaybackResolvedSourceKind.filePath:
        await _player.setFilePath(url);
        break;
      case PlaybackResolvedSourceKind.neteaseCacheStream:
        await _player.setAudioSource(
          StreamSource(url, source.fileType),
        );
        break;
      case PlaybackResolvedSourceKind.url:
        await _player.setUrl(url);
        break;
      case PlaybackResolvedSourceKind.empty:
        break;
    }
    if (_pendingRestorePosition > Duration.zero) {
      await _player.seek(_pendingRestorePosition);
      _pendingRestorePosition = Duration.zero;
    }
    if (playNow) {
      if (url.isNotEmpty) {
        await play();
      } else {
        isNext ? skipToNext() : skipToPrevious();
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

  @override
  Future<void> rewind() async {
    final mediaItem = queue.value[_curIndex];
    if (_handleToggleLike != null) {
      await _handleToggleLike!(mediaItem);
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _updateMediaControls();
  }

  @override
  Future<void> play() async {
    if (_player.audioSource == null &&
        queue.value.isNotEmpty &&
        _curIndex >= 0 &&
        _curIndex < queue.value.length) {
      await playIndex(audioSourceIndex: _curIndex, playNow: true);
      return;
    }
    await _player.play();
    _updateMediaControls();
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    await super.updateMediaItem(mediaItem);
    _updateMediaControls();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    int newIndex;
    if (curRepeatMode == AudioServiceRepeatMode.one) {
      newIndex = _curIndex;
    } else {
      newIndex = _curIndex + 1;
      if (newIndex == queue.value.length) {
        // 漫游模式的补队列是异步触发的，直接回环会把“加载中”和“切回第一首”
        // 混成同一个动作，结果会让队列状态和 UI 都更难解释。
        if (_isRoamingMode?.call() ?? false) {
          WidgetUtil.showToast('正在加载漫游歌曲...');
          return;
        }
        newIndex = 0;
      }
    }
    playIndex(audioSourceIndex: newIndex, playNow: true);
  }

  @override
  Future<void> skipToPrevious() async {
    int newIndex;
    if (curRepeatMode == AudioServiceRepeatMode.one) {
      newIndex = _curIndex;
    } else {
      newIndex = _curIndex - 1;
      if (newIndex < 0) {
        newIndex = queue.value.length - 1;
      }
    }
    playIndex(audioSourceIndex: newIndex, playNow: true);
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
    await _player.dispose();
  }

  /// 通知栏按钮仍以 `MediaItem.extras['liked']` 为准。
  ///
  /// 这里没有直接改成统一领域模型，是因为当前通知栏状态刷新仍跟着
  /// `audio_service` 的 `MediaItem` 流转，贸然拆开会先破坏现有按钮状态。
  _updateMediaControls() {
    bool isLiked = mediaItem.value?.extras?['liked'] ?? false;
    playbackState.add(playbackState.value.copyWith(controls: [
      MediaControl(
          label: 'rewind',
          action: MediaAction.rewind,
          androidIcon: isLiked
              ? 'drawable/audio_service_like'
              : 'drawable/audio_service_unlike'),
      MediaControl.skipToPrevious,
      _player.playing ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ]));
  }
}

// ignore: experimental_member_use
class StreamSource extends StreamAudioSource {
  String uri;
  String fileType;

  /// `.uc!` 缓存文件需要按网易云本地格式解密后再交给播放器。
  StreamSource(this.uri, this.fileType);

  @override
  // ignore: experimental_member_use
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // `.uc!` 不是标准媒体文件，播放器只能接收解密后的字节流。
    Uint8List fileBytes = Uint8List.fromList(
        File(uri).readAsBytesSync().map((e) => e ^ 0xa3).toList());

    // ignore: experimental_member_use
    return StreamAudioResponse(
      sourceLength: fileBytes.length,
      contentLength: (end ?? fileBytes.length) - (start ?? 0),
      offset: start ?? 0,
      stream: Stream.fromIterable([fileBytes.sublist(start ?? 0, end)]),
      contentType: fileType,
    );
  }
}
