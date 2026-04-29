import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';

class ExploreCacheStore {
  const ExploreCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  Future<ExplorePlaylistCatalogueData?> loadPlaylistCatalogue() async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(explorePlaylistCatalogueSp);
    if (payloadJson == null) {
      return null;
    }
    final cached = jsonDecode(payloadJson);
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
    await _cacheDataSource.save(
      cacheKey: explorePlaylistCatalogueSp,
      payloadJson: jsonEncode(
        {
          'categoryNames': data.categoryNames,
          'tagsByCategory': data.tagsByCategory,
        },
      ),
    );
  }

  Future<bool> isPlaylistCatalogueFresh({
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      explorePlaylistCatalogueSp,
      ttl: ttl,
    );
  }

  Future<List<PlaylistSummaryData>?> loadCategoryPlaylists(
    String category,
  ) async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(_categoryPlaylistKey(category));
    if (payloadJson == null) {
      return null;
    }
    final cached = jsonDecode(payloadJson);
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
    await _cacheDataSource.save(
      cacheKey: _categoryPlaylistKey(category),
      payloadJson: jsonEncode(
        playlists.map((item) => item.toJson()).toList(),
      ),
    );
  }

  Future<bool> isCategoryPlaylistsFresh(
    String category, {
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      _categoryPlaylistKey(category),
      ttl: ttl,
    );
  }

  String _categoryPlaylistKey(String category) =>
      'EXPLORE_CATEGORY_PLAYLISTS_${Uri.encodeComponent(category)}';
}
