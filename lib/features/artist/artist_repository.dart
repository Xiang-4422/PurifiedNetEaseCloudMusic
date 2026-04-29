import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/data/netease/netease_artist_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

class ArtistDetailData {
  const ArtistDetailData({
    required this.artist,
    required this.topSongs,
    required this.hotAlbums,
  });

  final ArtistEntity artist;
  final List<PlaybackQueueItem> topSongs;
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
      topSongs: _mapTracksToPlaybackQueueItems(
        topTracks,
        likedSongIds: likedSongIds,
      ),
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
      topSongs: _mapTracksToPlaybackQueueItems(
        tracks,
        likedSongIds: likedSongIds,
      ),
      hotAlbums: albums,
    );
  }

  List<PlaybackQueueItem> _mapTracksToPlaybackQueueItems(
    List<Track> tracks, {
    required List<int> likedSongIds,
  }) {
    if (tracks.isEmpty) {
      return const [];
    }
    return PlaybackQueueItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
  }
}
