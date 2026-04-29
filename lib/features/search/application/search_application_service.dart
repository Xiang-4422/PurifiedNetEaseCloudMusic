import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/core/network/load_state.dart';

class SearchResultState {
  const SearchResultState({
    required this.songs,
    required this.playlists,
    required this.albums,
    required this.artists,
  });

  final LoadState<List<PlaybackQueueItem>> songs;
  final LoadState<List<PlaylistEntity>> playlists;
  final LoadState<List<AlbumEntity>> albums;
  final LoadState<List<ArtistEntity>> artists;
}

class SearchApplicationService {
  SearchApplicationService({required SearchRepository repository})
      : _repository = repository;

  static const Duration hotKeywordTtl = Duration(minutes: 30);

  final SearchRepository _repository;

  Future<LoadState<List<String>>> loadInitialHotKeywords({
    bool force = false,
  }) async {
    final cachedKeywords = await _repository.loadCachedHotKeywords();
    final shouldRefresh = force ||
        !(await _repository.isHotKeywordCacheFresh(ttl: hotKeywordTtl)) ||
        cachedKeywords == null ||
        cachedKeywords.isEmpty;
    if (cachedKeywords != null && cachedKeywords.isNotEmpty && !shouldRefresh) {
      return LoadState.data(cachedKeywords);
    }
    try {
      final keywords = await _repository.fetchHotKeywords();
      if (keywords.isEmpty) {
        return const LoadState.empty();
      }
      return LoadState.data(keywords);
    } catch (error, stackTrace) {
      if (cachedKeywords != null && cachedKeywords.isNotEmpty) {
        return LoadState.data(cachedKeywords);
      }
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<SearchResultState> searchAll(
    String keyword, {
    required List<int> likedSongIds,
    required String currentUserId,
  }) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      return const SearchResultState(
        songs: LoadState.empty(),
        playlists: LoadState.empty(),
        albums: LoadState.empty(),
        artists: LoadState.empty(),
      );
    }
    final results = await Future.wait<LoadState<dynamic>>([
      _loadSongs(normalizedKeyword, likedSongIds: likedSongIds),
      _loadPlaylists(normalizedKeyword, currentUserId: currentUserId),
      _loadAlbums(normalizedKeyword),
      _loadArtists(normalizedKeyword),
    ]);
    return SearchResultState(
      songs: results[0] as LoadState<List<PlaybackQueueItem>>,
      playlists: results[1] as LoadState<List<PlaylistEntity>>,
      albums: results[2] as LoadState<List<AlbumEntity>>,
      artists: results[3] as LoadState<List<ArtistEntity>>,
    );
  }

  Future<LoadState<List<PlaybackQueueItem>>> _loadSongs(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    try {
      final songs = await _repository.searchTrackQueueItems(
        keyword,
        likedSongIds: likedSongIds,
      );
      return songs.isEmpty ? const LoadState.empty() : LoadState.data(songs);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<LoadState<List<PlaylistEntity>>> _loadPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    try {
      final playlists = await _repository.searchPlaylists(
        keyword,
        currentUserId: currentUserId,
      );
      return playlists.isEmpty
          ? const LoadState.empty()
          : LoadState.data(playlists);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<LoadState<List<AlbumEntity>>> _loadAlbums(String keyword) async {
    try {
      final albums = await _repository.searchAlbums(keyword);
      return albums.isEmpty ? const LoadState.empty() : LoadState.data(albums);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }

  Future<LoadState<List<ArtistEntity>>> _loadArtists(String keyword) async {
    try {
      final artists = await _repository.searchArtists(keyword);
      return artists.isEmpty
          ? const LoadState.empty()
          : LoadState.data(artists);
    } catch (error, stackTrace) {
      return LoadState.error(error, stackTrace: stackTrace);
    }
  }
}
