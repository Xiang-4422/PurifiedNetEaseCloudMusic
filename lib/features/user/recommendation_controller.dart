import 'dart:async';

import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
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

/// 首页歌单播放前解析出的队列计划。
class UserHomePlaylistPlaybackPlan {
  /// 创建首页歌单播放计划。
  const UserHomePlaylistPlaybackPlan({
    required this.songs,
    required this.playlistName,
  });

  /// 可播放歌曲队列。
  final List<PlaybackQueueItem> songs;

  /// 播放队列名称。
  final String playlistName;
}

/// 首页推荐需要的资料库能力，避免推荐控制器直接依赖全局资料库控制器。
class RecommendationLibraryAccess {
  /// 创建首页推荐资料库访问边界。
  const RecommendationLibraryAccess({
    required this.ensureCacheLoaded,
    required this.loadScopedLocalData,
    required this.refreshUserLibrary,
    required this.hasPlaylistData,
    required this.likedSongIds,
    required this.randomLikedSongAlbumUrl,
  });

  /// 等待资料库缓存完成启动读取。
  final Future<void> Function() ensureCacheLoaded;

  /// 加载指定账号作用域下的资料库本地数据。
  final Future<void> Function(String userId) loadScopedLocalData;

  /// 远程刷新用户资料库快照。
  final Future<void> Function() refreshUserLibrary;

  /// 当前资料库是否已有歌单数据。
  final bool Function() hasPlaylistData;

  /// 当前喜欢歌曲 id 快照。
  final List<int> Function() likedSongIds;

  /// 当前随机我喜欢歌曲封面。
  final String Function() randomLikedSongAlbumUrl;
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
    required PlaylistRepository playlistRepository,
    required UserSessionController sessionController,
    required RecommendationLibraryAccess libraryAccess,
    Future<void> Function()? validateLoginStateInBackground,
  })  : _repository = repository,
        _playlistRepository = playlistRepository,
        _sessionController = sessionController,
        _libraryAccess = libraryAccess,
        _validateLoginStateInBackground = validateLoginStateInBackground;

  final UserRepository _repository;
  final PlaylistRepository _playlistRepository;
  final UserSessionController _sessionController;
  final RecommendationLibraryAccess _libraryAccess;
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
  int _localDataGeneration = 0;
  int _homeRefreshGeneration = 0;
  int _recoPlaylistGeneration = 0;
  int? _recoPlaylistRefreshGeneration;
  int? _recoPlaylistLoadMoreGeneration;
  bool _hasLocalData = false;
  bool _disposed = false;

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
    if (_disposed) {
      return;
    }
    if (_hasLocalData) {
      dateLoaded.value = true;
      scheduleHomeImageColorPrewarm();
      unawaited(_validateLoginStateInBackground?.call());
      if (!_libraryAccess.hasPlaylistData() || await shouldRefreshStartupData()) {
        unawaited(updateData());
      }
      return;
    }
    await updateData();
  }

  Future<void> _reloadScopedLocalDataAndBootstrap(String userId) async {
    _activeLocalDataUserId = userId;
    final generation = ++_localDataGeneration;
    await _libraryAccess.loadScopedLocalData(userId);
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    await _loadScopedLocalData(userId, generation);
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
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
    try {
      return !(await _repository.isSyncMarkerFresh(
        userId: userId,
        markerKey: _startupSyncMarker,
        ttl: _startupDataTtl,
      ));
    } catch (_) {
      return true;
    }
  }

  /// 刷新首页推荐、日推和 FM 候选数据。
  Future<void> updateData() async {
    if (_disposed) {
      return;
    }
    final userId = _sessionController.userInfo.value.userId;
    final generation = ++_homeRefreshGeneration;
    if (userId.isEmpty) {
      dateLoaded.value = true;
      refreshController.refreshCompleted();
      refreshController.resetNoData();
      return;
    }

    try {
      await _libraryAccess.refreshUserLibrary();
      if (!_isCurrentHomeRefresh(userId, generation)) {
        return;
      }
      await Future.wait([
        _updateQuickStartCardData(userId, generation),
        updateRecoPlayLists(),
      ]);
      if (!_isCurrentHomeRefresh(userId, generation)) {
        return;
      }
      _hasLocalData = true;
      await _repository.markSyncMarkerUpdated(
        userId: userId,
        markerKey: _startupSyncMarker,
      );
      if (!_isCurrentHomeRefresh(userId, generation)) {
        return;
      }
      dateLoaded.value = true;
      scheduleHomeImageColorPrewarm();
      refreshController.refreshCompleted();
      refreshController.resetNoData();
    } catch (_) {
      if (!_isCurrentHomeRefresh(userId, generation)) {
        return;
      }
      _hasLocalData = _hasLocalData || _hasVisibleHomeData;
      dateLoaded.value = true;
      refreshController.refreshFailed();
      refreshController.resetNoData();
    }
  }

  /// 刷新推荐歌单，`getMore` 为 true 时追加下一页。
  Future<void> updateRecoPlayLists({bool getMore = false}) async {
    if (_disposed) {
      return;
    }
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      return;
    }

    if (getMore && (_recoPlaylistRefreshGeneration != null || _recoPlaylistLoadMoreGeneration != null)) {
      refreshController.loadComplete();
      return;
    }

    final generation = getMore ? _recoPlaylistGeneration : ++_recoPlaylistGeneration;
    if (getMore) {
      _recoPlaylistLoadMoreGeneration = generation;
    } else {
      _recoPlaylistRefreshGeneration = generation;
    }

    try {
      final data = await _repository.fetchRecommendedPlaylists(
        userId: userId,
        offset: getMore ? recoPlayLists.length : 0,
      );
      if (!_isCurrentRecoPlaylistLoad(userId, generation)) {
        return;
      }
      if (!getMore) {
        recoPlayLists.clear();
      }
      recoPlayLists.addAll(data);
      refreshController.loadComplete();
    } finally {
      if (getMore) {
        if (_recoPlaylistLoadMoreGeneration == generation) {
          _recoPlaylistLoadMoreGeneration = null;
        }
      } else if (_recoPlaylistRefreshGeneration == generation) {
        _recoPlaylistRefreshGeneration = null;
      }
    }
  }

  /// 拉取每日推荐歌曲队列。
  Future<List<PlaybackQueueItem>> getTodayRecommendSongs() async {
    final userId = _sessionController.userInfo.value.userId;
    if (userId.isEmpty || userId == '-1') {
      return const [];
    }
    return _repository.fetchTodayRecommendSongs(
      userId: userId,
      likedSongIds: _libraryAccess.likedSongIds(),
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
      likedSongIds: _libraryAccess.likedSongIds(),
    );
  }

  /// 将首页常用歌单摘要解析为播放队列计划。
  Future<UserHomePlaylistPlaybackPlan> resolveFrequentPlaylistPlayback(
    PlaylistSummaryData playlist,
  ) async {
    final likedSongIds = _libraryAccess.likedSongIds();
    final userId = _sessionController.userInfo.value.userId;
    final index = await _playlistRepository.fetchPlaylistIndex(
      playlist.id,
      currentUserId: userId,
      likedSongIds: likedSongIds,
    );
    final songs = await _playlistRepository.fetchPlaylistSongs(
      playlistId: playlist.id,
      likedSongIds: likedSongIds,
      playlistIndex: index,
    );
    return UserHomePlaylistPlaybackPlan(
      songs: songs,
      playlistName: index.name,
    );
  }

  /// 延迟预热首页卡片封面主色，避免阻塞首帧数据展示。
  void scheduleHomeImageColorPrewarm() {
    if (_disposed) {
      return;
    }
    _homeImageColorPrewarmTimer?.cancel();
    _homeImageColorPrewarmTimer = Timer(const Duration(milliseconds: 120), () {
      if (_disposed) {
        return;
      }
      unawaited(
        ImageColorService.prewarm(
          [
            todayRecommendSongs.isNotEmpty ? todayRecommendSongs.first.artworkUrl : null,
            fmSongs.isNotEmpty ? fmSongs.first.artworkUrl : null,
            _libraryAccess.randomLikedSongAlbumUrl(),
          ],
        ),
      );
    });
  }

  Future<void> _loadCache() async {
    await _sessionController.ensureCacheLoaded();
    await _libraryAccess.ensureCacheLoaded();
    _activeLocalDataUserId = _sessionController.userInfo.value.userId;
    final generation = ++_localDataGeneration;
    await _loadScopedLocalData(_activeLocalDataUserId, generation);
  }

  Future<void> _loadScopedLocalData(String userId, int generation) async {
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    recoPlayLists.clear();
    todayRecommendSongs.clear();
    fmSongs.clear();
    if (userId.isEmpty) {
      _hasLocalData = false;
      return;
    }

    final localData = await _loadLocalData(userId);
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    recoPlayLists.addAll(localData.recommendedPlaylists);
    todayRecommendSongs.addAll(localData.todayRecommendSongs);
    fmSongs.addAll(localData.fmSongs);
    _hasLocalData = localData.hasData;
  }

  Future<void> _updateQuickStartCardData(String userId, int generation) async {
    final localData = await _refreshQuickStartData(userId);
    if (!_isCurrentHomeRefresh(userId, generation)) {
      return;
    }
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
    final likedSongIds = _libraryAccess.likedSongIds();
    final results = await Future.wait<Object>([
      _loadCachedPlaylistList(
        userId,
        UserPlaylistListKind.recommended,
      ),
      _loadCachedTrackList(
        userId: userId,
        kind: UserTrackListKind.dailyRecommend,
        likedSongIds: likedSongIds,
      ),
      _loadCachedTrackList(
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

  Future<UserHomeLocalData> _refreshQuickStartData(String userId) async {
    if (userId.isEmpty || userId == '-1') {
      return const UserHomeLocalData.empty();
    }
    final likedSongIds = _libraryAccess.likedSongIds();
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

  Future<List<PlaylistSummaryData>> _loadCachedPlaylistList(
    String userId,
    UserPlaylistListKind kind,
  ) async {
    try {
      return await _repository.loadCachedPlaylistList(userId, kind);
    } catch (_) {
      return const [];
    }
  }

  Future<List<PlaybackQueueItem>> _loadCachedTrackList({
    required String userId,
    required UserTrackListKind kind,
    required List<int> likedSongIds,
  }) async {
    try {
      return await _repository.loadCachedTrackList(
        userId: userId,
        kind: kind,
        likedSongIds: likedSongIds,
      );
    } catch (_) {
      return const [];
    }
  }

  bool _isCurrentLocalDataLoad(String userId, int generation) {
    return !_disposed && generation == _localDataGeneration && _activeLocalDataUserId == userId && _sessionController.userInfo.value.userId == userId;
  }

  bool _isCurrentRecoPlaylistLoad(String userId, int generation) {
    return !_disposed && generation == _recoPlaylistGeneration && _isActiveSession(userId);
  }

  bool _isCurrentHomeRefresh(String userId, int generation) {
    return !_disposed && generation == _homeRefreshGeneration && _isActiveSession(userId);
  }

  bool _isActiveSession(String userId) {
    return !_disposed && _sessionController.userInfo.value.userId == userId;
  }

  bool get _hasVisibleHomeData {
    return recoPlayLists.isNotEmpty || todayRecommendSongs.isNotEmpty || fmSongs.isNotEmpty;
  }

  @override
  void onClose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _localDataGeneration++;
    _homeRefreshGeneration++;
    _recoPlaylistGeneration++;
    _recoPlaylistRefreshGeneration = null;
    _recoPlaylistLoadMoreGeneration = null;
    _homeImageColorPrewarmTimer?.cancel();
    refreshController.dispose();
    super.onClose();
  }
}
