import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/netease_artist_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

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
    required LibraryRepository libraryRepository,
    NeteaseArtistRemoteDataSource? remoteDataSource,
  })  : _libraryRepository = libraryRepository,
        _remoteDataSource =
            remoteDataSource ?? const NeteaseArtistRemoteDataSource();

  final LibraryRepository _libraryRepository;
  final NeteaseArtistRemoteDataSource _remoteDataSource;

  Future<ArtistDetailData?> loadLocalArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final artist = await _libraryRepository.getArtist('netease:$artistId');
    if (artist == null) {
      return null;
    }
    final topTracks = await _libraryRepository.getTracksByArtistId(artistId);
    final hotAlbums = await _libraryRepository.searchLocalAlbums(artist.name);
    return ArtistDetailData(
      artist: artist,
      topSongs: _mapTracksToMediaItems(topTracks, likedSongIds: likedSongIds),
      hotAlbums: hotAlbums
          .where((album) => album.artistNames.contains(artist.name))
          .toList(),
    );
  }

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

  List<MediaItem> _mapTracksToMediaItems(
    List<Track> tracks, {
    required List<int> likedSongIds,
  }) {
    if (tracks.isEmpty) {
      return const [];
    }
    return MediaItemMapper.fromTrackList(tracks, likedSongIds: likedSongIds);
  }
}
