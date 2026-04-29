/// 探索页只需要分类和标签视图时，直接返回整理后的结构，避免控制器理解网易云分类响应细节。
class ExplorePlaylistCatalogueData {
  /// 创建探索歌单分类目录数据。
  const ExplorePlaylistCatalogueData({
    required this.categoryNames,
    required this.tagsByCategory,
  });

  /// 分类名称列表。
  final List<String> categoryNames;

  /// 分类下的标签列表。
  final Map<String, List<String>> tagsByCategory;
}
