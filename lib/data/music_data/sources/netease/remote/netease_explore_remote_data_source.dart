import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';

/// 探索页远程入口集中在 data/music_data/sources/netease，便于后续继续下沉平台细节。
class NeteaseExploreRemoteDataSource implements ExploreRemoteDataSource {
  /// 创建网易云探索远程数据源。
  NeteaseExploreRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 获取歌单分类目录。
  @override
  Future<
      ({
        List<String> categoryNames,
        Map<String, List<String>> tagsByCategory,
      })> fetchPlaylistCatalogue() async {
    final response = await _api.playlistCatalogue();
    final categories = <String>[];
    final tagsByCategory = <String, List<String>>{};

    for (final category in response.categories?.values ?? const <String>[]) {
      categories.add(category);
      tagsByCategory[category] = <String>[];
    }

    for (final item in response.sub ?? const []) {
      final categoryIndex = item.category;
      if (categoryIndex == null || categoryIndex < 0 || categoryIndex >= categories.length) {
        continue;
      }
      final categoryName = categories[categoryIndex];
      tagsByCategory[categoryName] = List<String>.from(tagsByCategory[categoryName] ?? const [])..add(item.name ?? '');
    }

    return (
      categoryNames: categories,
      tagsByCategory: tagsByCategory,
    );
  }

  /// 获取指定分类下的歌单列表。
  @override
  Future<List<PlaylistEntity>> fetchCategoryPlaylists(String category) async {
    final response = await _api.categorySongList(category: category);
    return NeteasePlaylistMapper.fromPlaylistList(response.playlists ?? const []);
  }
}
