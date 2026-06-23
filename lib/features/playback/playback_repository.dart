import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/playback_history_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/playback_restore_data_source.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/playback/application/recent_playback_updates.dart';

/// 聚合播放恢复状态、曲目资源和歌词读取的仓库。
class PlaybackRepository {
  static const int _maxRecentPlaybackEntries = 100;

  /// 创建播放仓库。
  PlaybackRepository({
    required MusicDataRepository musicDataRepository,
    required PlaybackRestoreDataSource playbackRestoreDataSource,
    required PlaybackHistoryDataSource playbackHistoryDataSource,
  })  : _musicDataRepository = musicDataRepository,
        _playbackRestoreDataSource = playbackRestoreDataSource,
        _playbackHistoryDataSource = playbackHistoryDataSource;

  final MusicDataRepository _musicDataRepository;
  final PlaybackRestoreDataSource _playbackRestoreDataSource;
  final PlaybackHistoryDataSource _playbackHistoryDataSource;
  PlaybackRestoreState? _restoreStateCache;
  Future<PlaybackRestoreState>? _restoreStateLoad;
  PlaybackRestoreState? _pendingRestoreState;
  Future<void>? _restoreWriteFuture;
  Duration? _pendingRestorePosition;
  Future<void>? _positionWriteFuture;
  final RecentPlaybackUpdates _recentPlaybackUpdates = RecentPlaybackUpdates();

  /// 最近播放历史写入完成后的轻量通知。
  Stream<void> get recentPlaybackUpdates => _recentPlaybackUpdates.stream;

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

  /// 读取最近播放的本地曲目及资源索引。
  Future<List<TrackWithResources>> loadRecentPlayedTracks({int limit = 20}) async {
    try {
      final trackIds = await _playbackHistoryDataSource.loadRecentTrackIds(
        limit: limit,
      );
      return await _musicDataRepository.getTracksWithResources(trackIds);
    } catch (_) {
      return const <TrackWithResources>[];
    }
  }

  /// 记录底层播放器已经确认播放的曲目。
  Future<void> recordPlayedTrack(
    String trackId, {
    DateTime? playedAt,
  }) async {
    if (trackId.isEmpty) {
      return;
    }
    try {
      await _playbackHistoryDataSource.recordPlayedTrack(
        trackId,
        playedAt: playedAt,
      );
    } catch (_) {
      return;
    }
    try {
      await _playbackHistoryDataSource.prune(
        maxEntries: _maxRecentPlaybackEntries,
      );
    } catch (_) {
      // 修剪是附带清理，不能反向影响已确认的播放历史刷新。
    }
    _recentPlaybackUpdates.notify();
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
      try {
        return await loadingState;
      } catch (_) {
        return const PlaybackRestoreState();
      }
    }
    final loadFuture = _loadRestoreState();
    _restoreStateLoad = loadFuture;
    try {
      final state = await loadFuture;
      _restoreStateCache = state;
      return state;
    } catch (_) {
      return const PlaybackRestoreState();
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
      try {
        await _playbackRestoreDataSource.saveRestoreState(state);
      } catch (_) {
        _pendingRestoreState ??= state;
        rethrow;
      }
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
    } else if (_pendingRestoreState != null) {
      await _flushPendingRestoreState();
    }
    while (_pendingRestorePosition != null) {
      final position = _pendingRestorePosition!;
      _pendingRestorePosition = null;
      try {
        await _playbackRestoreDataSource.saveRestorePosition(position);
      } catch (_) {
        _pendingRestorePosition ??= position;
        rethrow;
      }
    }
  }

  /// 按音质偏好解析播放地址。
  Future<String?> fetchPlaybackUrl(
    String trackId, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) {
    return _musicDataRepository.getPlaybackUrlWithQuality(
      trackId,
      qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
      forceRefresh: forceRefresh,
    );
  }
}
