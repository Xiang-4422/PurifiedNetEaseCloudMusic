import 'dart:async';

import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/explore/ranking_playlist_data.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 维护探索页榜单、分类歌单和加载状态。
///
class ExplorePageController extends GetxController {
  static const Duration _playlistCatalogueTtl = Duration(hours: 12);
  static const Duration _categoryPlaylistsTtl = Duration(minutes: 30);
  static const Duration _rankingPlaylistTtl = Duration(minutes: 30);

  /// 创建探索页控制器。
  ExplorePageController({
    required ExploreRepository exploreRepository,
    required PlaylistRepository playlistRepository,
    required List<int> Function() likedSongIds,
    required String Function() currentUserId,
  })  : _exploreRepository = exploreRepository,
        _playlistRepository = playlistRepository,
        _likedSongIds = likedSongIds,
        _currentUserId = currentUserId;

  final ExploreRepository _exploreRepository;
  final PlaylistRepository _playlistRepository;
  final List<int> Function() _likedSongIds;
  final String Function() _currentUserId;

  /// 榜单分类和榜单基础数据。
  final Map<String, List<RankingPlaylistData>> topPlayListCategory = {
    "官方榜": [
      const RankingPlaylistData(name: '云音乐新歌榜', id: '3779629'),
      const RankingPlaylistData(name: '云音乐热歌榜', id: '3778678'),
      const RankingPlaylistData(name: '云音乐原创榜', id: '2884035'),
      const RankingPlaylistData(name: '云音乐飙升榜', id: '19723756'),
      const RankingPlaylistData(name: '云音乐电音榜', id: '10520166'),
    ],
    "全球榜": [
      const RankingPlaylistData(name: 'UK排行榜周榜', id: '180106'),
      const RankingPlaylistData(name: '美国Billboard周榜', id: '60198'),
      const RankingPlaylistData(name: 'KTV嗨榜', id: '21845217'),
      const RankingPlaylistData(name: 'iTunes榜', id: '11641012'),
      const RankingPlaylistData(name: 'Hit FM Top榜', id: '120001'),
      const RankingPlaylistData(name: '日本Oricon周榜', id: '60131'),
      const RankingPlaylistData(name: '韩国Melon排行榜周榜', id: '3733003'),
      const RankingPlaylistData(name: '韩国Mnet排行榜周榜', id: '60255'),
      const RankingPlaylistData(name: '韩国Melon原声周榜', id: '46772709'),
      const RankingPlaylistData(name: '中国TOP排行榜(港台榜)', id: '112504'),
      const RankingPlaylistData(name: '中国TOP排行榜(内地榜)', id: '64016'),
      const RankingPlaylistData(name: '香港电台中文歌曲龙虎榜', id: '10169002'),
      const RankingPlaylistData(name: '华语金曲榜', id: '4395559'),
      const RankingPlaylistData(name: '中国嘻哈榜', id: '1899724'),
      const RankingPlaylistData(name: '法国 NRJ EuroHot 30周榜', id: '27135204'),
      const RankingPlaylistData(name: '台湾Hito排行榜', id: '112463'),
      const RankingPlaylistData(name: 'Beatport全球电子舞曲榜', id: '3812895'),
    ],
    "语种榜": [
      const RankingPlaylistData(name: '云音乐欧美热歌榜', id: '2809513713'),
      const RankingPlaylistData(name: '云音乐欧美新歌榜', id: '2809577409'),
    ],
    "精选榜": [
      const RankingPlaylistData(name: '云音乐ACG音乐榜', id: '71385702'),
      const RankingPlaylistData(name: '云音乐说唱榜', id: '991319590'),
      const RankingPlaylistData(name: '云音乐古典音乐榜', id: '71384707'),
      const RankingPlaylistData(name: '云音乐电音榜', id: '1978921795'),
      const RankingPlaylistData(name: '抖音排行榜', id: '2250011882'),
      const RankingPlaylistData(name: '新声榜', id: '2617766278'),
      const RankingPlaylistData(name: '云音乐韩语榜', id: '745956260'),
      const RankingPlaylistData(name: '英国Q杂志中文版周榜', id: '2023401535'),
      const RankingPlaylistData(name: '电竞音乐榜', id: '2006508653'),
      const RankingPlaylistData(name: '说唱TOP榜', id: '2847251561'),
      const RankingPlaylistData(name: '云音乐ACG动画榜', id: '3001835560'),
      const RankingPlaylistData(name: '云音乐ACG游戏榜', id: '3001795926'),
      const RankingPlaylistData(name: '云音乐ACG VOCALOID榜', id: '3001890046'),
    ]
  };

  /// 歌单标签分类名称列表。
  RxList tagCategorys = <String>[].obs;

  /// 分类到标签列表的映射。
  RxMap tags = {}.obs;

  /// 当前选中的标签分类名称。
  RxString curTagCategoryName = "".obs;

  /// 当前选中的歌单标签。
  RxString curTag = "全部".obs;

  /// 是否展示分类选择器。
  RxBool showChooseCategory = false.obs;

  /// 是否展示歌单选择器。
  RxBool showChoosePlayList = false.obs;

  /// 榜单分类名称列表。
  List<String> topPlayListCategoryNames = [];

  /// 当前榜单分类名称。
  RxString curTopPlayListCategoryName = "".obs;

  /// 当前榜单分类下的榜单列表。
  RxList<RankingPlaylistData> curCategoryTopPlayLists = <RankingPlaylistData>[].obs;

  /// 当前榜单名称。
  RxString curTopPlayListName = "".obs;

  /// 当前榜单 id。
  RxString curTopPlayListId = "".obs;

  /// 当前榜单歌曲队列。
  RxList<PlaybackQueueItem> curTopPlayListSongs = <PlaybackQueueItem>[].obs;

  /// 当前标签下的歌单列表。
  RxList<PlaylistSummaryData> playLists = <PlaylistSummaryData>[].obs;

  /// 探索页是否处于首屏加载中。
  RxBool loading = true.obs;

  /// 探索页刷新控制器。
  RefreshController refreshController = RefreshController();
  Worker? _pageVisibilityWorker;
  bool _bootstrapped = false;
  int _playlistRequestGeneration = 0;
  int _rankingSongsRequestGeneration = 0;
  bool _disposed = false;

  @override
  void onReady() {
    super.onReady();
    _initStaticState();
    if (HomeShellController.to.isExplorePageIndex(
      HomeShellController.to.curHomePageIndex.value,
    )) {
      unawaited(_ensureBootstrapped());
      return;
    }
    _pageVisibilityWorker = ever<int>(HomeShellController.to.curHomePageIndex, (pageIndex) {
      if (!HomeShellController.to.isExplorePageIndex(pageIndex)) {
        return;
      }
      _pageVisibilityWorker?.dispose();
      _pageVisibilityWorker = null;
      unawaited(_ensureBootstrapped());
    });
  }

  Future<void> _ensureBootstrapped() async {
    if (_disposed || _bootstrapped) {
      return;
    }
    _bootstrapped = true;
    final hasCachedData = await _loadCachedInitialData();
    if (_disposed) {
      return;
    }
    if (hasCachedData) {
      loading.value = false;
      if (await _shouldRefreshInitialData()) {
        unawaited(updateData());
      }
      return;
    }
    await updateData(force: true);
    if (!_disposed) {
      loading.value = false;
    }
  }

  void _initStaticState() {
    if (topPlayListCategoryNames.isNotEmpty) {
      return;
    }
    topPlayListCategoryNames.addAll(topPlayListCategory.keys);
    curTopPlayListCategoryName.value = topPlayListCategoryNames[0];
    curCategoryTopPlayLists.addAll(topPlayListCategory[curTopPlayListCategoryName.value]!);
    curTopPlayListName.value = curCategoryTopPlayLists[0].name;
    curTopPlayListId.value = curCategoryTopPlayLists[0].id;
  }

  @override
  void onClose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _playlistRequestGeneration++;
    _rankingSongsRequestGeneration++;
    _pageVisibilityWorker?.dispose();
    super.onClose();
  }

  Future<bool> _loadCachedInitialData() async {
    var hasCachedData = false;
    if (await _loadCachedPlaylistCatalogue()) {
      hasCachedData = true;
    }
    final category = curTag.value;
    if (await _loadCachedPlayLists(
      category: category,
      canApply: () => !_disposed && curTag.value == category,
    )) {
      hasCachedData = true;
    }
    final playlistId = curTopPlayListId.value;
    final likedSongIds = List<int>.of(_likedSongIds());
    final currentUserId = _currentUserId();
    if (await _loadCachedRankingPlayListSongs(
      playlistId: playlistId,
      likedSongIds: likedSongIds,
      currentUserId: currentUserId,
      canApply: () => _isCurrentRankingContext(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: currentUserId,
      ),
    )) {
      hasCachedData = true;
    }
    return hasCachedData;
  }

  Future<bool> _shouldRefreshInitialData() async {
    final playlistCatalogueFresh = await _isPlaylistCatalogueFresh();
    final categoryPlaylistsFresh = await _isCategoryPlaylistsFresh(curTag.value);
    final rankingPlaylistFresh = await _isRankingPlaylistFresh(curTopPlayListId.value);
    if (!playlistCatalogueFresh || !categoryPlaylistsFresh || !rankingPlaylistFresh) {
      return true;
    }
    return tagCategorys.isEmpty || playLists.isEmpty || curTopPlayListSongs.isEmpty;
  }

  Future<bool> _loadCachedPlaylistCatalogue() async {
    final ExplorePlaylistCatalogueData? cachedCatalogue;
    try {
      cachedCatalogue = await _exploreRepository.loadCachedPlaylistCatalogue();
    } catch (_) {
      return false;
    }
    if (cachedCatalogue == null) {
      return false;
    }
    if (_disposed) {
      return false;
    }
    _applyPlaylistCatalogue(cachedCatalogue);
    return cachedCatalogue.categoryNames.isNotEmpty || cachedCatalogue.tagsByCategory.isNotEmpty;
  }

  void _applyPlaylistCatalogue(ExplorePlaylistCatalogueData catalogue) {
    tagCategorys.assignAll(catalogue.categoryNames);
    tags.assignAll(catalogue.tagsByCategory);
    if (tagCategorys.isNotEmpty && !tagCategorys.contains(curTagCategoryName.value)) {
      curTagCategoryName.value = tagCategorys.first;
    }
  }

  /// 刷新探索页分类歌单和榜单数据。
  Future<void> updateData({bool force = false}) async {
    if (_disposed) {
      return;
    }
    try {
      await _refreshPlaylistCatalogue(force: force);
      if (_disposed) {
        return;
      }
      await Future.wait([
        updatePlayLists(force: force),
        updateRankingPlayListSongs(force: force),
      ]);
      if (_disposed) {
        return;
      }
      refreshController.refreshCompleted();
      refreshController.resetNoData();
    } catch (_) {
      if (_disposed) {
        return;
      }
      loading.value = false;
      refreshController.refreshFailed();
      refreshController.resetNoData();
    }
  }

  Future<void> _refreshPlaylistCatalogue({bool force = false}) async {
    if (_disposed) {
      return;
    }
    if (!force && tagCategorys.isNotEmpty && await _isPlaylistCatalogueFresh()) {
      return;
    }
    final catalogue = await _exploreRepository.fetchPlaylistCatalogue();
    if (!_disposed) {
      _applyPlaylistCatalogue(catalogue);
    }
  }

  /// 刷新当前标签下的歌单列表。
  Future<void> updatePlayLists({bool force = false}) async {
    if (_disposed) {
      return;
    }
    final category = curTag.value;
    final generation = ++_playlistRequestGeneration;
    if (!force) {
      final hasCachedPlayLists = await _loadCachedPlayLists(
        category: category,
        canApply: () => _isCurrentPlaylistRequest(category, generation),
      );
      if (!_isCurrentPlaylistRequest(category, generation)) {
        return;
      }
      if (hasCachedPlayLists && await _isCategoryPlaylistsFresh(category)) {
        return;
      }
      if (!_isCurrentPlaylistRequest(category, generation)) {
        return;
      }
    }
    final data = await _exploreRepository.fetchCategoryPlaylists(category);
    if (!_isCurrentPlaylistRequest(category, generation)) {
      return;
    }
    playLists
      ..clear()
      ..addAll(data);
  }

  /// 切换当前排行榜歌单。
  void changeCurRankingPlayList(String rankingPlayListid) {
    curTopPlayListId.value = rankingPlayListid;
    unawaited(updateRankingPlayListSongs());
  }

  /// 刷新或分页加载当前排行榜歌曲。
  Future<void> updateRankingPlayListSongs({
    int offset = 0,
    int limit = 10,
    bool force = false,
  }) async {
    if (_disposed) {
      return;
    }
    final playlistId = curTopPlayListId.value;
    final likedSongIds = List<int>.of(_likedSongIds());
    final userId = _currentUserId();
    final generation = offset == 0 ? ++_rankingSongsRequestGeneration : _rankingSongsRequestGeneration;
    if (offset == 0 && !force) {
      final hasCachedSongs = await _loadCachedRankingPlayListSongs(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: userId,
        canApply: () => _isCurrentRankingRequest(
          playlistId: playlistId,
          likedSongIds: likedSongIds,
          currentUserId: userId,
          generation: generation,
        ),
      );
      if (!_isCurrentRankingRequest(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: userId,
        generation: generation,
      )) {
        return;
      }
      if (hasCachedSongs && await _isRankingPlaylistFresh(playlistId)) {
        return;
      }
      if (!_isCurrentRankingRequest(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: userId,
        generation: generation,
      )) {
        return;
      }
    }
    final previousSongs = offset == 0 ? curTopPlayListSongs.toList(growable: false) : null;
    try {
      final songs = await _playlistRepository.fetchPlaylistSongs(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        offset: offset,
        limit: limit,
      );
      if (!_isCurrentRankingRequest(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: userId,
        generation: generation,
      )) {
        return;
      }
      if (offset == 0) {
        curTopPlayListSongs
          ..clear()
          ..addAll(songs);
      } else {
        curTopPlayListSongs.addAll(songs);
      }
      _updateLoadMoreState(songs.length);
    } catch (_) {
      if (!_isCurrentRankingRequest(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: userId,
        generation: generation,
      )) {
        return;
      }
      if (offset == 0 && previousSongs != null && previousSongs.isNotEmpty) {
        curTopPlayListSongs
          ..clear()
          ..addAll(previousSongs);
        refreshController.loadComplete();
        return;
      }
      refreshController.loadFailed();
      rethrow;
    }
  }

  void _updateLoadMoreState(int currentBatchSize) {
    if (currentBatchSize < 10) {
      refreshController.loadNoData();
      return;
    }
    refreshController.loadComplete();
  }

  /// 切换榜单分类。
  void changeCurTopPlayListCategory(String name) {
    curTopPlayListCategoryName.value = name;
    showChooseCategory.value = false;
    showChoosePlayList.value = false;

    curCategoryTopPlayLists.clear();
    curCategoryTopPlayLists.addAll(topPlayListCategory[curTopPlayListCategoryName.value]!);
    changeCurTopPlayList(curCategoryTopPlayLists[0]);
  }

  /// 切换当前榜单。
  void changeCurTopPlayList(RankingPlaylistData topPlayList) {
    curTopPlayListName.value = topPlayList.name;
    curTopPlayListId.value = topPlayList.id;
    showChooseCategory.value = false;
    showChoosePlayList.value = false;

    unawaited(updateRankingPlayListSongs());
  }

  Future<bool> _loadCachedPlayLists({
    required String category,
    required bool Function() canApply,
  }) async {
    final List<PlaylistSummaryData>? cachedPlayLists;
    try {
      cachedPlayLists = await _exploreRepository.loadCachedCategoryPlaylists(category);
    } catch (_) {
      return false;
    }
    if (cachedPlayLists == null || cachedPlayLists.isEmpty) {
      return false;
    }
    if (!canApply()) {
      return false;
    }
    playLists
      ..clear()
      ..addAll(cachedPlayLists);
    return true;
  }

  Future<bool> _loadCachedRankingPlayListSongs({
    required String playlistId,
    required List<int> likedSongIds,
    required String currentUserId,
    required bool Function() canApply,
  }) async {
    final PlaylistDetailData? cachedDetail;
    try {
      cachedDetail = await _playlistRepository.loadLocalPlaylistDetail(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: currentUserId,
      );
    } catch (_) {
      return false;
    }
    final cachedSongs = cachedDetail?.songs ?? const <PlaybackQueueItem>[];
    if (cachedSongs.isEmpty) {
      return false;
    }
    if (!canApply()) {
      return false;
    }
    curTopPlayListSongs
      ..clear()
      ..addAll(cachedSongs);
    _updateLoadMoreState(cachedSongs.length);
    return true;
  }

  Future<bool> _isPlaylistCatalogueFresh() async {
    try {
      return await _exploreRepository.isPlaylistCatalogueFresh(
        ttl: _playlistCatalogueTtl,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isCategoryPlaylistsFresh(String category) async {
    try {
      return await _exploreRepository.isCategoryPlaylistsFresh(
        category,
        ttl: _categoryPlaylistsTtl,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isRankingPlaylistFresh(String playlistId) async {
    try {
      return await _playlistRepository.isCacheFresh(
        playlistId,
        ttl: _rankingPlaylistTtl,
      );
    } catch (_) {
      return false;
    }
  }

  bool _isCurrentPlaylistRequest(String category, int generation) {
    return !_disposed && generation == _playlistRequestGeneration && curTag.value == category;
  }

  bool _isCurrentRankingContext({
    required String playlistId,
    required List<int> likedSongIds,
    required String currentUserId,
  }) {
    return !_disposed && curTopPlayListId.value == playlistId && _currentUserId() == currentUserId && _sameLikedSongIds(likedSongIds);
  }

  bool _isCurrentRankingRequest({
    required String playlistId,
    required List<int> likedSongIds,
    required String currentUserId,
    required int generation,
  }) {
    return generation == _rankingSongsRequestGeneration &&
        _isCurrentRankingContext(
          playlistId: playlistId,
          likedSongIds: likedSongIds,
          currentUserId: currentUserId,
        );
  }

  bool _sameLikedSongIds(List<int> requestedLikedSongIds) {
    final currentLikedSongIds = _likedSongIds();
    if (requestedLikedSongIds.length != currentLikedSongIds.length) {
      return false;
    }
    for (var index = 0; index < requestedLikedSongIds.length; index++) {
      if (requestedLikedSongIds[index] != currentLikedSongIds[index]) {
        return false;
      }
    }
    return true;
  }
}
