import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/netease_album_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:get_it/get_it.dart';

class AlbumDetailData {
  const AlbumDetailData({
    required this.album,
    required this.albumSongs,
  });

  final AlbumEntity album;
  final List<MediaItem> albumSongs;
}

class AlbumRepository {
  AlbumRepository({
    LibraryRepository? libraryRepository,
    NeteaseAlbumRemoteDataSource? remoteDataSource,
  })
      : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _remoteDataSource =
            remoteDataSource ?? const NeteaseAlbumRemoteDataSource();

  final LibraryRepository _libraryRepository;
  final NeteaseAlbumRemoteDataSource _remoteDataSource;

  Future<AlbumDetailData> fetchAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchAlbumDetail(
      albumId: albumId,
      likedSongIds: likedSongIds,
    );
    final album = result.album;
    final tracks = result.tracks;
    if (album != null) {
      await _libraryRepository.saveAlbums([album]);
    }
    await _libraryRepository.saveTracks(tracks);
    return AlbumDetailData(
      album: album!,
      albumSongs: result.mediaItems,
    );
  }
}
