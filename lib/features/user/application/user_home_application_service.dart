import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/features/user/user_repository.dart';

class UserHomeApplicationService {
  UserHomeApplicationService({required UserRepository repository})
      : _repository = repository;

  final UserRepository _repository;

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

  Future<void> markStartupDataUpdated({
    required String userId,
    required String markerKey,
  }) {
    return _repository.markSyncMarkerUpdated(
      userId: userId,
      markerKey: markerKey,
    );
  }

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

  Future<List<PlaybackQueueItem>> fetchTodayRecommendSongs({
    required String userId,
    required List<int> likedSongIds,
  }) {
    return _repository.fetchTodayRecommendSongs(
      userId: userId,
      likedSongIds: likedSongIds,
    );
  }

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

class UserHomeSnapshot {
  const UserHomeSnapshot({
    required this.recommendedPlaylists,
    required this.todayRecommendSongs,
    required this.fmSongs,
  });

  const UserHomeSnapshot.empty()
      : recommendedPlaylists = const [],
        todayRecommendSongs = const [],
        fmSongs = const [];

  final List<PlaylistSummaryData> recommendedPlaylists;
  final List<PlaybackQueueItem> todayRecommendSongs;
  final List<PlaybackQueueItem> fmSongs;

  bool get hasData =>
      recommendedPlaylists.isNotEmpty ||
      todayRecommendSongs.isNotEmpty ||
      fmSongs.isNotEmpty;
}
