import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/core/storage/cache_timestamp_store.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';

class ExploreCacheStore {
  const ExploreCacheStore({
    CacheTimestampStore? timestampStore,
  }) : _timestampStore = timestampStore ?? const CacheTimestampStore();

  final CacheTimestampStore _timestampStore;

  Future<ExplorePlaylistCatalogueData?> loadPlaylistCatalogue() async {
    final cached = CacheBox.instance.get(explorePlaylistCatalogueSp);
    if (cached is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(
      cached.map((key, value) => MapEntry('$key', value)),
    );
    final categoryNames = (map['categoryNames'] as List? ?? const [])
        .map((item) => '$item')
        .toList();
    final rawTags = map['tagsByCategory'] as Map? ?? const {};
    final tagsByCategory = <String, List<String>>{};
    for (final entry in rawTags.entries) {
      tagsByCategory['${entry.key}'] =
          (entry.value as List? ?? const []).map((item) => '$item').toList();
    }
    if (categoryNames.isEmpty && tagsByCategory.isEmpty) {
      return null;
    }
    return ExplorePlaylistCatalogueData(
      categoryNames: categoryNames,
      tagsByCategory: tagsByCategory,
    );
  }

  Future<void> savePlaylistCatalogue(
    ExplorePlaylistCatalogueData data,
  ) async {
    await CacheBox.instance.put(
      explorePlaylistCatalogueSp,
      {
        'categoryNames': data.categoryNames,
        'tagsByCategory': data.tagsByCategory,
      },
    );
    await _timestampStore.markUpdated(explorePlaylistCatalogueLastRefreshSp);
  }

  bool isPlaylistCatalogueFresh({
    required Duration ttl,
  }) {
    return _timestampStore.isFresh(
      explorePlaylistCatalogueLastRefreshSp,
      ttl: ttl,
    );
  }

  Future<List<PlaylistSummaryData>?> loadCategoryPlaylists(
    String category,
  ) async {
    final cached = CacheBox.instance.get(_categoryPlaylistKey(category));
    if (cached is! List) {
      return null;
    }
    return cached
        .map(
          (item) => PlaylistSummaryData.fromJson(
            Map<String, dynamic>.from(
              (item as Map).map((key, value) => MapEntry('$key', value)),
            ),
          ),
        )
        .toList();
  }

  Future<void> saveCategoryPlaylists(
    String category,
    List<PlaylistSummaryData> playlists,
  ) async {
    await CacheBox.instance.put(
      _categoryPlaylistKey(category),
      playlists.map((item) => jsonDecode(jsonEncode(item.toJson()))).toList(),
    );
    await _timestampStore.markUpdated(_categoryPlaylistRefreshKey(category));
  }

  bool isCategoryPlaylistsFresh(
    String category, {
    required Duration ttl,
  }) {
    return _timestampStore.isFresh(
      _categoryPlaylistRefreshKey(category),
      ttl: ttl,
    );
  }

  String _categoryPlaylistKey(String category) =>
      'EXPLORE_CATEGORY_PLAYLISTS_${Uri.encodeComponent(category)}';

  String _categoryPlaylistRefreshKey(String category) =>
      'EXPLORE_CATEGORY_PLAYLISTS_REFRESH_${Uri.encodeComponent(category)}';
}
