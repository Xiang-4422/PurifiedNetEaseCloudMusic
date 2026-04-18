import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/data/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/mappers/netease_track_mapper.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';
import 'package:get_it/get_it.dart';

class AlbumDetailData {
  const AlbumDetailData({
    required this.album,
    required this.albumSongs,
  });

  final Album album;
  final List<MediaItem> albumSongs;
}

class AlbumRepository {
  AlbumRepository({LibraryRepository? libraryRepository})
      : _libraryRepository =
            libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<AlbumDetailData> fetchAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final albumDetail = await NeteaseMusicApi().albumDetail(albumId);
    if (albumDetail.album != null) {
      await _libraryRepository.saveAlbums(
        [NeteaseAlbumMapper.fromAlbum(albumDetail.album!)],
      );
    }
    await _libraryRepository.saveTracks(
      NeteaseTrackMapper.fromSong2List(albumDetail.songs ?? const []),
    );
    return AlbumDetailData(
      album: albumDetail.album!,
      albumSongs: MediaItemMapper.fromSong2List(
        albumDetail.songs ?? const [],
        likedSongIds: likedSongIds,
      ),
    );
  }
}
