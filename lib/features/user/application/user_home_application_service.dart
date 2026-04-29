import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/features/user/user_repository.dart';

class UserHomeApplicationService {
  UserHomeApplicationService({required UserRepository repository})
      : _repository = repository;

  final UserRepository _repository;

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
