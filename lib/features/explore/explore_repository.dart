import 'package:bujuan/data/netease/netease_explore_remote_data_source.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';

class ExploreRepository {
  ExploreRepository({
    NeteaseExploreRemoteDataSource? remoteDataSource,
    ExploreCacheStore? cacheStore,
  })  : _remoteDataSource =
            remoteDataSource ?? const NeteaseExploreRemoteDataSource(),
        _cacheStore = cacheStore ?? const ExploreCacheStore();

  final NeteaseExploreRemoteDataSource _remoteDataSource;
  final ExploreCacheStore _cacheStore;

  Future<ExplorePlaylistCatalogueData?> loadCachedPlaylistCatalogue() {
    return _cacheStore.loadPlaylistCatalogue();
  }

  bool isPlaylistCatalogueFresh({
    required Duration ttl,
  }) {
    return _cacheStore.isPlaylistCatalogueFresh(ttl: ttl);
  }

  Future<ExplorePlaylistCatalogueData> fetchPlaylistCatalogue() async {
    final response = await _remoteDataSource.fetchPlaylistCatalogue();
    final catalogue = ExplorePlaylistCatalogueData(
      categoryNames: response.categoryNames,
      tagsByCategory: response.tagsByCategory,
    );
    await _cacheStore.savePlaylistCatalogue(catalogue);
    return catalogue;
  }

  Future<List<PlaylistSummaryData>?> loadCachedCategoryPlaylists(
    String category,
  ) {
    return _cacheStore.loadCategoryPlaylists(category);
  }

  bool isCategoryPlaylistsFresh(
    String category, {
    required Duration ttl,
  }) {
    return _cacheStore.isCategoryPlaylistsFresh(category, ttl: ttl);
  }

  Future<List<PlaylistSummaryData>> fetchCategoryPlaylists(
      String category) async {
    final response = await _remoteDataSource.fetchCategoryPlaylists(category);
    final playlists = response.map(PlaylistSummaryData.fromEntity).toList();
    if (playlists.isNotEmpty) {
      await _cacheStore.saveCategoryPlaylists(category, playlists);
    }
    return playlists;
  }
}
