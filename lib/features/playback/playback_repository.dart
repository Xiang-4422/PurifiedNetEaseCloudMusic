import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/domain/entities/playback_restore_state.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/library/library_repository.dart';

/// 聚合播放恢复状态、曲目资源和歌词读取的仓库。
class PlaybackRepository {
  /// 创建播放仓库。
  PlaybackRepository({
    required LibraryRepository libraryRepository,
    required PlaybackRestoreDataSource playbackRestoreDataSource,
  })  : _libraryRepository = libraryRepository,
        _playbackRestoreDataSource = playbackRestoreDataSource;

  final LibraryRepository _libraryRepository;
  final PlaybackRestoreDataSource _playbackRestoreDataSource;

  /// 读取曲目歌词。
  Future<TrackLyrics?> fetchSongLyrics(String trackId) {
    return _libraryRepository.getLyrics(trackId);
  }

  /// 读取曲目基础信息。
  Future<Track?> getTrack(String trackId) {
    return _libraryRepository.getTrack(trackId);
  }

  /// 读取曲目及其本地资源索引。
  Future<TrackWithResources?> getTrackWithResources(String trackId) {
    return _libraryRepository.getTrackWithResources(trackId);
  }

  /// 保存曲目歌词。
  Future<void> saveSongLyrics(String trackId, TrackLyrics lyrics) {
    return _libraryRepository.saveLyrics(trackId, lyrics);
  }

  /// 读取播放恢复状态；无有效快照时返回空状态。
  Future<PlaybackRestoreState> getRestoreState() async {
    final localState = await _playbackRestoreDataSource.getRestoreState();
    if (localState != null && localState.hasSnapshotData) {
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
    await _playbackRestoreDataSource.saveRestoreState(nextState);
  }

  /// 按音质偏好解析播放地址。
  Future<String?> fetchPlaybackUrl(
    String trackId, {
    required bool preferHighQuality,
  }) {
    return _libraryRepository.getPlaybackUrlWithQuality(
      trackId,
      qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
    );
  }
}
