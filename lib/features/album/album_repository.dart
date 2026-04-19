import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/data/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
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
  AlbumRepository({LibraryRepository? libraryRepository})
      : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<AlbumDetailData> fetchAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final albumDetail = await NeteaseMusicApi().albumDetail(albumId);
    final album = albumDetail.album == null
        ? null
        : NeteaseAlbumMapper.fromAlbum(albumDetail.album!);
    final tracks = NeteaseTrackMapper.fromSong2List(albumDetail.songs ?? const []);
    if (album != null) {
      await _libraryRepository.saveAlbums([album]);
    }
    await _libraryRepository.saveTracks(tracks);
    return AlbumDetailData(
      album: album!,
      albumSongs: MediaItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }
}
