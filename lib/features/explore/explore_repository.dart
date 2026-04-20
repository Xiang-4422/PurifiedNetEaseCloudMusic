import 'package:bujuan/data/netease/netease_explore_remote_data_source.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';

class ExploreRepository {
  ExploreRepository({NeteaseExploreRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? const NeteaseExploreRemoteDataSource();

  final NeteaseExploreRemoteDataSource _remoteDataSource;

  Future<ExplorePlaylistCatalogueData> fetchPlaylistCatalogue() async {
    final response = await _remoteDataSource.fetchPlaylistCatalogue();
    return ExplorePlaylistCatalogueData(
      categoryNames: response.categoryNames,
      tagsByCategory: response.tagsByCategory,
    );
  }

  Future<List<PlaylistSummaryData>> fetchCategoryPlaylists(String category) async {
    final response = await _remoteDataSource.fetchCategoryPlaylists(category);
    return response.map(PlaylistSummaryData.fromEntity).toList();
  }
}
