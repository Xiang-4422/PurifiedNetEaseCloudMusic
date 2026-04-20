import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/netease_artist_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:get_it/get_it.dart';

class ArtistDetailData {
  const ArtistDetailData({
    required this.artist,
    required this.topSongs,
    required this.hotAlbums,
  });

  final ArtistEntity artist;
  final List<MediaItem> topSongs;
  final List<AlbumEntity> hotAlbums;
}

class ArtistRepository {
  ArtistRepository({
    LibraryRepository? libraryRepository,
    NeteaseArtistRemoteDataSource? remoteDataSource,
  })
      : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _remoteDataSource =
            remoteDataSource ?? const NeteaseArtistRemoteDataSource();

  final LibraryRepository _libraryRepository;
  final NeteaseArtistRemoteDataSource _remoteDataSource;

  Future<ArtistDetailData> fetchArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchArtistDetail(
      artistId: artistId,
      likedSongIds: likedSongIds,
    );
    final artist = result.artist;
    final tracks = result.topTracks;
    final albums = result.hotAlbums;
    if (artist != null) {
      await _libraryRepository.saveArtists([artist]);
    }
    await _libraryRepository.saveTracks(tracks);
    await _libraryRepository.saveAlbums(albums);

    return ArtistDetailData(
      artist: artist!,
      topSongs: result.topMediaItems,
      hotAlbums: albums,
    );
  }
}
