import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/download/local_song_list_controller.dart';

/// Creates page-local local song list controllers with download dependencies injected.
class LocalSongListControllerFactory {
  /// Creates a factory for local song list controllers.
  const LocalSongListControllerFactory({
    required MusicDataRepository musicDataRepository,
    required DownloadRepository downloadRepository,
  })  : _musicDataRepository = musicDataRepository,
        _downloadRepository = downloadRepository;

  final MusicDataRepository _musicDataRepository;
  final DownloadRepository _downloadRepository;

  /// Creates a controller owned and disposed by the local songs page.
  LocalSongListController create({
    Set<TrackResourceOrigin>? origins,
  }) {
    return LocalSongListController(
      musicDataRepository: _musicDataRepository,
      downloadRepository: _downloadRepository,
      origins: origins,
    );
  }
}
