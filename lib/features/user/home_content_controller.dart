import 'dart:async';

import 'package:bujuan/core/entities/liked_song_ids.dart';
import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:get/get.dart';

/// 首页用户本地数据，包含日推歌曲。
class UserHomeLocalData {
  /// 创建首页用户本地数据。
  const UserHomeLocalData({
    required this.todayRecommendSongs,
  });

  /// 创建空首页用户本地数据。
  const UserHomeLocalData.empty() : todayRecommendSongs = const [];

  /// 每日推荐歌曲数据。
  final List<PlaybackQueueItem> todayRecommendSongs;

  /// 是否包含任何可展示数据。
  bool get hasData => todayRecommendSongs.isNotEmpty;
}

/// 首页内容需要的当前账号 session 能力。
class HomeContentSessionAccess {
  /// 创建首页内容 session 访问边界。
  const HomeContentSessionAccess({
    required this.ensureCacheLoaded,
    required this.currentSession,
    required this.watchSession,
  });

  /// 等待当前账号 session 缓存完成启动读取。
  final Future<void> Function() ensureCacheLoaded;

  /// 当前 App 用户 session 快照。
  final UserSessionData Function() currentSession;

  /// 监听当前 App 用户 session 变化，返回取消监听函数。
  final void Function() Function(void Function(UserSessionData info) onChanged) watchSession;
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

/// 首页内容需要的资料库能力，避免首页内容控制器直接依赖全局资料库控制器。
class HomeContentLibraryAccess {
  /// 创建首页内容资料库访问边界。
  const HomeContentLibraryAccess({
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

/// 持有首页轻量内容和日推歌曲状态。
class HomeContentController extends GetxController {
  static const Duration _startupDataTtl = Duration(minutes: 10);
  static const String _startupSyncMarker = 'startup_home';

  /// 创建首页内容控制器。
  HomeContentController({
    required UserRepository repository,
    required PlaylistRepository playlistRepository,
    required HomeContentSessionAccess sessionAccess,
    required HomeContentLibraryAccess libraryAccess,
    Future<void> Function()? validateLoginStateInBackground,
  })  : _repository = repository,
        _playlistRepository = playlistRepository,
        _sessionAccess = sessionAccess,
        _libraryAccess = libraryAccess,
        _validateLoginStateInBackground = validateLoginStateInBackground;

  final UserRepository _repository;
  final PlaylistRepository _playlistRepository;
  final HomeContentSessionAccess _sessionAccess;
  final HomeContentLibraryAccess _libraryAccess;
  final Future<void> Function()? _validateLoginStateInBackground;

  /// 首页内容数据是否已经完成首轮加载。
  final RxBool dateLoaded = false.obs;

  /// 每日推荐歌曲队列。
  final RxList<PlaybackQueueItem> todayRecommendSongs = <PlaybackQueueItem>[].obs;

  Future<void>? _cacheBootstrapFuture;
  Timer? _homeImageColorPrewarmTimer;
  void Function()? _cancelSessionWatch;
  String _activeLocalDataUserId = '';
  int _localDataGeneration = 0;
  int _homeRefreshGeneration = 0;
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
    _cancelSessionWatch = _sessionAccess.watchSession((info) {
      final nextUserId = _normalizedUserId(info.userId);
      if (_activeLocalDataUserId == nextUserId) {
        return;
      }
      dateLoaded.value = false;
      unawaited(_reloadScopedLocalDataAndBootstrap(nextUserId));
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
    if (!_isSignedInUserId(_currentUserId())) {
      _clearHomeState();
      _hasLocalData = false;
      dateLoaded.value = true;
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
    final normalizedUserId = _normalizedUserId(userId);
    _activeLocalDataUserId = normalizedUserId;
    final generation = ++_localDataGeneration;
    await _libraryAccess.loadScopedLocalData(normalizedUserId);
    if (!_isCurrentLocalDataLoad(normalizedUserId, generation)) {
      return;
    }
    await _loadScopedLocalData(normalizedUserId, generation);
    if (!_isCurrentLocalDataLoad(normalizedUserId, generation)) {
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
    final userId = _currentUserId();
    if (!_isSignedInUserId(userId)) {
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

  /// 刷新首页轻量内容和日推数据。
  Future<void> updateData() async {
    if (_disposed) {
      return;
    }
    final userId = _currentUserId();
    final generation = ++_homeRefreshGeneration;
    if (!_isSignedInUserId(userId)) {
      _clearHomeState();
      _hasLocalData = false;
      dateLoaded.value = true;
      return;
    }

    try {
      await _libraryAccess.refreshUserLibrary();
      if (!_isCurrentHomeRefresh(userId, generation)) {
        return;
      }
      await _updateQuickStartCardData(userId, generation);
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
    } catch (_) {
      if (!_isCurrentHomeRefresh(userId, generation)) {
        return;
      }
      _hasLocalData = _hasLocalData || _hasVisibleHomeData;
      dateLoaded.value = true;
    }
  }

  /// 将首页常用歌单摘要解析为播放队列计划。
  Future<UserHomePlaylistPlaybackPlan> resolveFrequentPlaylistPlayback(
    PlaylistSummaryData playlist,
  ) async {
    final likedSongIds = _likedSongIdsSnapshot();
    final userId = _currentUserId();
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
            _libraryAccess.randomLikedSongAlbumUrl(),
          ],
        ),
      );
    });
  }

  Future<void> _loadCache() async {
    await _sessionAccess.ensureCacheLoaded();
    await _libraryAccess.ensureCacheLoaded();
    _activeLocalDataUserId = _currentUserId();
    final generation = ++_localDataGeneration;
    await _loadScopedLocalData(_activeLocalDataUserId, generation);
  }

  Future<void> _loadScopedLocalData(String userId, int generation) async {
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    _clearHomeState();
    if (!_isSignedInUserId(userId)) {
      _hasLocalData = false;
      return;
    }

    final localData = await _loadLocalData(userId);
    if (!_isCurrentLocalDataLoad(userId, generation)) {
      return;
    }
    todayRecommendSongs.addAll(localData.todayRecommendSongs);
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
  }

  Future<UserHomeLocalData> _loadLocalData(String userId) async {
    if (!_isSignedInUserId(userId)) {
      return const UserHomeLocalData.empty();
    }
    final likedSongIds = _likedSongIdsSnapshot();
    final songs = await _loadCachedTrackList(
      userId: userId,
      kind: UserTrackListKind.dailyRecommend,
      likedSongIds: likedSongIds,
    );
    return UserHomeLocalData(
      todayRecommendSongs: songs,
    );
  }

  Future<UserHomeLocalData> _refreshQuickStartData(String userId) async {
    if (!_isSignedInUserId(userId)) {
      return const UserHomeLocalData.empty();
    }
    final likedSongIds = _likedSongIdsSnapshot();
    final songs = await _repository.fetchTodayRecommendSongs(
      userId: userId,
      likedSongIds: likedSongIds,
    );
    return UserHomeLocalData(
      todayRecommendSongs: songs,
    );
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
    return !_disposed && generation == _localDataGeneration && _activeLocalDataUserId == userId && _currentUserId() == userId;
  }

  bool _isCurrentHomeRefresh(String userId, int generation) {
    return !_disposed && generation == _homeRefreshGeneration && _isActiveSession(userId);
  }

  bool _isActiveSession(String userId) {
    return !_disposed && _currentUserId() == _normalizedUserId(userId);
  }

  String _currentUserId() {
    return _normalizedUserId(_sessionAccess.currentSession().userId);
  }

  String _normalizedUserId(String userId) {
    return userId.trim();
  }

  List<int> _likedSongIdsSnapshot() {
    return normalizeLikedSongIds(_libraryAccess.likedSongIds());
  }

  bool _isSignedInUserId(String userId) {
    final normalizedUserId = _normalizedUserId(userId);
    return normalizedUserId.isNotEmpty && normalizedUserId != '-1';
  }

  bool get _hasVisibleHomeData {
    return todayRecommendSongs.isNotEmpty;
  }

  void _clearHomeState() {
    todayRecommendSongs.clear();
  }

  @override
  void onClose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _localDataGeneration++;
    _homeRefreshGeneration++;
    _homeImageColorPrewarmTimer?.cancel();
    _cancelSessionWatch?.call();
    _cancelSessionWatch = null;
    super.onClose();
  }
}
