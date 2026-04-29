import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/search/search_repository.dart';

class SearchApplicationService {
  SearchApplicationService({required SearchRepository repository})
      : _repository = repository;

  static const Duration hotKeywordTtl = Duration(minutes: 30);

  final SearchRepository _repository;

  Future<List<String>?> loadCachedHotKeywords() {
    return _repository.loadCachedHotKeywords();
  }

  Future<bool> isHotKeywordCacheFresh() {
    return _repository.isHotKeywordCacheFresh(ttl: hotKeywordTtl);
  }

  Future<List<String>> fetchHotKeywords() {
    return _repository.fetchHotKeywords();
  }

  Future<List<PlaybackQueueItem>> searchTrackQueueItems(
    String keyword, {
    required List<int> likedSongIds,
  }) {
    return _repository.searchTrackQueueItems(
      keyword,
      likedSongIds: likedSongIds,
    );
  }

  Future<List<PlaylistEntity>> searchPlaylists(
    String keyword, {
    required String currentUserId,
  }) {
    return _repository.searchPlaylists(
      keyword,
      currentUserId: currentUserId,
    );
  }

  Future<List<AlbumEntity>> searchAlbums(String keyword) {
    return _repository.searchAlbums(keyword);
  }

  Future<List<ArtistEntity>> searchArtists(String keyword) {
    return _repository.searchArtists(keyword);
  }
}
