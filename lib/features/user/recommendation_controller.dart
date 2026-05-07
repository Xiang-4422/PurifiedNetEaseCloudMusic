import 'dart:async';

import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 首页用户本地数据，包含推荐歌单、日推歌曲和 FM 候选歌曲。
class UserHomeLocalData {
  /// 创建首页用户本地数据。
  const UserHomeLocalData({
    required this.recommendedPlaylists,
    required this.todayRecommendSongs,
    required this.fmSongs,
  });

  /// 创建空首页用户本地数据。
  const UserHomeLocalData.empty()
      : recommendedPlaylists = const [],
        todayRecommendSongs = const [],
        fmSongs = const [];

  /// 推荐歌单数据。
  final List<PlaylistSummaryData> recommendedPlaylists;

  /// 每日推荐歌曲数据。
  final List<PlaybackQueueItem> todayRecommendSongs;

  /// 私人 FM 候选歌曲数据。
  final List<PlaybackQueueItem> fmSongs;

  /// 是否包含任何可展示数据。
  bool get hasData => recommendedPlaylists.isNotEmpty || todayRecommendSongs.isNotEmpty || fmSongs.isNotEmpty;
}

/// 持有首页推荐、日推和 FM 候选歌曲状态。
class RecommendationController extends GetxController {
  static const Duration _startupDataTtl = Duration(minutes: 10);
  static const String _startupSyncMarker = 'startup_home';

  /// 当前推荐控制器实例。
  static RecommendationController get to => Get.find();

  /// 创建推荐控制器。
  RecommendationController({
    required UserRepository repository,
    required UserSessionController sessionController,
    required UserLibraryController libraryController,
    Future<void> Function()? validateLoginStateInBackground,
  })  : _repository = repository,
        _sessionController = sessionController,
        _libraryController = libraryController,
        _validateLoginStateInBackground = validateLoginStateInBackground;

  final UserRepository _repository;
  final UserSessionController _sessionController;
  final UserLibraryController _libraryController;
  final Future<void> Function()? _validateLoginStateInBackground;

  /// 首页下拉刷新控制器。
  final RefreshController refreshController = RefreshController();

  /// 首页推荐数据是否已经完成首轮加载。
  final RxBool dateLoaded = false.obs;

  /// 推荐歌单列表。
  final RxList<PlaylistSummaryData> recoPlayLists = <PlaylistSummaryData>[].obs;

  /// 每日推荐歌曲队列。
  final RxList<PlaybackQueueItem> todayRecommendSongs = <PlaybackQueueItem>[].obs;

  /// 私人 FM 候选歌曲队列。
  final RxList<PlaybackQueueItem> fmSongs = <PlaybackQueueItem>[].obs;

  Future<void>? _cacheBootstrapFuture;
  Timer? _homeImageColorPrewarmTimer;
  String _activeLocalDataUserId = '';
  bool _hasLocalData = false;

  /// 当前账号是否已有本地首页数据。
  bool get hasLocalData => _hasLocalData;

  /// 等待首页和用户资料缓存启动加载完成。
  Future<void> ensureCacheLoaded() async {
    await (_cacheBootstrapFuture ?? Future<void>.value());
  }

  @override
  void onInit() {
    super.onInit();
    _cacheBootstrapFuture = _loadCache();
    ever<UserSessionData>(_sessionController.userInfo, (info) {
      if (_activeLocalDataUserId == info.userId) {
        return;
      }
      _activeLocalDataUserId = info.userId;
      dateLoaded.value = false;
      unawaited(_reloadScopedLocalDataAndBootstrap(info.userId));
    });
  }

  @override
  void onReady() {
    super.onReady();
    unawaited(startHomeBootstrap());
  }

  /// 启动首页数据加载流程，优先展示本地数据再按 TTL 后台刷新。
  Future<void> startHomeBootstrap() async {
    await ensureCacheLoaded();
    if (_hasLocalData) {
      dateLoaded.value = true;
      scheduleHomeImageColorPrewarm();
      unawaited(_validateLoginStateInBackground?.call());
      if (!_libraryController.hasPlaylistData || await shouldRefreshStartupData()) {
        unawaited(updateData());
      }
      return;
    }
    await updateData();
  }

  Future<void> _reloadScopedLocalDataAndBootstrap(String userId) async {
    await _libraryController.loadScopedLocalData(userId);
    await _loadScopedLocalData(userId);
    await startHomeBootstrap();
  }

  /// 判断启动数据是否需要刷新。
  Future<bool> shouldRefreshStartupData() async {
    await ensureCacheLoaded();
    if (!_hasLocalData) {
      return true;
    }
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty) {
      return true;
    }
    return !(await _repository.isSyncMarkerFresh(
      userId: userId,
      markerKey: _startupSyncMarker,
      ttl: _startupDataTtl,
    ));
  }

  /// 刷新首页推荐、日推和 FM 候选数据。
  Future<void> updateData() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty) {
      dateLoaded.value = true;
      refreshController.refreshCompleted();
      refreshController.resetNoData();
      return;
    }

    await _libraryController.refreshUserLibrary();
    await Future.wait([
      _updateQuickStartCardData(),
      updateRecoPlayLists(),
    ]);
    _hasLocalData = true;
    await _repository.markSyncMarkerUpdated(
      userId: userId,
      markerKey: _startupSyncMarker,
    );
    dateLoaded.value = true;
    scheduleHomeImageColorPrewarm();
    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  /// 刷新推荐歌单，`getMore` 为 true 时追加下一页。
  Future<void> updateRecoPlayLists({bool getMore = false}) async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      return;
    }
    final data = await _repository.fetchRecommendedPlaylists(
      userId: userId,
      offset: getMore ? recoPlayLists.length : 0,
    );
    if (!getMore) {
      recoPlayLists.clear();
    }
    recoPlayLists.addAll(data);
    refreshController.loadComplete();
  }

  /// 拉取每日推荐歌曲队列。
  Future<List<PlaybackQueueItem>> getTodayRecommendSongs() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      return const [];
    }
    return _repository.fetchTodayRecommendSongs(
      userId: userId,
      likedSongIds: _libraryController.likedSongIds.toList(),
    );
  }

  /// 拉取私人 FM 候选歌曲队列。
  Future<List<PlaybackQueueItem>> getFmSongs() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      return const [];
    }
    return _repository.fetchFmSongs(
      userId: userId,
      likedSongIds: _libraryController.likedSongIds.toList(),
    );
  }

  /// 延迟预热首页卡片封面主色，避免阻塞首帧数据展示。
  void scheduleHomeImageColorPrewarm() {
    _homeImageColorPrewarmTimer?.cancel();
    _homeImageColorPrewarmTimer = Timer(const Duration(milliseconds: 120), () {
      unawaited(
        ImageColorService.prewarm(
          [
            todayRecommendSongs.isNotEmpty ? todayRecommendSongs.first.artworkUrl : null,
            fmSongs.isNotEmpty ? fmSongs.first.artworkUrl : null,
            _libraryController.randomLikedSongAlbumUrl.value,
          ],
        ),
      );
    });
  }

  Future<void> _loadCache() async {
    await _sessionController.ensureCacheLoaded();
    await _libraryController.ensureCacheLoaded();
    _activeLocalDataUserId = _sessionController.userInfo.value.userId;
    await _loadScopedLocalData(_activeLocalDataUserId);
  }

  Future<void> _loadScopedLocalData(String userId) async {
    recoPlayLists.clear();
    todayRecommendSongs.clear();
    fmSongs.clear();
    if (userId.isEmpty) {
      _hasLocalData = false;
      return;
    }

    final localData = await _loadLocalData(userId);
    recoPlayLists.addAll(localData.recommendedPlaylists);
    todayRecommendSongs.addAll(localData.todayRecommendSongs);
    fmSongs.addAll(localData.fmSongs);
    _hasLocalData = localData.hasData;
  }

  Future<void> _updateQuickStartCardData() async {
    final localData = await _refreshQuickStartData();
    todayRecommendSongs
      ..clear()
      ..addAll(localData.todayRecommendSongs);

    fmSongs
      ..clear()
      ..addAll(localData.fmSongs);
  }

  Future<UserHomeLocalData> _loadLocalData(String userId) async {
    if (userId.isEmpty) {
      return const UserHomeLocalData.empty();
    }
    final likedSongIds = _libraryController.likedSongIds.toList();
    final results = await Future.wait<Object>([
      _repository.loadCachedPlaylistList(
        userId,
        UserPlaylistListKind.recommended,
      ),
      _repository.loadCachedTrackList(
        userId: userId,
        kind: UserTrackListKind.dailyRecommend,
        likedSongIds: likedSongIds,
      ),
      _repository.loadCachedTrackList(
        userId: userId,
        kind: UserTrackListKind.fm,
        likedSongIds: likedSongIds,
      ),
    ]);
    return UserHomeLocalData(
      recommendedPlaylists: results[0] as List<PlaylistSummaryData>,
      todayRecommendSongs: results[1] as List<PlaybackQueueItem>,
      fmSongs: results[2] as List<PlaybackQueueItem>,
    );
  }

  Future<UserHomeLocalData> _refreshQuickStartData() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      return const UserHomeLocalData.empty();
    }
    final likedSongIds = _libraryController.likedSongIds.toList();
    final results = await Future.wait<Object>([
      _repository.fetchTodayRecommendSongs(
        userId: userId,
        likedSongIds: likedSongIds,
      ),
      _repository.fetchFmSongs(
        userId: userId,
        likedSongIds: likedSongIds,
      ),
    ]);
    return UserHomeLocalData(
      recommendedPlaylists: const [],
      todayRecommendSongs: results[0] as List<PlaybackQueueItem>,
      fmSongs: results[1] as List<PlaybackQueueItem>,
    );
  }

  @override
  void onClose() {
    _homeImageColorPrewarmTimer?.cancel();
    refreshController.dispose();
    super.onClose();
  }
}
