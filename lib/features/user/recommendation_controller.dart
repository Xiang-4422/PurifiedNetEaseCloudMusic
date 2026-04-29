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

  /// to。
  static RecommendationController get to => Get.find();

  /// 创建 RecommendationController。
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

  /// refreshController。
  final RefreshController refreshController = RefreshController();

  /// dateLoaded。
  final RxBool dateLoaded = false.obs;

  /// recoPlayLists。
  final RxList<PlaylistSummaryData> recoPlayLists = <PlaylistSummaryData>[].obs;

  /// todayRecommendSongs。
  final RxList<PlaybackQueueItem> todayRecommendSongs =
      <PlaybackQueueItem>[].obs;

  /// fmSongs。
  final RxList<PlaybackQueueItem> fmSongs = <PlaybackQueueItem>[].obs;

  Future<void>? _cacheBootstrapFuture;
  Timer? _homeImageColorPrewarmTimer;
  String _activeSnapshotUserId = '';
  bool _hasLocalSnapshot = false;

  /// hasLocalSnapshot。
  bool get hasLocalSnapshot => _hasLocalSnapshot;

  /// ensureCacheLoaded。
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

  /// startHomeBootstrap。
  Future<void> startHomeBootstrap() async {
    await ensureCacheLoaded();
    if (_hasLocalSnapshot) {
      dateLoaded.value = true;
      scheduleHomeImageColorPrewarm();
      unawaited(_validateLoginStateInBackground?.call());
      if (await shouldRefreshStartupData()) {
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

  /// shouldRefreshStartupData。
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

  /// updateData。
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

  /// updateRecoPlayLists。
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

  /// getTodayRecommendSongs。
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

  /// getFmSongs。
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

  /// scheduleHomeImageColorPrewarm。
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
