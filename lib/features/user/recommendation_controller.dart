import 'dart:async';

import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';
import 'package:bujuan/features/user/application/user_home_application_service.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 持有首页推荐、日推和 FM 候选歌曲状态。
class RecommendationController extends GetxController {
  static const Duration _startupDataTtl = Duration(minutes: 10);
  static const String _startupSyncMarker = 'startup_home';

  /// 当前推荐控制器实例。
  static RecommendationController get to => Get.find();

  /// 创建推荐控制器。
  RecommendationController({
    required UserHomeApplicationService homeService,
    required UserSessionController sessionController,
    required UserLibraryController libraryController,
    Future<void> Function()? validateLoginStateInBackground,
  })  : _homeService = homeService,
        _sessionController = sessionController,
        _libraryController = libraryController,
        _validateLoginStateInBackground = validateLoginStateInBackground;

  final UserHomeApplicationService _homeService;
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
  final RxList<PlaybackQueueItem> todayRecommendSongs =
      <PlaybackQueueItem>[].obs;

  /// 私人 FM 候选歌曲队列。
  final RxList<PlaybackQueueItem> fmSongs = <PlaybackQueueItem>[].obs;

  Future<void>? _cacheBootstrapFuture;
  Timer? _homeImageColorPrewarmTimer;
  String _activeSnapshotUserId = '';
  bool _hasLocalSnapshot = false;

  /// 当前账号是否已有本地首页快照。
  bool get hasLocalSnapshot => _hasLocalSnapshot;

  /// 等待首页和用户资料缓存启动加载完成。
  Future<void> ensureCacheLoaded() async {
    await (_cacheBootstrapFuture ?? Future<void>.value());
  }

  @override
  void onInit() {
    super.onInit();
    _cacheBootstrapFuture = _loadCache();
    ever<UserSessionData>(_sessionController.userInfo, (info) {
      if (_activeSnapshotUserId == info.userId) {
        return;
      }
      _activeSnapshotUserId = info.userId;
      dateLoaded.value = false;
      unawaited(_reloadScopedSnapshotAndBootstrap(info.userId));
    });
  }

  @override
  void onReady() {
    super.onReady();
    unawaited(startHomeBootstrap());
  }

  /// 启动首页数据加载流程，优先展示本地快照再按 TTL 后台刷新。
  Future<void> startHomeBootstrap() async {
    await ensureCacheLoaded();
    if (_hasLocalSnapshot) {
      dateLoaded.value = true;
      scheduleHomeImageColorPrewarm();
      unawaited(_validateLoginStateInBackground?.call());
      if (!_libraryController.hasPlaylistSnapshot ||
          await shouldRefreshStartupData()) {
        unawaited(updateData());
      }
      return;
    }
    await updateData();
  }

  Future<void> _reloadScopedSnapshotAndBootstrap(String userId) async {
    await _libraryController.loadScopedSnapshot(userId);
    await _loadScopedSnapshot(userId);
    await startHomeBootstrap();
  }

  /// 判断启动数据是否需要刷新。
  Future<bool> shouldRefreshStartupData() async {
    await ensureCacheLoaded();
    if (!_hasLocalSnapshot) {
      return true;
    }
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty) {
      return true;
    }
    return _homeService.shouldRefreshStartupData(
      userId: userId,
      markerKey: _startupSyncMarker,
      ttl: _startupDataTtl,
      hasLocalSnapshot: _hasLocalSnapshot,
    );
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
    _hasLocalSnapshot = true;
    await _homeService.markStartupDataUpdated(
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
    final data = await _homeService.fetchRecommendedPlaylists(
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
    return _homeService.fetchTodayRecommendSongs(
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
    return _homeService.fetchFmSongs(
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
            todayRecommendSongs.isNotEmpty
                ? todayRecommendSongs.first.artworkUrl
                : null,
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
    _activeSnapshotUserId = _sessionController.userInfo.value.userId;
    await _loadScopedSnapshot(_activeSnapshotUserId);
  }

  Future<void> _loadScopedSnapshot(String userId) async {
    recoPlayLists.clear();
    todayRecommendSongs.clear();
    fmSongs.clear();
    if (userId.isEmpty) {
      _hasLocalSnapshot = false;
      return;
    }

    final snapshot = await _homeService.loadLocalSnapshot(
      userId: userId,
      likedSongIds: _libraryController.likedSongIds.toList(),
    );
    recoPlayLists.addAll(snapshot.recommendedPlaylists);
    todayRecommendSongs.addAll(snapshot.todayRecommendSongs);
    fmSongs.addAll(snapshot.fmSongs);
    _hasLocalSnapshot = snapshot.hasData;
  }

  Future<void> _updateQuickStartCardData() async {
    final snapshot = await _homeService.refreshQuickStartData(
      userId: _sessionController.userInfo.value.userId,
      likedSongIds: _libraryController.likedSongIds.toList(),
    );
    todayRecommendSongs
      ..clear()
      ..addAll(snapshot.todayRecommendSongs);

    fmSongs
      ..clear()
      ..addAll(snapshot.fmSongs);
  }

  @override
  void onClose() {
    _homeImageColorPrewarmTimer?.cancel();
    refreshController.dispose();
    super.onClose();
  }
}
