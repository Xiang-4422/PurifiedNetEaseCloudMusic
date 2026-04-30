import 'package:bujuan/data/netease/remote/netease_explore_remote_data_source.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';

/// 探索仓库，聚合探索分类远程数据和本地缓存。
class ExploreRepository {
  /// 创建探索仓库。
  ExploreRepository({
    NeteaseExploreRemoteDataSource? remoteDataSource,
    required ExploreCacheStore cacheStore,
  })  : _remoteDataSource =
            remoteDataSource ?? NeteaseExploreRemoteDataSource(),
        _cacheStore = cacheStore;

  final NeteaseExploreRemoteDataSource _remoteDataSource;
  final ExploreCacheStore _cacheStore;

  /// 加载缓存的歌单分类目录。
  Future<ExplorePlaylistCatalogueData?> loadCachedPlaylistCatalogue() {
    return _cacheStore.loadPlaylistCatalogue();
  }

  /// 判断歌单分类目录缓存是否新鲜。
  Future<bool> isPlaylistCatalogueFresh({
    required Duration ttl,
  }) {
    return _cacheStore.isPlaylistCatalogueFresh(ttl: ttl);
  }

  /// 获取远程歌单分类目录并写入缓存。
  Future<ExplorePlaylistCatalogueData> fetchPlaylistCatalogue() async {
    final response = await _remoteDataSource.fetchPlaylistCatalogue();
    final catalogue = ExplorePlaylistCatalogueData(
      categoryNames: response.categoryNames,
      tagsByCategory: response.tagsByCategory,
    );
    await _cacheStore.savePlaylistCatalogue(catalogue);
    return catalogue;
  }

  /// 加载指定分类的缓存歌单。
  Future<List<PlaylistSummaryData>?> loadCachedCategoryPlaylists(
    String category,
  ) {
    return _cacheStore.loadCategoryPlaylists(category);
  }

  /// 判断指定分类歌单缓存是否新鲜。
  Future<bool> isCategoryPlaylistsFresh(
    String category, {
    required Duration ttl,
  }) {
    return _cacheStore.isCategoryPlaylistsFresh(category, ttl: ttl);
  }

  /// 获取指定分类的远程歌单并写入缓存。
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
