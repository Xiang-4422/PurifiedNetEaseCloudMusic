import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';
import 'package:bujuan/features/playback/playback_state_store.dart';
import 'package:get_it/get_it.dart';

class PlaybackRepository {
  PlaybackRepository({
    LibraryRepository? libraryRepository,
    PlaybackStateStore? playbackStateStore,
  })
      : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _playbackStateStore = playbackStateStore ?? const PlaybackStateStore();

  final LibraryRepository _libraryRepository;
  final PlaybackStateStore _playbackStateStore;

  Future<TrackLyrics?> fetchSongLyrics(String trackId) {
    return _libraryRepository.getLyrics(trackId);
  }

  Future<void> saveSongLyrics(String trackId, TrackLyrics lyrics) {
    return _libraryRepository.saveLyrics(trackId, lyrics);
  }

  /// 恢复态后面会迁到正式本地库，先让播放器主链路只认仓库入口，
  /// 这样切换存储介质时不用再回头改控制器和 handler。
  Future<PlaybackRestoreState> getRestoreState() async {
    final localState = await _libraryRepository.getPlaybackRestoreState();
    if (localState != null && localState.hasSnapshotData) {
      return localState;
    }
    final lightState = _playbackStateStore.restoreState;
    if (lightState.hasSnapshotData) {
      await _libraryRepository.savePlaybackRestoreState(lightState);
    }
    return lightState;
  }

  Future<void> updateRestoreState({
    PlaybackMode? playbackMode,
    AudioServiceRepeatMode? repeatMode,
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
    await Future.wait([
      _playbackStateStore.saveRestoreState(nextState),
      _libraryRepository.savePlaybackRestoreState(nextState),
    ]);
  }

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
