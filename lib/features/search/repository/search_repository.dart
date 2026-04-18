import 'package:bujuan/common/netease_api/src/dio_ext.dart';
import 'package:bujuan/common/netease_api/src/netease_handler.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';
import 'package:audio_service/audio_service.dart';

class SearchRepository {
  SearchRepository({LibraryRepository? libraryRepository})
      : _libraryRepository = libraryRepository ?? LibraryRepository();

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
}
