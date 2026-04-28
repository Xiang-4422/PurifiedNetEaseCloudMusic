import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/netease_album_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

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
    required LibraryRepository libraryRepository,
    NeteaseAlbumRemoteDataSource? remoteDataSource,
  })  : _libraryRepository = libraryRepository,
        _remoteDataSource =
            remoteDataSource ?? const NeteaseAlbumRemoteDataSource();

  final LibraryRepository _libraryRepository;
  final NeteaseAlbumRemoteDataSource _remoteDataSource;

  Future<AlbumDetailData?> loadLocalAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final album = await _libraryRepository.getAlbum('netease:$albumId');
    if (album == null) {
      return null;
    }
    final tracks = await _libraryRepository.getTracksByAlbumId(albumId);
    return AlbumDetailData(
      album: album,
      albumSongs: _mapTracksToMediaItems(tracks, likedSongIds: likedSongIds),
    );
  }

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
