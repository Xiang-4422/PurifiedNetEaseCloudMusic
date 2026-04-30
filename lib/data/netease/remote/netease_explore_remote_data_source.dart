import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';

/// 探索页远程入口集中在 data/netease，便于后续继续下沉平台细节。
class NeteaseExploreRemoteDataSource {
  /// 创建网易云探索远程数据源。
  const NeteaseExploreRemoteDataSource();

  /// 获取歌单分类目录。
  Future<
      ({
        List<String> categoryNames,
        Map<String, List<String>> tagsByCategory,
      })> fetchPlaylistCatalogue() async {
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

    return (
      categoryNames: categories,
      tagsByCategory: tagsByCategory,
    );
  }

  /// 获取指定分类下的歌单列表。
  Future<List<PlaylistEntity>> fetchCategoryPlaylists(String category) async {
    final response =
        await NeteaseMusicApi().categorySongList(category: category);
    return NeteasePlaylistMapper.fromPlaylistList(
        response.playlists ?? const []);
  }
}
