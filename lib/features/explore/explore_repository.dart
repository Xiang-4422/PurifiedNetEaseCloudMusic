import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';

class ExploreRepository {
  Future<ExplorePlaylistCatalogueData> fetchPlaylistCatalogue() async {
    final response = await NeteaseMusicApi().playlistCatalogue();
    final categories = <String>[];
    final tagsByCategory = <String, List<String>>{};

    for (final category in response.categories?.values ?? const <String>[]) {
      categories.add(category);
      tagsByCategory[category] = <String>[];
    }

    for (final item in response.sub ?? const []) {
      final categoryIndex = item.category;
      if (categoryIndex == null ||
          categoryIndex < 0 ||
          categoryIndex >= categories.length) {
        continue;
      }
      final categoryName = categories[categoryIndex];
      tagsByCategory[categoryName] =
          List<String>.from(tagsByCategory[categoryName] ?? const [])
            ..add(item.name ?? '');
    }

    return ExplorePlaylistCatalogueData(
      categoryNames: categories,
      tagsByCategory: tagsByCategory,
    );
  }

  Future<List<PlaylistSummaryData>> fetchCategoryPlaylists(String category) async {
    final response = await NeteaseMusicApi().categorySongList(category: category);
    return NeteasePlaylistMapper.fromPlaylistList(response.playlists ?? const [])
        .map(PlaylistSummaryData.fromEntity)
        .toList();
  }
}
