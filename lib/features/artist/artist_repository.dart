import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_artist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
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
  ArtistRepository({LibraryRepository? libraryRepository})
      : _libraryRepository = libraryRepository ??
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
    final artist = artistDetail.data?.artist == null
        ? null
        : NeteaseArtistMapper.fromArtist(artistDetail.data!.artist!);
    final tracks = NeteaseTrackMapper.fromSong2List(artistSongs.songs ?? const []);
    final albums = NeteaseAlbumMapper.fromAlbumList(artistAlbums.hotAlbums ?? const []);
    if (artist != null) {
      await _libraryRepository.saveArtists([artist]);
    }
    await _libraryRepository.saveTracks(tracks);
    await _libraryRepository.saveAlbums(albums);

    return ArtistDetailData(
      artist: artist!,
      topSongs: MediaItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
      hotAlbums: albums,
    );
  }
}
