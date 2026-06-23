import '../dao/user_playlist_subscription_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的歌单订阅状态数据源。
class DriftPlaylistSubscriptionDataSource implements PlaylistSubscriptionDataSource {
  /// 创建 Drift 歌单订阅状态数据源。
  const DriftPlaylistSubscriptionDataSource({required UserPlaylistSubscriptionDao dao}) : _dao = dao;

  final UserPlaylistSubscriptionDao _dao;

  @override
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  ) {
    return _dao.loadPlaylistSubscriptionState(userId, playlistId);
  }

  @override
  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  ) {
    return _dao.savePlaylistSubscriptionState(
      userId,
      playlistId,
      isSubscribed,
    );
  }
}
