import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/features/user/user_repository.dart';

/// 编排首页推荐、日推和 FM 候选数据的应用服务。
class UserHomeApplicationService {
  /// 创建用户首页应用服务。
  UserHomeApplicationService({required UserRepository repository})
      : _repository = repository;

  final UserRepository _repository;

  /// 判断启动首页数据是否需要按 TTL 刷新。
  Future<bool> shouldRefreshStartupData({
    required String userId,
    required String markerKey,
    required Duration ttl,
    required bool hasLocalSnapshot,
  }) async {
    if (!hasLocalSnapshot || userId.isEmpty) {
      return true;
    }
    return !(await _repository.isSyncMarkerFresh(
      userId: userId,
      markerKey: markerKey,
      ttl: ttl,
    ));
  }

  /// 标记启动首页数据已经刷新。
  Future<void> markStartupDataUpdated({
    required String userId,
    required String markerKey,
  }) {
    return _repository.markSyncMarkerUpdated(
      userId: userId,
      markerKey: markerKey,
    );
  }

  /// 从本地缓存读取首页推荐、日推和 FM 候选快照。
  Future<UserHomeSnapshot> loadLocalSnapshot({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    if (userId.isEmpty) {
      return const UserHomeSnapshot.empty();
    }
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
    return UserHomeSnapshot(
      recommendedPlaylists: results[0] as List<PlaylistSummaryData>,
      todayRecommendSongs: results[1] as List<PlaybackQueueItem>,
      fmSongs: results[2] as List<PlaybackQueueItem>,
    );
  }

  /// 刷新首页启动阶段需要优先展示的日推和 FM 候选。
  Future<UserHomeSnapshot> refreshQuickStartData({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    if (userId.isEmpty || userId == '-1') {
      return const UserHomeSnapshot.empty();
    }
    final results = await Future.wait<Object>([
      fetchTodayRecommendSongs(userId: userId, likedSongIds: likedSongIds),
      fetchFmSongs(userId: userId, likedSongIds: likedSongIds),
    ]);
    return UserHomeSnapshot(
      recommendedPlaylists: const [],
      todayRecommendSongs: results[0] as List<PlaybackQueueItem>,
      fmSongs: results[1] as List<PlaybackQueueItem>,
    );
  }

  /// 分页拉取推荐歌单并交由仓库更新本地快照。
  Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists({
    required String userId,
    required int offset,
    int limit = 10,
  }) {
    return _repository.fetchRecommendedPlaylists(
      userId: userId,
      offset: offset,
      limit: limit,
    );
  }

  /// 拉取每日推荐歌曲并转换为播放队列项。
  Future<List<PlaybackQueueItem>> fetchTodayRecommendSongs({
    required String userId,
    required List<int> likedSongIds,
  }) {
    return _repository.fetchTodayRecommendSongs(
      userId: userId,
      likedSongIds: likedSongIds,
    );
  }

  /// 拉取私人 FM 候选歌曲并转换为播放队列项。
  Future<List<PlaybackQueueItem>> fetchFmSongs({
    required String userId,
    required List<int> likedSongIds,
  }) {
    return _repository.fetchFmSongs(
      userId: userId,
      likedSongIds: likedSongIds,
    );
  }
}

/// 首页用户数据快照，包含推荐歌单、日推歌曲和 FM 候选歌曲。
class UserHomeSnapshot {
  /// 创建首页用户数据快照。
  const UserHomeSnapshot({
    required this.recommendedPlaylists,
    required this.todayRecommendSongs,
    required this.fmSongs,
  });

  /// 创建空首页用户数据快照。
  const UserHomeSnapshot.empty()
      : recommendedPlaylists = const [],
        todayRecommendSongs = const [],
        fmSongs = const [];

  /// 推荐歌单快照。
  final List<PlaylistSummaryData> recommendedPlaylists;

  /// 每日推荐歌曲快照。
  final List<PlaybackQueueItem> todayRecommendSongs;

  /// 私人 FM 候选歌曲快照。
  final List<PlaybackQueueItem> fmSongs;

  /// 快照中是否包含任何可展示数据。
  bool get hasData =>
      recommendedPlaylists.isNotEmpty ||
      todayRecommendSongs.isNotEmpty ||
      fmSongs.isNotEmpty;
}
