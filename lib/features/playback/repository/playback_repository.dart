import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:get_it/get_it.dart';

class PlaybackRepository {
  PlaybackRepository({LibraryRepository? libraryRepository})
      : _libraryRepository =
            libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<TrackLyrics?> fetchSongLyrics(String trackId) {
    return _libraryRepository.getLyrics(trackId);
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
