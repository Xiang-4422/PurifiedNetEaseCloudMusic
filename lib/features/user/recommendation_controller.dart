import 'dart:async';

import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 持有首页推荐、日推和 FM 候选歌曲状态。
class RecommendationController extends GetxController {
  static const Duration _startupDataTtl = Duration(minutes: 10);
  static const String _startupSyncMarker = 'startup_home';

  static RecommendationController get to => Get.find();

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

  final RefreshController refreshController = RefreshController();
  final RxBool dateLoaded = false.obs;
  final RxList<PlaylistSummaryData> recoPlayLists = <PlaylistSummaryData>[].obs;
  final RxList<PlaybackQueueItem> todayRecommendSongs =
      <PlaybackQueueItem>[].obs;
  final RxList<PlaybackQueueItem> fmSongs = <PlaybackQueueItem>[].obs;

  Future<void>? _cacheBootstrapFuture;
  Timer? _homeImageColorPrewarmTimer;
  String _activeSnapshotUserId = '';
  bool _hasLocalSnapshot = false;

  bool get hasLocalSnapshot => _hasLocalSnapshot;

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

  Future<bool> shouldRefreshStartupData() async {
    await ensureCacheLoaded();
    if (!_hasLocalSnapshot) {
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
    await _repository.markSyncMarkerUpdated(
      userId: userId,
      markerKey: _startupSyncMarker,
    );
    dateLoaded.value = true;
    scheduleHomeImageColorPrewarm();
    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

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

  void scheduleHomeImageColorPrewarm() {
    _homeImageColorPrewarmTimer?.cancel();
    _homeImageColorPrewarmTimer = Timer(const Duration(milliseconds: 120), () {
      unawaited(
        OtherUtils.prewarmImageColors(
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

    var hasCachedData = false;
    final cachedReco = await _repository.loadCachedPlaylistList(
      userId,
      UserPlaylistListKind.recommended,
    );
    recoPlayLists.addAll(cachedReco);
    hasCachedData = hasCachedData || cachedReco.isNotEmpty;

    final cachedTodaySongs = await _repository.loadCachedTrackList(
      userId: userId,
      kind: UserTrackListKind.dailyRecommend,
      likedSongIds: _libraryController.likedSongIds.toList(),
    );
    todayRecommendSongs.addAll(cachedTodaySongs);
    hasCachedData = hasCachedData || cachedTodaySongs.isNotEmpty;

    final cachedFmSongs = await _repository.loadCachedTrackList(
      userId: userId,
      kind: UserTrackListKind.fm,
      likedSongIds: _libraryController.likedSongIds.toList(),
    );
    fmSongs.addAll(cachedFmSongs);
    hasCachedData = hasCachedData || cachedFmSongs.isNotEmpty;
    _hasLocalSnapshot = hasCachedData;
  }

  Future<void> _updateQuickStartCardData() async {
    final nextTodayRecommendSongs = await getTodayRecommendSongs();
    todayRecommendSongs
      ..clear()
      ..addAll(nextTodayRecommendSongs);

    final nextFmSongs = await getFmSongs();
    fmSongs
      ..clear()
      ..addAll(nextFmSongs);
  }

  @override
  void onClose() {
    _homeImageColorPrewarmTimer?.cancel();
    refreshController.dispose();
    super.onClose();
  }
}
