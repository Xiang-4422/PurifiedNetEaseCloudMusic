import 'package:bujuan/common/netease_api/src/dio_ext.dart';
import 'package:bujuan/common/netease_api/src/netease_handler.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

class SearchRepository {
  SearchRepository({LibraryRepository? libraryRepository})
      : _libraryRepository =
            libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  DioMetaData buildSearchRequest(
    String keyword,
    int type, {
    int offset = 0,
    int limit = 30,
  }) {
    return DioMetaData(
      joinUri('/weapi/cloudsearch/pc'),
      data: {
        's': keyword,
        'type': type,
        'limit': limit,
        'offset': offset,
      },
      options: joinOptions(),
    );
  }

  DioMetaData buildHotKeywordRequest() {
    return DioMetaData(
      joinUri('/weapi/search/hot'),
      data: {'type': 1111},
      options: joinOptions(userAgent: UserAgent.Mobile),
    );
  }

  Future<List<MediaItem>> searchTrackMediaItems(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    final localTracks = await _libraryRepository.searchLocalTracks(keyword);
    if (localTracks.isNotEmpty) {
      return MediaItemMapper.fromTrackList(
        localTracks,
        likedSongIds: likedSongIds,
      );
    }
    final tracks = await _libraryRepository.searchTracks(
      sourceKey: 'netease',
      keyword: keyword,
    );
    return MediaItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
  }

  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async {
    final localPlaylists = await _libraryRepository.searchLocalPlaylists(
      keyword,
    );
    if (localPlaylists.isNotEmpty) {
      return localPlaylists;
    }
    return _libraryRepository.searchPlaylists(
      sourceKey: 'netease',
      keyword: keyword,
    );
  }

  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    final localAlbums = await _libraryRepository.searchLocalAlbums(keyword);
    if (localAlbums.isNotEmpty) {
      return localAlbums;
    }
    return _libraryRepository.searchAlbums(
      sourceKey: 'netease',
      keyword: keyword,
    );
  }

  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    final localArtists = await _libraryRepository.searchLocalArtists(keyword);
    if (localArtists.isNotEmpty) {
      return localArtists;
    }
    return _libraryRepository.searchArtists(
      sourceKey: 'netease',
      keyword: keyword,
    );
  }
}
