import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/features/user/user_repository.dart';

/// UserHomeApplicationService。
class UserHomeApplicationService {
  /// 创建 UserHomeApplicationService。
  UserHomeApplicationService({required UserRepository repository})
      : _repository = repository;

  final UserRepository _repository;

  /// shouldRefreshStartupData。
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

  /// markStartupDataUpdated。
  Future<void> markStartupDataUpdated({
    required String userId,
    required String markerKey,
  }) {
    return _repository.markSyncMarkerUpdated(
      userId: userId,
      markerKey: markerKey,
    );
  }

  /// loadLocalSnapshot。
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

  /// refreshQuickStartData。
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

  /// fetchRecommendedPlaylists。
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

  /// fetchTodayRecommendSongs。
  Future<List<PlaybackQueueItem>> fetchTodayRecommendSongs({
    required String userId,
    required List<int> likedSongIds,
  }) {
    return _repository.fetchTodayRecommendSongs(
      userId: userId,
      likedSongIds: likedSongIds,
    );
  }

  /// fetchFmSongs。
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

/// UserHomeSnapshot。
class UserHomeSnapshot {
  /// 创建 UserHomeSnapshot。
  const UserHomeSnapshot({
    required this.recommendedPlaylists,
    required this.todayRecommendSongs,
    required this.fmSongs,
  });

  /// 创建 UserHomeSnapshot。
  const UserHomeSnapshot.empty()
      : recommendedPlaylists = const [],
        todayRecommendSongs = const [],
        fmSongs = const [];

  /// recommendedPlaylists。
  final List<PlaylistSummaryData> recommendedPlaylists;

  /// todayRecommendSongs。
  final List<PlaybackQueueItem> todayRecommendSongs;

  /// fmSongs。
  final List<PlaybackQueueItem> fmSongs;

  /// hasData。
  bool get hasData =>
      recommendedPlaylists.isNotEmpty ||
      todayRecommendSongs.isNotEmpty ||
      fmSongs.isNotEmpty;
}
