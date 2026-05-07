import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/data/music_data/sources/local/playback_restore_data_source.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';

/// 聚合播放恢复状态、曲目资源和歌词读取的仓库。
class PlaybackRepository {
  /// 创建播放仓库。
  PlaybackRepository({
    required MusicDataRepository musicDataRepository,
    required PlaybackRestoreDataSource playbackRestoreDataSource,
  })  : _musicDataRepository = musicDataRepository,
        _playbackRestoreDataSource = playbackRestoreDataSource;

  final MusicDataRepository _musicDataRepository;
  final PlaybackRestoreDataSource _playbackRestoreDataSource;
  PlaybackRestoreState? _restoreStateCache;
  Future<PlaybackRestoreState>? _restoreStateLoad;
  PlaybackRestoreState? _pendingRestoreState;
  Future<void>? _restoreWriteFuture;
  Duration? _pendingRestorePosition;
  Future<void>? _positionWriteFuture;

  /// 读取曲目歌词。
  Future<TrackLyrics?> fetchSongLyrics(String trackId) {
    return _musicDataRepository.getLyrics(trackId);
  }

  /// 读取曲目基础信息。
  Future<Track?> getTrack(String trackId) {
    return _musicDataRepository.getTrack(trackId);
  }

  /// 读取曲目及其本地资源索引。
  Future<TrackWithResources?> getTrackWithResources(String trackId) {
    return _musicDataRepository.getTrackWithResources(trackId);
  }

  /// 保存曲目歌词。
  Future<void> saveSongLyrics(String trackId, TrackLyrics lyrics) {
    return _musicDataRepository.saveLyrics(trackId, lyrics);
  }

  /// 读取播放恢复状态；无有效恢复数据时返回空状态。
  Future<PlaybackRestoreState> getRestoreState() async {
    final cachedState = _restoreStateCache;
    if (cachedState != null) {
      return cachedState;
    }
    final loadingState = _restoreStateLoad;
    if (loadingState != null) {
      return loadingState;
    }
    final loadFuture = _loadRestoreState();
    _restoreStateLoad = loadFuture;
    try {
      final state = await loadFuture;
      _restoreStateCache = state;
      return state;
    } finally {
      if (identical(_restoreStateLoad, loadFuture)) {
        _restoreStateLoad = null;
      }
    }
  }

  Future<PlaybackRestoreState> _loadRestoreState() async {
    final localState = await _playbackRestoreDataSource.getRestoreState();
    if (localState != null && localState.hasRestoreData) {
      return localState;
    }
    return const PlaybackRestoreState();
  }

  /// 更新播放恢复状态的部分字段。
  Future<void> updateRestoreState({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
    List<String>? queue,
    String? currentSongId,
    String? playlistName,
    String? playlistHeader,
    Duration? position,
  }) async {
    final nextState = (await getRestoreState()).copyWith(
      playbackMode: playbackMode,
      repeatMode: repeatMode,
      queue: queue,
      currentSongId: currentSongId,
      playlistName: playlistName,
      playlistHeader: playlistHeader,
      position: position,
    );
    _pendingRestoreState = nextState;
    _restoreStateCache = nextState;
    await _flushPendingRestoreState();
  }

  Future<void> _flushPendingRestoreState() {
    final currentWrite = _restoreWriteFuture;
    if (currentWrite != null) {
      return currentWrite;
    }
    late final Future<void> trackedWrite;
    trackedWrite = _writePendingRestoreStates().whenComplete(() {
      if (identical(_restoreWriteFuture, trackedWrite)) {
        _restoreWriteFuture = null;
      }
    });
    _restoreWriteFuture = trackedWrite;
    return trackedWrite;
  }

  Future<void> _writePendingRestoreStates() async {
    while (_pendingRestoreState != null) {
      final state = _pendingRestoreState!;
      _pendingRestoreState = null;
      await _playbackRestoreDataSource.saveRestoreState(state);
    }
  }

  /// 高频播放进度保存只更新进度字段，不重写完整恢复状态。
  Future<void> updateRestorePosition(Duration position) async {
    final nextState = (await getRestoreState()).copyWith(position: position);
    _restoreStateCache = nextState;
    _pendingRestorePosition = position;
    await _flushPendingRestorePosition();
  }

  Future<void> _flushPendingRestorePosition() {
    final currentWrite = _positionWriteFuture;
    if (currentWrite != null) {
      return currentWrite;
    }
    late final Future<void> trackedWrite;
    trackedWrite = _writePendingRestorePositions().whenComplete(() {
      if (identical(_positionWriteFuture, trackedWrite)) {
        _positionWriteFuture = null;
      }
    });
    _positionWriteFuture = trackedWrite;
    return trackedWrite;
  }

  Future<void> _writePendingRestorePositions() async {
    final fullStateWrite = _restoreWriteFuture;
    if (fullStateWrite != null) {
      await fullStateWrite;
    }
    while (_pendingRestorePosition != null) {
      final position = _pendingRestorePosition!;
      _pendingRestorePosition = null;
      await _playbackRestoreDataSource.saveRestorePosition(position);
    }
  }

  /// 按音质偏好解析播放地址。
  Future<String?> fetchPlaybackUrl(
    String trackId, {
    required bool preferHighQuality,
  }) {
    return _musicDataRepository.getPlaybackUrlWithQuality(
      trackId,
      qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
    );
  }
}
