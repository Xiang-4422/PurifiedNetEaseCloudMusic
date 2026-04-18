import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/common/netease_api/src/netease_api.dart';
import 'package:bujuan/data/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/mappers/netease_artist_mapper.dart';
import 'package:bujuan/data/mappers/netease_track_mapper.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';
import 'package:get_it/get_it.dart';

class ArtistDetailData {
  const ArtistDetailData({
    required this.artist,
    required this.topSongs,
    required this.hotAlbums,
  });

  final Artist artist;
  final List<MediaItem> topSongs;
  final List<Album> hotAlbums;
}

class ArtistRepository {
  ArtistRepository({LibraryRepository? libraryRepository})
      : _libraryRepository =
            libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<ArtistDetailData> fetchArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final artistDetail = await NeteaseMusicApi().artistDetail(artistId);
    final artistSongs = await NeteaseMusicApi().artistTopSongList(artistId);
    final artistAlbums = await NeteaseMusicApi().artistAlbumList(artistId);
    if (artistDetail.data?.artist != null) {
      await _libraryRepository.saveArtists(
        [NeteaseArtistMapper.fromArtist(artistDetail.data!.artist!)],
      );
    }
    await _libraryRepository.saveTracks(
      NeteaseTrackMapper.fromSong2List(artistSongs.songs ?? const []),
    );
    await _libraryRepository.saveAlbums(
      NeteaseAlbumMapper.fromAlbumList(artistAlbums.hotAlbums ?? const []),
    );

    return ArtistDetailData(
      artist: artistDetail.data!.artist!,
      topSongs: MediaItemMapper.fromSong2List(
        artistSongs.songs ?? const [],
        likedSongIds: likedSongIds,
      ),
      hotAlbums: artistAlbums.hotAlbums ?? const [],
    );
  }
}
