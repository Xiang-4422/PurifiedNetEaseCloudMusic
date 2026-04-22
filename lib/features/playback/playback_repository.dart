import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';
import 'package:get_it/get_it.dart';

class PlaybackRepository {
  PlaybackRepository({
    LibraryRepository? libraryRepository,
    PlaybackRestoreDataSource? playbackRestoreDataSource,
  })
      : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _playbackRestoreDataSource = playbackRestoreDataSource ??
            (GetIt.instance.isRegistered<PlaybackRestoreDataSource>()
                ? GetIt.instance<PlaybackRestoreDataSource>()
                : (throw StateError(
                    'PlaybackRestoreDataSource is not registered',
                  )));

  final LibraryRepository _libraryRepository;
  final PlaybackRestoreDataSource _playbackRestoreDataSource;

  Future<TrackLyrics?> fetchSongLyrics(String trackId) {
    return _libraryRepository.getLyrics(trackId);
  }

  Future<Track?> getTrack(String trackId) {
    return _libraryRepository.getTrack(trackId);
  }

  Future<TrackWithResources?> getTrackWithResources(String trackId) {
    return _libraryRepository.getTrackWithResources(trackId);
  }

  Future<void> saveSongLyrics(String trackId, TrackLyrics lyrics) {
    return _libraryRepository.saveLyrics(trackId, lyrics);
  }

  Future<PlaybackRestoreState> getRestoreState() async {
    final localState = await _playbackRestoreDataSource.getRestoreState();
    if (localState != null && localState.hasSnapshotData) {
      return localState;
    }
    return const PlaybackRestoreState();
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
    await _playbackRestoreDataSource.saveRestoreState(nextState);
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
